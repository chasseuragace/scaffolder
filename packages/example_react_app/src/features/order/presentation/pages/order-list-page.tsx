/// List page for Order.
import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useOrderListInfinite, useOrderMutations } from '../hooks/order.hooks';
import { ErrorView } from '../../../../core/components/error-view';
import { EmptyView } from '../../../../core/components/empty-view';
import { ConfirmationDialog } from '../../../../core/components/confirmation-dialog';
import { ShimmerTileList } from '../../../../core/components/shimmer-tile';
import { OrderItemRow } from '../components/order-item-row';
import { OrderFormDialog } from '../components/order-form-dialog';

export function OrderListPage() {
  const navigate = useNavigate();

  const [successMessage, setSuccessMessage] = React.useState<string | null>(null);
  React.useEffect(() => {
    if (!successMessage) return;
    const t = setTimeout(() => setSuccessMessage(null), 3000);
    return () => clearTimeout(t);
  }, [successMessage]);
  const { add, delete: deleteMutation } = useOrderMutations({ onSuccess: setSuccessMessage });

  const { data: pages, isLoading, error, fetchNextPage, hasNextPage, isFetchingNextPage } = useOrderListInfinite();
  const data = pages?.pages.flatMap((p) => p.items) ?? [];
  const refetch = () => {};

  const [isFormOpen, setIsFormOpen] = React.useState(false);

  /// Confirmation dialog state — replaces browser confirm() which blocks the event loop.
  const [deleteTargetId, setDeleteTargetId] = React.useState<string | null>(null);
  const handleDeleteConfirm = () => {
    if (deleteTargetId) {
      deleteMutation.mutate(deleteTargetId);
      setDeleteTargetId(null);
    }
  };

  if (isLoading) {
    return <ShimmerTileList />;
  }

  if (error) {
    return <ErrorView message={error.message} onRetry={() => refetch()} />;
  }

  if (!data || data.length === 0) {
    return <EmptyView message="No Orders yet" />;
  }

  return (
    <div className="container mx-auto p-4">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-2xl font-bold">Orders</h1>
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
            Add Order
          </button>
        </div>
      </div>

      <div className="space-y-2">
        {data.map((item) => (
          <OrderItemRow
            key={item.id}
            item={item}
            onView={() => navigate(`/order/${item.id}`)}
            onDelete={() => setDeleteTargetId(item.id)}
          />
        ))}
      </div>

      {hasNextPage && (
        <div className="mt-4 flex justify-center">
          <button
            onClick={() => fetchNextPage()}
            disabled={isFetchingNextPage}
            className="rounded border px-6 py-2 hover:bg-gray-100 disabled:opacity-50"
          >
            {isFetchingNextPage ? 'Loading…' : 'Load more'}
          </button>
        </div>
      )}

      {isFormOpen && (
        <OrderFormDialog
          isOpen={isFormOpen}
          onClose={() => setIsFormOpen(false)}
          onSave={(entity) => {
            add.mutate(entity);
            setIsFormOpen(false);
          }}
        />
      )}

      <ConfirmationDialog
        isOpen={deleteTargetId !== null}
        title="Delete Order"
        message="Are you sure you want to delete this Order? This action cannot be undone."
        confirmText="Delete"
        onConfirm={handleDeleteConfirm}
        onCancel={() => setDeleteTargetId(null)}
      />

      {successMessage && (
        <div className="fixed bottom-4 right-4 rounded bg-green-500 px-4 py-2 text-white shadow-lg">
          {successMessage}
        </div>
      )}
    </div>
  );
}
