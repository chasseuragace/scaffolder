/// Generic pagination types used by repositories and notifiers.
///
/// Offset/limit shape — the most common REST convention and what the
/// openapi-generated dart-dio clients return when wrapping `?offset=&limit=`
/// query parameters. Cursor-based variants can be added alongside without
/// breaking this surface.
library;

class PaginationParams {
  const PaginationParams({required this.offset, required this.limit});
  final int offset;
  final int limit;

  PaginationParams nextPage() =>
      PaginationParams(offset: offset + limit, limit: limit);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationParams && other.offset == offset && other.limit == limit;

  @override
  int get hashCode => Object.hash(offset, limit);

  @override
  String toString() => 'PaginationParams(offset: $offset, limit: $limit)';
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.offset,
    required this.limit,
  });

  final List<T> items;
  final int total;
  final int offset;
  final int limit;

  /// True when more pages exist after the current one.
  bool get hasMore => offset + items.length < total;
}
