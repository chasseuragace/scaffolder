/// Simple debouncer utility.
/// NOTE: Do NOT instantiate inside a React component body — that creates
/// a new instance every render and defeats debouncing.
/// Use `useRef` to hold the instance, or prefer the `useDebounce` hook below.
export class Debouncer {
  private timeoutId: ReturnType<typeof setTimeout> | null = null;
  private readonly delay: number;

  constructor(delay = 300) {
    this.delay = delay;
  }

  debounce(callback: () => void): void {
    if (this.timeoutId !== null) clearTimeout(this.timeoutId);
    this.timeoutId = setTimeout(() => {
      callback();
      this.timeoutId = null;
    }, this.delay);
  }

  cancel(): void {
    if (this.timeoutId !== null) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
}

/// React-safe debounce hook. Wraps a callback so it only fires after
/// `delay` ms of inactivity. Safe to call on every render.
import { useRef, useCallback } from 'react';

export function useDebouncedCallback<T extends (...args: unknown[]) => void>(
  callback: T,
  delay = 300,
): T {
  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  return useCallback(
    ((...args) => {
      if (timeoutRef.current !== null) clearTimeout(timeoutRef.current);
      timeoutRef.current = setTimeout(() => callback(...args), delay);
    }) as T,
    [callback, delay],
  );
}
