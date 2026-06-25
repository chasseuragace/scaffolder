/// TanStack Query hooks for Order.
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
import type { OrderEntity } from '../../domain/entities/order.entity';
import type { OrderRepository } from '../../domain/repositories/order.repository';
import {
  GetAllOrdersUseCase,
  GetOrderByIdUseCase,
  AddOrderUseCase,
  UpdateOrderUseCase,
  DeleteOrderUseCase,
} from '../../domain/usecases/order.usecases';
import { SearchOrdersUseCase } from '../../domain/usecases/order.usecases';
import { GetAllOrdersPaginatedUseCase } from '../../domain/usecases/order.usecases';
import { useOrderRepositoryContext } from '../order.repository-context';

/// Stable string key — avoids accidental collision with other features.
const QUERY_KEY = 'order' as const;

export function useOrderRepository(): OrderRepository {
  return useOrderRepositoryContext();
}

// ---------------------------------------------------------------------------
// Queries
// ---------------------------------------------------------------------------

export function useOrderList(): UseQueryResult<OrderEntity[], Error> {
  const repository = useOrderRepository();
  const useCase = useMemo(() => new GetAllOrdersUseCase(repository), [repository]);
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

export function useOrderListInfinite() {
  const repository = useOrderRepository();
  const useCase = useMemo(() => new GetAllOrdersPaginatedUseCase(repository), [repository]);
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

export function useOrderById(id: string): UseQueryResult<OrderEntity, Error> {
  const repository = useOrderRepository();
  const useCase = useMemo(() => new GetOrderByIdUseCase(repository), [repository]);
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

export function useOrderSearch(query: string): UseQueryResult<OrderEntity[], Error> {
  const repository = useOrderRepository();
  const useCase = useMemo(() => new SearchOrdersUseCase(repository), [repository]);
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

export function useOrderMutations({ onSuccess: onSuccessCallback }: MutationCallbacks = {}) {
  const queryClient = useQueryClient();
  const repository = useOrderRepository();

  /// Stable use-case instances — one per hook mount, not per mutation call.
  const addUseCase = useMemo(() => new AddOrderUseCase(repository), [repository]);
  const updateUseCase = useMemo(() => new UpdateOrderUseCase(repository), [repository]);
  const deleteUseCase = useMemo(() => new DeleteOrderUseCase(repository), [repository]);

  // ---- add ----------------------------------------------------------------
  const addMutation = useMutation({
    mutationFn: (entity: OrderEntity) =>
      addUseCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    onMutate: async (newEntity) => {
      await queryClient.cancelQueries({ queryKey: [QUERY_KEY] });
      const snapshot = queryClient.getQueryData<OrderEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<OrderEntity[]>([QUERY_KEY], (old = []) => [
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
      onSuccessCallback?.('Order added');
    },
  });

  // ---- update -------------------------------------------------------------
  const updateMutation = useMutation({
    mutationFn: (entity: OrderEntity) =>
      updateUseCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    onMutate: async (updated) => {
      await queryClient.cancelQueries({ queryKey: [QUERY_KEY] });
      const snapshot = queryClient.getQueryData<OrderEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<OrderEntity[]>([QUERY_KEY], (old = []) =>
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
      onSuccessCallback?.('Order updated');
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
      const snapshot = queryClient.getQueryData<OrderEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<OrderEntity[]>([QUERY_KEY], (old = []) =>
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
      onSuccessCallback?.('Order deleted');
    },
  });

  return {
    add: addMutation,
    update: updateMutation,
    delete: deleteMutation,
  };
}
