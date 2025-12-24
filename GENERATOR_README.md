# 🚀 Flutter Code Generator

A powerful, configurable Flutter code generator that creates clean, production-ready CRUD applications with modern architecture patterns.

## ✨ Features

### 🏗️ **Architecture Options**
- **Simple Mode**: Minimal files for basic CRUD operations
- **Clean Architecture**: Full layered architecture with Domain/Data/Presentation
- **Enterprise Ready**: All best practices with testing and advanced features

### 🎯 **Smart State Management**
- **Optimistic Updates**: Update UI immediately, revert on error
- **Retry Mechanisms**: Auto-retry failed operations
- **Inline Loading**: Better UX than blocking dialogs
- **Advanced Error Handling**: User-friendly error messages

### 📱 **Mobile-First UX**
- Shimmer loading states
- Toast notifications
- Offline support with caching
- Responsive design patterns

### 🧪 **Development Tools**
- Realistic mock data generation
- Unit test scaffolding
- Integration test setup
- Generic base classes

## 🚀 Quick Start

### Option 1: Interactive Template Selector (Recommended)
```bash
dart run tool/select_template.dart User
```

### Option 2: Direct Generation
```bash
# Simple CRUD
dart run tool/generate_feature.dart User --template templates/simple_crud.yaml

# Enterprise (Full featured)
dart run tool/generate_feature.dart User --template templates/enterprise.yaml

# Mobile Optimized
dart run tool/generate_feature.dart User --template templates/mobile_optimized.yaml

# Custom with feature flags
dart run tool/generate_feature.dart User --feature simple_mode=true --feature optimistic_updates=true
```

## 📋 Available Templates

### 🎯 **Simple CRUD** (`templates/simple_crud.yaml`)
Perfect for: MVPs, prototypes, simple apps
- Minimal file structure
- Basic CRUD operations
- Optimistic updates
- Mock data generation

**Generated files**: ~8 files
**Best for**: Getting started quickly

### 🏢 **Enterprise** (`templates/enterprise.yaml`)
Perfect for: Large applications, teams, production apps
- Full Clean Architecture
- Comprehensive error handling
- Offline support with sync
- Unit & integration tests
- All advanced features

**Generated files**: ~32 files
**Best for**: Production applications

### 📱 **Mobile Optimized** (`templates/mobile_optimized.yaml`)
Perfect for: Mobile-first applications
- Optimized for mobile UX
- Offline-first approach
- Retry mechanisms for poor connections
- Toast notifications
- Shimmer loading states

**Generated files**: ~25 files
**Best for**: Mobile applications

## ⚙️ Configuration Flags

### Architecture
- `simple_mode`: Generate minimal files only
- `clean_architecture`: Full Clean Architecture layers

### UI Features
- `pagination`: Add pagination support
- `forms`: Generate form dialogs
- `filters`: Add filtering capabilities
- `shimmer_loading`: Skeleton loading states

### State Management
- `optimistic_updates`: Update UI immediately, revert on error
- `offline_support`: Local caching and sync
- `stream_based`: Use streams instead of futures

### Error Handling & UX
- `advanced_error_handling`: User-friendly error messages
- `retry_mechanisms`: Auto-retry failed operations
- `inline_loading`: Show loading states inline instead of dialogs
- `toast_notifications`: Use toast instead of snackbars

### Development
- `mock_data_generation`: Generate realistic mock data
- `unit_tests`: Generate unit test scaffolding
- `json_serialization`: Add toJson/fromJson methods

## 🎨 Customization Examples

### Minimal Setup
```bash
dart run tool/generate_feature.dart Product \
  --feature simple_mode=true \
  --feature optimistic_updates=true \
  --feature mock_data_generation=true
```

### Mobile-First
```bash
dart run tool/generate_feature.dart Order \
  --feature inline_loading=true \
  --feature retry_mechanisms=true \
  --feature offline_support=true \
  --feature toast_notifications=true
```

### Enterprise Setup
```bash
dart run tool/generate_feature.dart Customer \
  --feature clean_architecture=true \
  --feature advanced_error_handling=true \
  --feature unit_tests=true \
  --feature pagination=true
```

## 📁 Generated Structure

### Simple Mode
```
lib/
├── data/models/
├── presentation/
│   ├── providers/
│   └── pages/
```

### Full Architecture
```
lib/
├── core/
│   ├── errors/
│   ├── usecases/
│   └── utils/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
├── presentation/
│   ├── providers/
│   ├── widgets/
│   └── pages/
└── di/
```

## 🔧 Advanced Usage

### Custom Template Creation
1. Copy `simpler_generator_folders.yaml`
2. Modify the `features` section
3. Add conditional logic using `{% if features.feature_name %}`
4. Use your custom template: `--template my_template.yaml`

### Feature Flag Syntax
```yaml
# In template files
{% if features.optimistic_updates %}
// Optimistic update code
{% else %}
// Regular update code
{% endif %}

{% if features.mock_data_generation %}
// Mock data generation code
{% endif %}
```

## 🚀 What's Generated

### State Management
- **Riverpod providers** with proper error handling
- **Optimistic updates** for better UX
- **Retry mechanisms** for failed operations
- **Loading states** with inline or dialog options

### Error Handling
- **User-friendly error messages** based on failure types
- **Retry logic** for network failures
- **Validation errors** with field-specific messages
- **Offline handling** with proper fallbacks

### UI Components
- **Responsive list pages** with pagination
- **Form dialogs** with validation
- **Search functionality** with debouncing
- **Loading states** (shimmer, inline, dialogs)
- **Empty states** with helpful messages

### Data Layer
- **Repository pattern** with local/remote data sources
- **Model classes** with JSON serialization
- **Mock data generation** for testing
- **Caching strategies** for offline support

## 🎯 Best Practices Included

1. **Separation of Concerns**: Clean Architecture principles
2. **Error Handling**: Comprehensive failure types and user messages
3. **Performance**: Optimistic updates, debouncing, caching
4. **UX**: Inline loading, toast notifications, retry mechanisms
5. **Testing**: Mock data, unit test scaffolding
6. **Maintainability**: Generic base classes, consistent patterns

## 🤝 Contributing

1. Add new features to the `features` section
2. Use conditional logic in templates
3. Test with different flag combinations
4. Update documentation

## 📝 License

MIT License - feel free to use in your projects!