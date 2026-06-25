/// TanStack Query hooks for Customer.
///
/// Fixes vs v1:
///   - use cases memoised (stable instance, no allocation per render)
///   - pagination uses useInfiniteQuery (real infinite-scroll)
///   - optimistic_updates flag wires onMutate/onError rollback
///   - success_feedback callbacks exposed so pages can show toasts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useInfiniteQuery } from '@tanstack/react-query';
import type { UseQueryResult } from '@tanstack/react-query';
import { useMemo } from 'react';
import type { CustomerEntity } from '../../domain/entities/customer.entity';
import type { CustomerRepository } from '../../domain/repositories/customer.repository';
import {
  GetAllCustomersUseCase,
  GetCustomerByIdUseCase,
  AddCustomerUseCase,
  UpdateCustomerUseCase,
  DeleteCustomerUseCase,
} from '../../domain/usecases/customer.usecases';
import { SearchCustomersUseCase } from '../../domain/usecases/customer.usecases';
import { GetAllCustomersPaginatedUseCase } from '../../domain/usecases/customer.usecases';
import { useCustomerRepositoryContext } from '../customer.repository-context';

/// Stable string key — avoids accidental collision with other features.
const QUERY_KEY = 'customer' as const;

export function useCustomerRepository(): CustomerRepository {
  return useCustomerRepositoryContext();
}

// ---------------------------------------------------------------------------
// Queries
// ---------------------------------------------------------------------------

export function useCustomerList(): UseQueryResult<CustomerEntity[], Error> {
  const repository = useCustomerRepository();
  const useCase = useMemo(() => new GetAllCustomersUseCase(repository), [repository]);
  return useQuery({
    queryKey: [QUERY_KEY],
    queryFn: () =>
      useCase.execute().then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
  });
}

/// Infinite-scroll paginated list.
/// Consumers: `data.pages.flatMap(p => p.items)`, `fetchNextPage`, `hasNextPage`.
const PAGE_SIZE = 20;

export function useCustomerListInfinite() {
  const repository = useCustomerRepository();
  const useCase = useMemo(() => new GetAllCustomersPaginatedUseCase(repository), [repository]);
  return useInfiniteQuery({
    queryKey: [QUERY_KEY, 'infinite'],
    queryFn: ({ pageParam }) =>
      useCase.execute({ offset: pageParam as number, limit: PAGE_SIZE }).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    initialPageParam: 0,
    getNextPageParam: (lastPage) => {
      const fetched = lastPage.offset + lastPage.items.length;
      return fetched < lastPage.total ? fetched : undefined;
    },
  });
}

export function useCustomerById(id: string): UseQueryResult<CustomerEntity, Error> {
  const repository = useCustomerRepository();
  const useCase = useMemo(() => new GetCustomerByIdUseCase(repository), [repository]);
  return useQuery({
    queryKey: [QUERY_KEY, id],
    queryFn: () =>
      useCase.execute(id).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    enabled: !!id,
  });
}

export function useCustomerSearch(query: string): UseQueryResult<CustomerEntity[], Error> {
  const repository = useCustomerRepository();
  const useCase = useMemo(() => new SearchCustomersUseCase(repository), [repository]);
  return useQuery({
    queryKey: [QUERY_KEY, 'search', query],
    queryFn: () =>
      useCase.execute(query).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    enabled: query.trim().length > 0,
  });
}

// ---------------------------------------------------------------------------
// Mutations
// ---------------------------------------------------------------------------

interface MutationCallbacks {
  onSuccess?: (message: string) => void;
}

export function useCustomerMutations({ onSuccess: onSuccessCallback }: MutationCallbacks = {}) {
  const queryClient = useQueryClient();
  const repository = useCustomerRepository();

  /// Stable use-case instances — one per hook mount, not per mutation call.
  const addUseCase = useMemo(() => new AddCustomerUseCase(repository), [repository]);
  const updateUseCase = useMemo(() => new UpdateCustomerUseCase(repository), [repository]);
  const deleteUseCase = useMemo(() => new DeleteCustomerUseCase(repository), [repository]);

  // ---- add ----------------------------------------------------------------
  const addMutation = useMutation({
    mutationFn: (entity: CustomerEntity) =>
      addUseCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    onMutate: async (newEntity) => {
      await queryClient.cancelQueries({ queryKey: [QUERY_KEY] });
      const snapshot = queryClient.getQueryData<CustomerEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<CustomerEntity[]>([QUERY_KEY], (old = []) => [
        ...old,
        newEntity,
      ]);
      return { snapshot };
    },
    onError: (_err, _vars, context) => {
      if (context?.snapshot !== undefined) {
        queryClient.setQueryData([QUERY_KEY], context.snapshot);
      }
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: [QUERY_KEY] }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
      onSuccessCallback?.('Customer added');
    },
  });

  // ---- update -------------------------------------------------------------
  const updateMutation = useMutation({
    mutationFn: (entity: CustomerEntity) =>
      updateUseCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    onMutate: async (updated) => {
      await queryClient.cancelQueries({ queryKey: [QUERY_KEY] });
      const snapshot = queryClient.getQueryData<CustomerEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<CustomerEntity[]>([QUERY_KEY], (old = []) =>
        old.map((e) => (e.id === updated.id ? updated : e)),
      );
      return { snapshot };
    },
    onError: (_err, _vars, context) => {
      if (context?.snapshot !== undefined) {
        queryClient.setQueryData([QUERY_KEY], context.snapshot);
      }
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: [QUERY_KEY] }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
      onSuccessCallback?.('Customer updated');
    },
  });

  // ---- delete -------------------------------------------------------------
  const deleteMutation = useMutation({
    mutationFn: (id: string) =>
      deleteUseCase.execute(id).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: [QUERY_KEY] });
      const snapshot = queryClient.getQueryData<CustomerEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<CustomerEntity[]>([QUERY_KEY], (old = []) =>
        old.filter((e) => e.id !== id),
      );
      return { snapshot };
    },
    onError: (_err, _vars, context) => {
      if (context?.snapshot !== undefined) {
        queryClient.setQueryData([QUERY_KEY], context.snapshot);
      }
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: [QUERY_KEY] }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: [QUERY_KEY] });
      onSuccessCallback?.('Customer deleted');
    },
  });

  return {
    add: addMutation,
    update: updateMutation,
    delete: deleteMutation,
  };
}
