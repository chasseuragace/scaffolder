/// List page for LoyaltyCard.
import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useLoyaltyCardList, useLoyaltyCardMutations } from '../hooks/loyalty-card.hooks';
import { ErrorView } from '../../../../core/components/error-view';
import { EmptyView } from '../../../../core/components/empty-view';
import { ConfirmationDialog } from '../../../../core/components/confirmation-dialog';
import { LoyaltyCardItemRow } from '../components/loyalty-card-item-row';
import { LoyaltyCardFormDialog } from '../components/loyalty-card-form-dialog';

export function LoyaltyCardListPage() {
  const navigate = useNavigate();

  const [successMessage, setSuccessMessage] = React.useState<string | null>(null);
  React.useEffect(() => {
    if (!successMessage) return;
    const t = setTimeout(() => setSuccessMessage(null), 3000);
    return () => clearTimeout(t);
  }, [successMessage]);
  const { add, delete: deleteMutation } = useLoyaltyCardMutations({ onSuccess: setSuccessMessage });

  const { data, isLoading, error, refetch } = useLoyaltyCardList();

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
    return <div className="flex justify-center p-8">Loading...</div>;
  }

  if (error) {
    return <ErrorView message={error.message} onRetry={() => refetch()} />;
  }

  if (!data || data.length === 0) {
    return <EmptyView message="No LoyaltyCards yet" />;
  }

  return (
    <div className="container mx-auto p-4">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-2xl font-bold">LoyaltyCards</h1>
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
            Add LoyaltyCard
          </button>
        </div>
      </div>

      <div className="space-y-2">
        {data.map((item) => (
          <LoyaltyCardItemRow
            key={item.id}
            item={item}
            onView={() => navigate(`/loyalty-card/${item.id}`)}
            onDelete={() => setDeleteTargetId(item.id)}
          />
        ))}
      </div>

      {isFormOpen && (
        <LoyaltyCardFormDialog
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
        title="Delete LoyaltyCard"
        message="Are you sure you want to delete this LoyaltyCard? This action cannot be undone."
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
