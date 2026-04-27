/// Search bar component for Product.
import { useState } from 'react';
import { useProductSearch } from '../hooks/product.hooks';
import type { ProductEntity } from '../../domain/entities/product.entity';
import { Debouncer } from '../../../../core/utils/debouncer';

interface ProductSearchBarProps {
  onSelect: (entity: ProductEntity) => void;
}

export function ProductSearchBar({ onSelect }: ProductSearchBarProps) {
  const [query, setQuery] = useState('');
  const { data, isLoading } = useProductSearch(query);
  const [isOpen, setIsOpen] = useState(false);
  const debouncer = new Debouncer(300);

  const handleQueryChange = (value: string) => {
    setQuery(value);
    debouncer.debounce(() => {
      setIsOpen(value.length > 0);
    });
  };

  const handleSelect = (entity: ProductEntity) => {
    onSelect(entity);
    setQuery('');
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <input
        type="text"
        value={query}
        onChange={(e) => handleQueryChange(e.target.value)}
        placeholder="Search Products..."
        className="w-full rounded border border-gray-300 px-4 py-2"
        onFocus={() => setIsOpen(query.length > 0)}
        onBlur={() => setTimeout(() => setIsOpen(false), 200)}
      />

      {isOpen && (
        <div className="absolute z-10 mt-1 w-full rounded border bg-white shadow-lg">
          {isLoading ? (
            <div className="p-4 text-center">Loading...</div>
          ) : data && data.length > 0 ? (
            <ul className="max-h-60 overflow-auto">
              {data.map((item) => (
                <li
                  key={item.id}
                  onClick={() => handleSelect(item)}
                  className="cursor-pointer px-4 py-2 hover:bg-gray-100"
                >
                  <div className="font-semibold">{item.name || 'Unnamed'}</div>
                  {item.description && (
                    <div className="text-sm text-gray-600">{item.description}</div>
                  )}
                </li>
              ))}
            </ul>
          ) : (
            <div className="p-4 text-center text-gray-500">No results found</div>
          )}
        </div>
      )}
    </div>
  );
}
