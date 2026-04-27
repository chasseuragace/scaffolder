/// List page for Product.
import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useProductList, useProductMutations } from '../hooks/product.hooks';
import { ErrorView } from '../../../../core/components/error-view';
import { EmptyView } from '../../../../core/components/empty-view';
import { ShimmerTileList } from '../../../../core/components/shimmer-tile';
import { ProductItemRow } from '../components/product-item-row';
import { ProductFormDialog } from '../components/product-form-dialog';

export function ProductListPage() {
  const navigate = useNavigate();
  const { data, isLoading, error, refetch } = useProductList();
  const { add, delete: deleteMutation } = useProductMutations();
  const [isFormOpen, setIsFormOpen] = React.useState(false);

  const handleDelete = (id: string) => {
    if (confirm('Are you sure you want to delete this Product?')) {
      deleteMutation.mutate(id);
    }
  };

  if (isLoading) {
    return <ShimmerTileList />;
  }

  if (error) {
    return <ErrorView message={error.message} onRetry={() => refetch()} />;
  }

  if (!data || data.length === 0) {
    return <EmptyView message="No Products yet" />;
  }

  return (
    <div className="container mx-auto p-4">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-2xl font-bold">Products</h1>
        <div className="space-x-2">
          <button
            onClick={() => refetch()}
            className="rounded border px-4 py-2 hover:bg-gray-100"
          >
            Refresh
          </button>
          <button
            onClick={() => setIsFormOpen(true)}
            className="rounded bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
          >
            Add Product
          </button>
        </div>
      </div>

      <div className="space-y-2">
        {data.map((item) => (
          <ProductItemRow
            key={item.id}
            item={item}
            onView={() => navigate(`/product/${item.id}`)}
            onDelete={() => handleDelete(item.id)}
          />
        ))}
      </div>

      {isFormOpen && (
        <ProductFormDialog
          isOpen={isFormOpen}
          onClose={() => setIsFormOpen(false)}
          onSave={(entity) => {
            add.mutate(entity);
            setIsFormOpen(false);
          }}
        />
      )}
    </div>
  );
}
