/// React Context for repository dependency injection.
/// Allows overriding repositories in tests or with real implementations.
import { createContext, useContext, type ReactNode } from 'react';

export interface RepositoryContextValue<T> {
  repository: T;
}

export function createRepositoryContext<T>() {
  const Context = createContext<RepositoryContextValue<T> | null>(null);

  function Provider({
    children,
    repository,
  }: RepositoryContextValue<T> & { children: ReactNode }) {
    return <Context.Provider value={{ repository }}>{children}</Context.Provider>;
  }

  function useRepository(): T {
    const context = useContext(Context);
    if (!context) {
      throw new Error('useRepository must be used within a RepositoryProvider');
    }
    return context.repository;
  }

  return { Provider, useRepository };
}
