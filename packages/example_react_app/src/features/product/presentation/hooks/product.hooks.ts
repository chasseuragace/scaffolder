/// TanStack Query hooks for Product.
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import type { UseQueryResult } from '@tanstack/react-query';
import type { ProductEntity } from '../../domain/entities/product.entity';
import type { ProductRepository } from '../../domain/repositories/product.repository';
import { GetAllProductsUseCase, GetProductByIdUseCase, AddProductUseCase, UpdateProductUseCase, DeleteProductUseCase } from '../../domain/usecases/product.usecases';
import { GetAllProductsPaginatedUseCase } from '../../domain/usecases/product.usecases';
import type { PaginationParams } from '../../../../core/pagination/pagination';
import { SearchProductsUseCase } from '../../domain/usecases/product.usecases';
import { useProductRepositoryContext } from '../product.repository-context';

const QUERY_KEY = ['product'];

export function useProductRepository(): ProductRepository {
  return useProductRepositoryContext();
}

export function useProductList(): UseQueryResult<ProductEntity[], Error> {
  const repository = useProductRepository();
  const useCase = new GetAllProductsUseCase(repository);
  return useQuery({
    queryKey: QUERY_KEY,
    queryFn: () => useCase.execute().then((result) => {
      if ('left' in result) throw new Error(result.left.message);
      return result.right;
    }),
  });
}

export function useProductListPaginated(params: PaginationParams): UseQueryResult<{ items: ProductEntity[]; total: number; hasMore: boolean }, Error> {
  const repository = useProductRepository();
  const useCase = new GetAllProductsPaginatedUseCase(repository);
  return useQuery({
    queryKey: [...QUERY_KEY, 'paginated', params],
    queryFn: () => useCase.execute(params).then((result) => {
      if ('left' in result) throw new Error(result.left.message);
      return {
        items: result.right.items,
        total: result.right.total,
        hasMore: result.right.offset + result.right.items.length < result.right.total,
      };
    }),
  });
}

export function useProductById(id: string): UseQueryResult<ProductEntity, Error> {
  const repository = useProductRepository();
  const useCase = new GetProductByIdUseCase(repository);
  return useQuery({
    queryKey: [...QUERY_KEY, id],
    queryFn: () => useCase.execute(id).then((result) => {
      if ('left' in result) throw new Error(result.left.message);
      return result.right;
    }),
    enabled: !!id,
  });
}

export function useProductSearch(query: string): UseQueryResult<ProductEntity[], Error> {
  const repository = useProductRepository();
  const useCase = new SearchProductsUseCase(repository);
  return useQuery({
    queryKey: [...QUERY_KEY, 'search', query],
    queryFn: () => useCase.execute(query).then((result) => {
      if ('left' in result) throw new Error(result.left.message);
      return result.right;
    }),
    enabled: query.length > 0,
  });
}

export function useProductMutations() {
  const queryClient = useQueryClient();
  const repository = useProductRepository();

  const addMutation = useMutation({
    mutationFn: (entity: ProductEntity) => {
      const useCase = new AddProductUseCase(repository);
      return useCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });

  const updateMutation = useMutation({
    mutationFn: (entity: ProductEntity) => {
      const useCase = new UpdateProductUseCase(repository);
      return useCase.execute(entity).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => {
      const useCase = new DeleteProductUseCase(repository);
      return useCase.execute(id).then((result) => {
        if ('left' in result) throw new Error(result.left.message);
        return result.right;
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEY });
    },
  });

  return {
    add: addMutation,
    update: updateMutation,
    delete: deleteMutation,
  };
}
