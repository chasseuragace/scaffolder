# Design Document

## Overview

This design addresses critical bugs in the Flutter code generator system to ensure all generated code is error-free, passes static analysis, and functions correctly. The focus is on fixing the template engine, improving code quality, and ensuring feature flags work as intended.

## Architecture

### Current Issues Identified

1. **Feature Flag Override System**: Command-line overrides are recognized but not applied to template processing
2. **Provider Naming Bug**: Simple template uses hardcoded `moduleNameProvider` instead of dynamic names
3. **Mock Data Inconsistency**: Simple template has basic mock data while main template has enhanced version
4. **Template Engine Logic**: Conditional processing doesn't properly evaluate feature flags
5. **Static Analysis Issues**: Generated code may have unused imports, naming inconsistencies

### Solution Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Template      │    │   Feature Flag   │    │   Code          │
│   Validator     │───▶│   Processor      │───▶│   Generator     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Syntax        │    │   Conditional    │    │   Static        │
│   Checker       │    │   Logic Engine   │    │   Analysis      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Components and Interfaces

### 1. Template Validator

**Purpose**: Validate template syntax and feature flag references before processing

**Interface**:
```dart
class TemplateValidator {
  ValidationResult validate(YamlMap template);
  List<ValidationError> checkFeatureReferences(YamlMap template);
  bool validateConditionalSyntax(String templateContent);
}
```

**Key Functions**:
- Validate YAML syntax
- Check feature flag references exist
- Validate conditional template syntax
- Report clear error messages with line numbers

### 2. Feature Flag Processor

**Purpose**: Correctly merge and apply feature flags from multiple sources

**Interface**:
```dart
class FeatureFlagProcessor {
  Map<String, bool> processFlags(
    YamlMap templateDefaults,
    Map<String, bool> commandLineOverrides,
  );
  bool evaluateCondition(String condition, Map<String, bool> flags);
}
```

**Key Functions**:
- Merge template defaults with command-line overrides
- Apply precedence rules (CLI > template > defaults)
- Evaluate conditional expressions
- Handle flag conflicts gracefully

### 3. Enhanced Template Engine

**Purpose**: Process templates with correct feature flag evaluation

**Interface**:
```dart
class TemplateEngine {
  String processTemplate(
    String template,
    Map<String, String> replacements,
    Map<String, bool> featureFlags,
  );
  String evaluateConditionals(String content, Map<String, bool> flags);
}
```

**Key Functions**:
- Replace module name placeholders correctly
- Process conditional blocks based on feature flags
- Handle nested conditionals
- Maintain consistent naming conventions

### 4. Code Quality Validator

**Purpose**: Ensure generated code passes static analysis

**Interface**:
```dart
class CodeQualityValidator {
  Future<List<AnalysisError>> validateGeneratedCode(List<String> filePaths);
  bool checkImportUsage(String dartCode);
  bool validateNamingConventions(String dartCode);
}
```

**Key Functions**:
- Run dart analyze on generated files
- Check for unused imports
- Validate naming conventions
- Ensure null safety compliance

## Data Models

### Template Configuration
```dart
class TemplateConfig {
  final Map<String, bool> features;
  final List<GenerationRule> rules;
  final Map<String, String> replacements;
  
  TemplateConfig merge(TemplateConfig override);
  bool isFeatureEnabled(String featureName);
}
```

### Generation Context
```dart
class GenerationContext {
  final String moduleName;
  final String pascalCase;
  final String snakeCase;
  final Map<String, bool> activeFeatures;
  final String outputPath;
  
  String getProviderName() => '${snakeCase}Provider';
  String getNotifierName() => '${pascalCase}Notifier';
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do.*

### Property-Based Testing Overview

Property-based testing (PBT) validates software correctness by testing universal properties across many generated inputs. Each property is a formal specification that should hold for all valid inputs.

### Core Properties

**Property 1: Generated Code Compilation**
*For any* valid template configuration and module name, all generated Dart files should compile without errors when analyzed with `dart analyze`
**Validates: Requirements 1.1, 1.2**

**Property 2: Feature Flag Consistency**
*For any* feature flag setting, the generated code should include or exclude features consistently based on the flag value
**Validates: Requirements 2.1, 2.2, 2.3**

**Property 3: Naming Convention Consistency**
*For any* module name input, all generated provider names, class names, and file names should follow consistent naming conventions
**Validates: Requirements 1.5, 3.1, 3.2**

**Property 4: Template Conditional Logic**
*For any* conditional template block with feature flags, the block should be included if and only if the condition evaluates to true
**Validates: Requirements 2.5, 5.1**

**Property 5: Import Correctness**
*For any* generated Dart file that imports other files, all imports should be necessary and all referenced symbols should be available
**Validates: Requirements 1.3, 4.2**

**Property 6: Mock Data Uniqueness**
*For any* generated mock data list, each item should have unique identifiers and varied content
**Validates: Requirements 7.4, 7.1**

**Property 7: Static Analysis Compliance**
*For any* generated code, running `dart analyze` should return zero errors and zero warnings
**Validates: Requirements 4.1, 4.6**

**Property 8: Feature Flag Override Precedence**
*For any* feature flag that is set both in template defaults and command-line overrides, the command-line value should take precedence
**Validates: Requirements 2.3, 5.2**

## Error Handling

### Template Validation Errors
- **Syntax Errors**: Clear messages with line numbers for YAML syntax issues
- **Reference Errors**: Specific errors for undefined feature flag references
- **Logic Errors**: Validation of conditional template syntax

### Generation Errors
- **File System Errors**: Handle permission issues, disk space, path problems
- **Template Processing Errors**: Clear context when template processing fails
- **Feature Flag Conflicts**: Graceful handling of conflicting flag combinations

### Code Quality Errors
- **Static Analysis Failures**: Report specific analyzer errors with context
- **Import Issues**: Clear messages for missing or unused imports
- **Naming Convention Violations**: Specific guidance on naming fixes

## Testing Strategy

### Unit Testing
- Template validator with malformed YAML
- Feature flag processor with various override combinations
- Template engine with complex conditional logic
- Code quality validator with known problematic code

### Property-Based Testing
- Generate random module names and verify naming consistency
- Generate random feature flag combinations and verify code correctness
- Generate templates with various conditional blocks and verify evaluation
- Test static analysis compliance across generated code variations

### Integration Testing
- End-to-end generation with all templates
- Cross-template compatibility testing
- Command-line interface testing with various flag combinations
- Generated code compilation and execution testing

### Regression Testing
- Test cases for each identified bug
- Verification that fixes don't break existing functionality
- Performance testing to ensure fixes don't slow generation

## Implementation Plan

### Phase 1: Core Bug Fixes
1. Fix feature flag override system in generator script
2. Fix provider naming in simple template
3. Standardize mock data generation across templates
4. Add template validation before processing

### Phase 2: Static Analysis Integration
1. Add dart analyze validation to generation process
2. Fix import issues in generated code
3. Ensure naming convention compliance
4. Add code quality checks

### Phase 3: Enhanced Template Engine
1. Improve conditional logic processing
2. Add better error reporting
3. Implement template inheritance
4. Add cross-template validation

### Phase 4: Developer Experience
1. Improve error messages and context
2. Add progress reporting during generation
3. Enhance interactive template selector
4. Add template debugging tools

This design ensures the generator produces bug-free, production-ready code that passes all static analysis checks and functions correctly across all supported templates and feature combinations.