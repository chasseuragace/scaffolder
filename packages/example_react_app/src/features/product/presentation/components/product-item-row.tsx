/// Item row component for Product list.
import type { ProductEntity } from '../../domain/entities/product.entity';

interface ProductItemRowProps {
  item: ProductEntity;
  onView: () => void;
  onDelete: () => void;
}

export function ProductItemRow({ item, onView, onDelete }: ProductItemRowProps) {
  return (
    <div className="flex items-center justify-between rounded border p-4 hover:bg-gray-50">
      <div className="flex-1">
        <h3 className="font-semibold">{item.name || 'Unnamed Product'}</h3>
        {item.description && (
          <p className="text-sm text-gray-600">{item.description}</p>
        )}
      </div>
      <div className="space-x-2">
        <button
          onClick={onView}
          className="rounded border px-3 py-1 text-sm hover:bg-gray-100"
        >
          View
        </button>
        <button
          onClick={onDelete}
          className="rounded border border-red-500 px-3 py-1 text-sm text-red-500 hover:bg-red-50"
        >
          Delete
        </button>
      </div>
    </div>
  );
}
