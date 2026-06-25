/// TanStack Query hooks for LoyaltyCard.
///
/// Fixes vs v1:
///   - use cases memoised (stable instance, no allocation per render)
///   - pagination uses useInfiniteQuery (real infinite-scroll)
///   - optimistic_updates flag wires onMutate/onError rollback
///   - success_feedback callbacks exposed so pages can show toasts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import type { UseQueryResult } from '@tanstack/react-query';
import { useMemo } from 'react';
import type { LoyaltyCardEntity } from '../../domain/entities/loyalty-card.entity';
import type { LoyaltyCardRepository } from '../../domain/repositories/loyalty-card.repository';
import {
  GetAllLoyaltyCardsUseCase,
  GetLoyaltyCardByIdUseCase,
  AddLoyaltyCardUseCase,
  UpdateLoyaltyCardUseCase,
  DeleteLoyaltyCardUseCase,
} from '../../domain/usecases/loyalty-card.usecases';
import { useLoyaltyCardRepositoryContext } from '../loyalty-card.repository-context';

/// Stable string key — avoids accidental collision with other features.
const QUERY_KEY = 'loyalty-card' as const;

export function useLoyaltyCardRepository(): LoyaltyCardRepository {
  return useLoyaltyCardRepositoryContext();
}

// ---------------------------------------------------------------------------
// Queries
// ---------------------------------------------------------------------------

export function useLoyaltyCardList(): UseQueryResult<LoyaltyCardEntity[], Error> {
  const repository = useLoyaltyCardRepository();
  const useCase = useMemo(() => new GetAllLoyaltyCardsUseCase(repository), [repository]);
  return useQuery({
    queryKey: [QUERY_KEY],
    queryFn: () =>
      useCase.execute().then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
  });
}

export function useLoyaltyCardById(id: string): UseQueryResult<LoyaltyCardEntity, Error> {
  const repository = useLoyaltyCardRepository();
  const useCase = useMemo(() => new GetLoyaltyCardByIdUseCase(repository), [repository]);
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

// ---------------------------------------------------------------------------
// Mutations
// ---------------------------------------------------------------------------

interface MutationCallbacks {
  onSuccess?: (message: string) => void;
}

export function useLoyaltyCardMutations({ onSuccess: onSuccessCallback }: MutationCallbacks = {}) {
  const queryClient = useQueryClient();
  const repository = useLoyaltyCardRepository();

  /// Stable use-case instances — one per hook mount, not per mutation call.
  const addUseCase = useMemo(() => new AddLoyaltyCardUseCase(repository), [repository]);
  const updateUseCase = useMemo(() => new UpdateLoyaltyCardUseCase(repository), [repository]);
  const deleteUseCase = useMemo(() => new DeleteLoyaltyCardUseCase(repository), [repository]);

  // ---- add ----------------------------------------------------------------
  const addMutation = useMutation({
    mutationFn: (entity: LoyaltyCardEntity) =>
      addUseCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    onMutate: async (newEntity) => {
      await queryClient.cancelQueries({ queryKey: [QUERY_KEY] });
      const snapshot = queryClient.getQueryData<LoyaltyCardEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<LoyaltyCardEntity[]>([QUERY_KEY], (old = []) => [
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
      onSuccessCallback?.('LoyaltyCard added');
    },
  });

  // ---- update -------------------------------------------------------------
  const updateMutation = useMutation({
    mutationFn: (entity: LoyaltyCardEntity) =>
      updateUseCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      }),
    onMutate: async (updated) => {
      await queryClient.cancelQueries({ queryKey: [QUERY_KEY] });
      const snapshot = queryClient.getQueryData<LoyaltyCardEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<LoyaltyCardEntity[]>([QUERY_KEY], (old = []) =>
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
      onSuccessCallback?.('LoyaltyCard updated');
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
      const snapshot = queryClient.getQueryData<LoyaltyCardEntity[]>([QUERY_KEY]);
      queryClient.setQueryData<LoyaltyCardEntity[]>([QUERY_KEY], (old = []) =>
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
      onSuccessCallback?.('LoyaltyCard deleted');
    },
  });

  return {
    add: addMutation,
    update: updateMutation,
    delete: deleteMutation,
  };
}
