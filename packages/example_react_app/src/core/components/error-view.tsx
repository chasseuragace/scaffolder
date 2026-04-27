/// Error view component for displaying error states.

interface ErrorViewProps {
  message: string;
  onRetry?: () => void;
}

export function ErrorView({ message, onRetry }: ErrorViewProps) {
  return (
    <div className="flex flex-col items-center justify-center p-8 text-center">
      <div className="mb-4 text-6xl">⚠️</div>
      <h3 className="mb-2 text-lg font-semibold text-red-600">Error</h3>
      <p className="mb-4 text-gray-600">{message}</p>
      {onRetry && (
        <button
          onClick={onRetry}
          className="rounded bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
        >
          Retry
        </button>
      )}
    </div>
  );
}
