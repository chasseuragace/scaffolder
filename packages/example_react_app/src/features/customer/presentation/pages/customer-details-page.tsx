/// Details page for Customer.
import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useCustomerById, useCustomerMutations } from '../hooks/customer.hooks';
import { ErrorView } from '../../../../core/components/error-view';
import { ConfirmationDialog } from '../../../../core/components/confirmation-dialog';
import { CustomerFormDialog } from '../components/customer-form-dialog';

export function CustomerDetailsPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, isLoading, error, refetch } = useCustomerById(id ?? '');

  const [successMessage, setSuccessMessage] = React.useState<string | null>(null);
  React.useEffect(() => {
    if (!successMessage) return;
    const t = setTimeout(() => setSuccessMessage(null), 3000);
    return () => clearTimeout(t);
  }, [successMessage]);
  const { update, delete: deleteMutation } = useCustomerMutations({ onSuccess: setSuccessMessage });

  const [isFormOpen, setIsFormOpen] = React.useState(false);

  /// Confirmation dialog state — no browser confirm().
  const [isDeleteOpen, setIsDeleteOpen] = React.useState(false);
  const handleDeleteConfirm = () => {
    deleteMutation.mutate(id ?? '', {
      onSuccess: () => navigate('/customer'),
    });
    setIsDeleteOpen(false);
  };

  if (isLoading) {
    return <div className="flex justify-center p-8">Loading…</div>;
  }

  if (error) {
    return <ErrorView message={error.message} onRetry={() => refetch()} />;
  }

  if (!data) {
    return <div className="p-8 text-center">Customer not found</div>;
  }

  return (
    <div className="container mx-auto p-4">
      <div className="mb-4">
        <button
          onClick={() => navigate('/customer')}
          className="text-blue-500 hover:underline"
        >
          ← Back to list
        </button>
      </div>

      <div className="rounded border p-6">
        <h1 className="mb-4 text-2xl font-bold">{data.name ?? 'Unnamed Customer'}</h1>

        <dl className="space-y-2">
          <div>
            <dt className="inline font-semibold">ID: </dt>
            <dd className="inline">{data.id}</dd>
          </div>
          {data.description && (
            <div>
              <dt className="inline font-semibold">Description: </dt>
              <dd className="inline">{data.description}</dd>
            </div>
          )}
          {data.createdAt && (
            <div>
              <dt className="inline font-semibold">Created: </dt>
              <dd className="inline">{data.createdAt.toLocaleString()}</dd>
            </div>
          )}
          {data.updatedAt && (
            <div>
              <dt className="inline font-semibold">Updated: </dt>
              <dd className="inline">{data.updatedAt.toLocaleString()}</dd>
            </div>
          )}
        </dl>

        <div className="mt-6 space-x-2">
          <button
            onClick={() => setIsFormOpen(true)}
            className="rounded border px-4 py-2 hover:bg-gray-100"
          >
            Edit
          </button>
          <button
            onClick={() => setIsDeleteOpen(true)}
            className="rounded bg-red-500 px-4 py-2 text-white hover:bg-red-600"
          >
            Delete
          </button>
        </div>
      </div>

      {isFormOpen && (
        <CustomerFormDialog
          isOpen={isFormOpen}
          entity={data}
          onClose={() => setIsFormOpen(false)}
          onSave={(entity) => {
            update.mutate(entity);
            setIsFormOpen(false);
          }}
        />
      )}

      <ConfirmationDialog
        isOpen={isDeleteOpen}
        title="Delete Customer"
        message="Are you sure you want to delete this Customer? This action cannot be undone."
        confirmText="Delete"
        onConfirm={handleDeleteConfirm}
        onCancel={() => setIsDeleteOpen(false)}
      />

      {successMessage && (
        <div className="fixed bottom-4 right-4 rounded bg-green-500 px-4 py-2 text-white shadow-lg">
          {successMessage}
        </div>
      )}
    </div>
  );
}
