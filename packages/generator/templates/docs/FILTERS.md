# Filter Implementation Guide

This guide explains how to implement filters in the generated Flutter feature. The filter system is designed to be generic and domain-agnostic, allowing you to pass filter parameters as API query params.

## Overview

The generator provides a `filters` field in `PaginationParams` that accepts a `Map<String, dynamic>`. This allows you to pass any filter parameters your API requires. The template includes helper methods for serialization:

- `toQueryParams()`: Converts filters to URL query string format
- `toJson()`: Converts filters to JSON for request body
- `addFilter(key, value)`: Convenience method to add filters
- `removeFilter(key)`: Convenience method to remove filters

## Real-World Examples

### E-commerce

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'min_price': 10,
    'max_price': 100,
    'category': ['electronics', 'phones'],
    'min_rating': 4.0,
    'in_stock': true,
    'brand': 'apple',
  },
);
```

### Location-based Services

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'distance': '5km',
    'lat': 40.7128,
    'lng': -74.0060,
    'min_rating': 4.0,
    'open_now': true,
  },
);
```

### Admin Panels

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'status': 'pending',
    'created_after': '2024-01-01',
    'created_before': '2024-12-31',
    'region': 'us-east',
    'business_type': 'restaurant',
  },
);
```

### User Management

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'min_age': 18,
    'max_age': 65,
    'role': 'admin',
    'is_verified': true,
    'registered_after': '2024-01-01',
  },
);
```

### Content Management

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'status': 'published',
    'author': 'john_doe',
    'tags': ['technology', 'flutter'],
    'category': 'tutorials',
  },
);
```

## API Serialization Patterns

Different APIs expect different filter formats. Here are common patterns:

### 1. Simple Query Params

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'min_price': 10,
    'max_price': 100,
  },
);

final queryParams = params.toQueryParams();
// Result: offset=0&limit=20&min_price=10&max_price=100

final response = await http.get(Uri.parse('$apiUrl/products?$queryParams'));
```

### 2. Nested Format

```dart
// Some APIs expect nested filter objects
// You may need to customize toQueryParams() or implement custom serialization

final filters = {
  'price': {'min': 10, 'max': 100},
  'category': 'electronics',
};

// Result: filter[price][min]=10&filter[price][max]=100&filter[category]=electronics
```

### 3. Operator Suffix

```dart
// Use filter keys with operator suffixes
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'price__gte': 10,      // greater than or equal
    'price__lte': 100,     // less than or equal
    'price__gt': 10,       // greater than
    'price__lt': 100,      // less than
    'name__contains': 'iphone',
    'status__in': ['active', 'pending'],
  },
);
```

### 4. Array Values

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'category': ['electronics', 'phones', 'accessories'],
  },
);

final queryParams = params.toQueryParams();
// Result: offset=0&limit=20&category=electronics&category=phones&category=accessories
```

### 5. JSON Body (POST Request)

```dart
final params = PaginationParams(
  offset: 0,
  limit: 20,
  filters: {
    'price': {'min': 10, 'max': 100},
    'category': 'electronics',
  },
);

final response = await http.post(
  Uri.parse('$apiUrl/products/search'),
  body: jsonEncode(params.toJson()),
  headers: {'Content-Type': 'application/json'},
);
// Body: {"offset":0,"limit":20,"filters":{"price":{"min":10,"max":100},"category":"electronics"}}
```

## Common Filter Patterns

### Range Filters

```dart
// Price range
filters: {
  'min_price': 10,
  'max_price': 100,
}

// Date range
filters: {
  'start_date': '2024-01-01',
  'end_date': '2024-12-31',
}

// Age range
filters: {
  'min_age': 18,
  'max_age': 65,
}
```

### Array/IN Filters

```dart
// Multiple categories
filters: {
  'category': ['electronics', 'phones', 'accessories'],
}

// Multiple statuses
filters: {
  'status': ['active', 'pending', 'review'],
}
```

### Boolean Filters

```dart
filters: {
  'in_stock': true,
  'is_verified': true,
  'open_now': false,
}
```

## Implementing in Repository

The template provides a TODO comment in `repository_impl.dart.tmpl` with examples. Here's how to implement it:

```dart
@override
Future<Either<Failure, PaginatedResponse<{{Module}}Entity>>> getAllPaginated(
    PaginationParams params) async {
  try {
    // Option 1: Simple query params
    final queryParams = params.toQueryParams();
    final response = await http.get(Uri.parse('$apiUrl/{{module_snake}}?$queryParams'));
    
    // Option 2: JSON body
    final response = await http.post(
      Uri.parse('$apiUrl/{{module_snake}}/search'),
      body: jsonEncode(params.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    
    // Option 3: Custom serialization for nested format
    final customParams = _serializeFilters(params);
    final response = await http.get(Uri.parse('$apiUrl/{{module_snake}}?$customParams'));
    
    // Parse response and return PaginatedResponse
    final data = jsonDecode(response.body);
    return Right(PaginatedResponse<{{Module}}Entity>(
      items: (data['items'] as List).map((e) => {{Module}}Model.fromJson(e).toEntity()).toList(),
      total: data['total'] ?? 0,
      offset: params.offset,
      limit: params.limit,
    ));
  } catch (e) {
    return Left(failureFromError(e));
  }
}
```

## Testing with Fake Repository

The fake repository includes basic filter application for testing. You can extend it based on your specific entity fields:

```dart
// In repository_fake.dart.tmpl
if (params.filters != null && params.filters!.isNotEmpty) {
  filteredItems = filteredItems.where((item) {
    return params.filters!.entries.every((entry) {
      final key = entry.key;
      final value = entry.value;
      
      // Add your custom filter logic here
      switch (key) {
        case 'price':
          return item.price >= (value['min'] as num) && 
                 item.price <= (value['max'] as num);
        case 'category':
          return item.category == value;
        default:
          return true;
      }
    });
  }).toList();
}
```

## Best Practices

1. **Use descriptive filter keys**: `min_price` instead of `mp`
2. **Document your API format**: Clearly document which format your API expects
3. **Handle edge cases**: Null values, empty arrays, invalid data types
4. **Validate filters**: Validate filter values before sending to API
5. **Use type-safe values**: Ensure numeric values are numbers, not strings
6. **Test with fake repository**: Use the fake repository to test filter logic before API integration

## GraphQL

For GraphQL APIs, you'll typically pass filters in the query variables:

```dart
final query = '''
  query GetItems(\$offset: Int!, \$limit: Int!, \$filters: ItemFilters) {
    items(offset: \$offset, limit: \$limit, filters: \$filters) {
      items { id name }
      total
    }
  }
''';

final variables = {
  'offset': params.offset,
  'limit': params.limit,
  'filters': params.filters,
};

final response = await http.post(
  Uri.parse(graphqlUrl),
  body: jsonEncode({'query': query, 'variables': variables}),
  headers: {'Content-Type': 'application/json'},
);
```

## Summary

The filter system is designed to be:
- **Generic**: Works with any domain and API format
- **Flexible**: Supports simple and complex filter patterns
- **Minimal**: Provides basic infrastructure, you refine the implementation
- **Domain-agnostic**: No hardcoded fields in the template code

The project owner is responsible for:
- Implementing the actual API calls with proper filter serialization
- Extending the fake repository filter logic for testing
- Building custom filter UI components as needed
- Documenting the specific filter format their API expects
