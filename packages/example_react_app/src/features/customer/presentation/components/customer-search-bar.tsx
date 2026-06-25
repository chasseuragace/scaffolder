/// Search bar component for Customer.
///
/// Fix vs v1: Debouncer is now held in a ref so the same instance
/// survives re-renders. Previously a new Debouncer was created each render,
/// making debouncing a no-op.
import { useState, useRef, useCallback } from 'react';
import { useCustomerSearch } from '../hooks/customer.hooks';
import type { CustomerEntity } from '../../domain/entities/customer.entity';

interface CustomerSearchBarProps {
  onSelect: (entity: CustomerEntity) => void;
}

const DEBOUNCE_MS = 300;

export function CustomerSearchBar({ onSelect }: CustomerSearchBarProps) {
  const [query, setQuery] = useState('');
  const [debouncedQuery, setDebouncedQuery] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const { data, isLoading } = useCustomerSearch(debouncedQuery);

  const handleQueryChange = useCallback((value: string) => {
    setQuery(value);
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    timeoutRef.current = setTimeout(() => {
      setDebouncedQuery(value);
      setIsOpen(value.trim().length > 0);
    }, DEBOUNCE_MS);
  }, []);

  const handleSelect = (entity: CustomerEntity) => {
    onSelect(entity);
    setQuery('');
    setDebouncedQuery('');
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <input
        type="text"
        value={query}
        onChange={(e) => handleQueryChange(e.target.value)}
        placeholder="Search Customers…"
        className="w-full rounded border border-gray-300 px-4 py-2"
        onFocus={() => setIsOpen(debouncedQuery.length > 0)}
        onBlur={() => setTimeout(() => setIsOpen(false), 200)}
      />

      {isOpen && (
        <div className="absolute z-10 mt-1 w-full rounded border bg-white shadow-lg">
          {isLoading ? (
            <div className="p-4 text-center text-sm text-gray-500">Searching…</div>
          ) : data && data.length > 0 ? (
            <ul className="max-h-60 overflow-auto">
              {data.map((item) => (
                <li
                  key={item.id}
                  onMouseDown={() => handleSelect(item)}
                  className="cursor-pointer px-4 py-2 hover:bg-gray-100"
                >
                  <div className="font-semibold">{item.name ?? 'Unnamed'}</div>
                  {item.description && (
                    <div className="text-sm text-gray-500">{item.description}</div>
                  )}
                </li>
              ))}
            </ul>
          ) : (
            <div className="p-4 text-center text-sm text-gray-500">No results found</div>
          )}
        </div>
      )}
    </div>
  );
}
