/// Shimmer skeleton component for loading states.

export function ShimmerTile() {
  return (
    <div className="flex items-center space-x-4 rounded border p-4">
      <div className="h-12 w-12 animate-pulse rounded bg-gray-200" />
      <div className="flex-1 space-y-2">
        <div className="h-4 w-3/4 animate-pulse rounded bg-gray-200" />
        <div className="h-3 w-1/2 animate-pulse rounded bg-gray-200" />
      </div>
    </div>
  );
}

export function ShimmerTileList({ count = 5 }: { count?: number }) {
  return (
    <div className="space-y-2">
      {Array.from({ length: count }).map((_, i) => (
        <ShimmerTile key={i} />
      ))}
    </div>
  );
}
