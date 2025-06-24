# MoonBit ITOA Library

Fast integer-to-string conversion library for MoonBit, inspired by Rust's `itoa`
crate.

## Features

- **High Performance**: Uses optimized algorithms for fast integer-to-string
  conversion
- **Multiple Types**: Supports Int32, UInt32, Int64, and UInt64
- **Zero Allocations**: Reusable buffer for efficient memory usage
- **Comprehensive**: Handles all edge cases including negative numbers and
  boundary values

## Installation

Add `justjavac/itoa` to your dependencies:

```bash
moon update
moon add justjavac/itoa
```

## Usage

### Basic Usage

```moonbit
let buffer = @itoa.Buffer::new()
let result = buffer.format_i32(12345)
println(result) // "12345"
```

### Different Integer Types

```moonbit
let buffer = @itoa.Buffer::new()

// 32-bit integers
let i32_result = buffer.format_i32(-123)      // "-123"
let u32_result = buffer.format_u32(456U)      // "456"

// 64-bit integers  
let i64_result = buffer.format_i64(-789L)     // "-789"
let u64_result = buffer.format_u64(12345UL)   // "12345"
```

### Buffer Reuse

The same buffer can be reused for multiple conversions:

```moonbit
let buffer = @itoa.Buffer::new()

// All these calls reuse the same buffer
let result1 = buffer.format_i32(100)
let result2 = buffer.format_u64(200UL) 
let result3 = buffer.format_i64(-300L)
```

## Performance

This library is optimized for speed:

- **4-digit groups**: Numbers are processed 4 digits at a time when possible
- **Lookup table**: Pre-computed digit pairs (00-99) for fast conversion
- **Minimal branching**: Code paths optimized for branch prediction
- **Direct buffer writing**: No string concatenation overhead

## Supported Range

- **Int32**: -2,147,483,648 to 2,147,483,647
- **UInt32**: 0 to 4,294,967,295
- **Int64**: -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807
- **UInt64**: 0 to 18,446,744,073,709,551,615

## Algorithm

The implementation uses the same high-performance algorithm as Rust's libcore:

1. **Large numbers**: Process 4 digits at a time using division by 10,000
2. **Medium numbers**: Process 2 digits at a time using division by 100
3. **Small numbers**: Handle 1-2 remaining digits directly
4. **Negative numbers**: Handle sign separately to avoid branching in hot path

## Testing

The library includes comprehensive test coverage:

- Basic functionality tests
- Boundary value tests
- Edge case tests
- Performance benchmark tests
- Pattern-specific tests

Run tests with:

```bash
moon test
```

## Examples

### Edge Cases

```moonbit
let buffer = @itoa.Buffer::new()

// Zero
buffer.format_i32(0)           // "0"

// Maximum values
buffer.format_i32(2147483647)  // "2147483647" (Int32.MAX)
buffer.format_u32(4294967295U) // "4294967295" (UInt32.MAX)

// Minimum values  
buffer.format_i32(-2147483648) // "-2147483648" (Int32.MIN)

// Large 64-bit numbers
buffer.format_u64(18446744073709551615UL) // "18446744073709551615" (UInt64.MAX)
```

### Performance Critical Patterns

```moonbit
let buffer = @itoa.Buffer::new()

// These patterns exercise different optimization paths:
buffer.format_i32(9)        // Single digit
buffer.format_i32(99)       // Two digits  
buffer.format_i32(999)      // Three digits
buffer.format_i32(9999)     // Four digits (triggers optimization)
buffer.format_i32(10000)    // Five digits (uses 4+1 digit algorithm)
```

## Implementation Details

The library consists of several key components:

- **Buffer**: Main interface struct that holds the working buffer
- **Lookup Table**: Pre-computed byte array of digit pairs (00-99)
- **Write Functions**: Type-specific formatting functions for each integer type
- **Helper Functions**: Utilities for byte-to-string conversion

The core algorithm processes numbers from right to left, building the decimal
representation in a buffer, then returns the relevant slice as a string.
