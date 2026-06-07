// This file is port from https://github.com/dtolnay/itoa/blob/1ca7e009a324b9ef35c0d519a87ca90d5b6597fe/src/lib.rs
// Copyright Apache-2.0 dtolnay. All rights reserved.

///|
/// Reusable scratch space for formatting integers as decimal strings.
///
/// A `Buffer` keeps an internal byte array large enough for every supported
/// integer type, so repeated formatting calls can reuse the same working
/// memory instead of allocating a fresh temporary buffer each time.
///
/// # Example
/// ```mbt check
/// test "buffer can be reused" {
///   let buffer = Buffer::new()
///   inspect(buffer.format_i32(-42), content="-42")
///   inspect(buffer.format_u64(9000UL), content="9000")
/// }
/// ```
pub struct Buffer {
  bytes : FixedArray[Byte]
}

///|
/// Create a reusable decimal formatting buffer.
///
/// The returned buffer is large enough for every integer type supported by
/// this package, including `UInt64` and the negative boundary of `Int64`.
///
/// # Example
/// ```mbt check
/// test "create buffer" {
///   let buffer = Buffer::new()
///   inspect(buffer.format_u32(7U), content="7")
/// }
/// ```
pub fn Buffer::new() -> Buffer {
  { bytes: FixedArray::make(20, b'\x00') }
}

///|
/// Format an `Int` as a base-10 string.
///
/// The conversion writes digits into the buffer's reusable scratch space and
/// returns a freshly allocated `String` containing the final decimal text.
///
/// # Example
/// ```mbt check
/// test "format signed 32-bit value" {
///   let buffer = Buffer::new()
///   inspect(buffer.format_i32(-2147483648), content="-2147483648")
/// }
/// ```
pub fn Buffer::format_i32(self : Buffer, i : Int) -> String {
  let result = write_i32(i, self.bytes)
  bytes_to_string(result)
}

///|
/// Format a `UInt` as a base-10 string.
///
/// This method is optimized for unsigned 32-bit values and avoids any sign
/// handling while still reusing the same internal working buffer.
///
/// # Example
/// ```mbt check
/// test "format unsigned 32-bit value" {
///   let buffer = Buffer::new()
///   inspect(buffer.format_u32(4294967295U), content="4294967295")
/// }
/// ```
pub fn Buffer::format_u32(self : Buffer, i : UInt) -> String {
  let result = write_u32(i, self.bytes)
  bytes_to_string(result)
}

///|
/// Format an `Int64` as a base-10 string.
///
/// Negative values are handled by emitting the sign separately and then using
/// the fast digit-pair algorithm for the remaining absolute value.
///
/// # Example
/// ```mbt check
/// test "format signed 64-bit value" {
///   let buffer = Buffer::new()
///   inspect(
///     buffer.format_i64(-1234567890123456789L),
///     content="-1234567890123456789",
///   )
/// }
/// ```
pub fn Buffer::format_i64(self : Buffer, i : Int64) -> String {
  let result = write_i64(i, self.bytes)
  bytes_to_string(result)
}

///|
/// Format a `UInt64` as a base-10 string.
///
/// This is the widest integer conversion supported by the package and can
/// render values all the way up to `18446744073709551615`.
///
/// # Example
/// ```mbt check
/// test "format unsigned 64-bit value" {
///   let buffer = Buffer::new()
///   inspect(
///     buffer.format_u64(18446744073709551615UL),
///     content="18446744073709551615",
///   )
/// }
/// ```
pub fn Buffer::format_u64(self : Buffer, i : UInt64) -> String {
  let result = write_u64(i, self.bytes)
  bytes_to_string(result)
}

///|
/// Convert ASCII digit bytes into a `String`.
fn bytes_to_string(bytes : Array[Byte]) -> String {
  let chars = Array::make(bytes.length(), '\u0000')
  for i in 0..<bytes.length() {
    chars[i] = match bytes[i].to_int().to_char() {
      Some(c) => c
      None => '\u0000'
    }
  }
  String::from_array(chars)
}

///|
/// Lookup table for decimal digits (00, 01, 02, ..., 99)
let dec_digits_lut : FixedArray[Byte] = [
  b'0', b'0', b'0', b'1', b'0', b'2', b'0', b'3', b'0', b'4', b'0', b'5', b'0', b'6',
  b'0', b'7', b'0', b'8', b'0', b'9', b'1', b'0', b'1', b'1', b'1', b'2', b'1', b'3',
  b'1', b'4', b'1', b'5', b'1', b'6', b'1', b'7', b'1', b'8', b'1', b'9', b'2', b'0',
  b'2', b'1', b'2', b'2', b'2', b'3', b'2', b'4', b'2', b'5', b'2', b'6', b'2', b'7',
  b'2', b'8', b'2', b'9', b'3', b'0', b'3', b'1', b'3', b'2', b'3', b'3', b'3', b'4',
  b'3', b'5', b'3', b'6', b'3', b'7', b'3', b'8', b'3', b'9', b'4', b'0', b'4', b'1',
  b'4', b'2', b'4', b'3', b'4', b'4', b'4', b'5', b'4', b'6', b'4', b'7', b'4', b'8',
  b'4', b'9', b'5', b'0', b'5', b'1', b'5', b'2', b'5', b'3', b'5', b'4', b'5', b'5',
  b'5', b'6', b'5', b'7', b'5', b'8', b'5', b'9', b'6', b'0', b'6', b'1', b'6', b'2',
  b'6', b'3', b'6', b'4', b'6', b'5', b'6', b'6', b'6', b'7', b'6', b'8', b'6', b'9',
  b'7', b'0', b'7', b'1', b'7', b'2', b'7', b'3', b'7', b'4', b'7', b'5', b'7', b'6',
  b'7', b'7', b'7', b'8', b'7', b'9', b'8', b'0', b'8', b'1', b'8', b'2', b'8', b'3',
  b'8', b'4', b'8', b'5', b'8', b'6', b'8', b'7', b'8', b'8', b'8', b'9', b'9', b'0',
  b'9', b'1', b'9', b'2', b'9', b'3', b'9', b'4', b'9', b'5', b'9', b'6', b'9', b'7',
  b'9', b'8', b'9', b'9',
]

///|
/// Encode a signed 32-bit integer into the tail of `buf`.
fn write_i32(value : Int, buf : FixedArray[Byte]) -> Array[Byte] {
  let is_nonnegative = value >= 0
  let mut n = if is_nonnegative {
    value.reinterpret_as_uint()
  } else {
    (-value).reinterpret_as_uint()
  }
  let mut curr = buf.length()

  // Render 4 digits at a time
  while n >= 10000U {
    let rem = n % 10000U
    n = n / 10000U
    let d1 = (rem / 100U * 2U).reinterpret_as_int()
    let d2 = (rem % 100U * 2U).reinterpret_as_int()
    curr = curr - 4
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
    buf[curr + 2] = dec_digits_lut[d2]
    buf[curr + 3] = dec_digits_lut[d2 + 1]
  }

  // Render 2 more digits, if >2 digits
  if n >= 100U {
    let d1 = (n % 100U * 2U).reinterpret_as_int()
    n = n / 100U
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }

  // Render last 1 or 2 digits
  if n < 10U {
    curr = curr - 1
    buf[curr] = (n.reinterpret_as_int() + b'0'.to_int()).to_byte()
  } else {
    let d1 = (n * 2U).reinterpret_as_int()
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }
  if !is_nonnegative {
    curr = curr - 1
    buf[curr] = b'-'
  }
  let len = buf.length() - curr
  let result = Array::make(len, b'\x00')
  for i in 0..<len {
    result[i] = buf[curr + i]
  }
  result
}

///|
/// Encode an unsigned 32-bit integer into the tail of `buf`.
fn write_u32(value : UInt, buf : FixedArray[Byte]) -> Array[Byte] {
  let mut n = value
  let mut curr = buf.length()

  // Render 4 digits at a time
  while n >= 10000U {
    let rem = n % 10000U
    n = n / 10000U
    let d1 = (rem / 100U * 2U).reinterpret_as_int()
    let d2 = (rem % 100U * 2U).reinterpret_as_int()
    curr = curr - 4
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
    buf[curr + 2] = dec_digits_lut[d2]
    buf[curr + 3] = dec_digits_lut[d2 + 1]
  }

  // Render 2 more digits, if >2 digits
  if n >= 100U {
    let d1 = (n % 100U * 2U).reinterpret_as_int()
    n = n / 100U
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }

  // Render last 1 or 2 digits
  if n < 10U {
    curr = curr - 1
    buf[curr] = (n.reinterpret_as_int() + b'0'.to_int()).to_byte()
  } else {
    let d1 = (n * 2U).reinterpret_as_int()
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }
  let len = buf.length() - curr
  let result = Array::make(len, b'\x00')
  for i in 0..<len {
    result[i] = buf[curr + i]
  }
  result
}

///|
/// Encode a signed 64-bit integer into the tail of `buf`.
fn write_i64(value : Int64, buf : FixedArray[Byte]) -> Array[Byte] {
  let is_nonnegative = value >= 0L
  let mut n = if is_nonnegative {
    value.reinterpret_as_uint64()
  } else {
    (-value).reinterpret_as_uint64()
  }
  let mut curr = buf.length()

  // Render 4 digits at a time
  while n >= 10000UL {
    let rem = n % 10000UL
    n = n / 10000UL
    let d1 = (rem / 100UL * 2UL).to_int()
    let d2 = (rem % 100UL * 2UL).to_int()
    curr = curr - 4
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
    buf[curr + 2] = dec_digits_lut[d2]
    buf[curr + 3] = dec_digits_lut[d2 + 1]
  }

  // Render 2 more digits, if >2 digits
  if n >= 100UL {
    let d1 = (n % 100UL * 2UL).to_int()
    n = n / 100UL
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }

  // Render last 1 or 2 digits
  if n < 10UL {
    curr = curr - 1
    buf[curr] = (n.to_int() + b'0'.to_int()).to_byte()
  } else {
    let d1 = (n * 2UL).to_int()
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }
  if !is_nonnegative {
    curr = curr - 1
    buf[curr] = b'-'
  }
  let len = buf.length() - curr
  let result = Array::make(len, b'\x00')
  for i in 0..<len {
    result[i] = buf[curr + i]
  }
  result
}

///|
/// Encode an unsigned 64-bit integer into the tail of `buf`.
fn write_u64(value : UInt64, buf : FixedArray[Byte]) -> Array[Byte] {
  let mut n = value
  let mut curr = buf.length()

  // Render 4 digits at a time
  while n >= 10000UL {
    let rem = n % 10000UL
    n = n / 10000UL
    let d1 = (rem / 100UL * 2UL).to_int()
    let d2 = (rem % 100UL * 2UL).to_int()
    curr = curr - 4
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
    buf[curr + 2] = dec_digits_lut[d2]
    buf[curr + 3] = dec_digits_lut[d2 + 1]
  }

  // Render 2 more digits, if >2 digits
  if n >= 100UL {
    let d1 = (n % 100UL * 2UL).to_int()
    n = n / 100UL
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }

  // Render last 1 or 2 digits
  if n < 10UL {
    curr = curr - 1
    buf[curr] = (n.to_int() + b'0'.to_int()).to_byte()
  } else {
    let d1 = (n * 2UL).to_int()
    curr = curr - 2
    buf[curr] = dec_digits_lut[d1]
    buf[curr + 1] = dec_digits_lut[d1 + 1]
  }
  let len = buf.length() - curr
  let result = Array::make(len, b'\x00')
  for i in 0..<len {
    result[i] = buf[curr + i]
  }
  result
}

///|
/// Additional test cases for edge conditions
test "test_zero_values" {
  let buffer = Buffer::new()
  inspect(buffer.format_i32(0), content="0")
  inspect(buffer.format_u32(0U), content="0")
  inspect(buffer.format_i64(0L), content="0")
  inspect(buffer.format_u64(0UL), content="0")
}

///|
test "test_small_numbers" {
  let buffer = Buffer::new()
  inspect(buffer.format_i32(1), content="1")
  inspect(buffer.format_i32(9), content="9")
  inspect(buffer.format_i32(10), content="10")
  inspect(buffer.format_i32(99), content="99")
  inspect(buffer.format_i32(100), content="100")
}

///|
test "test_negative_numbers_basic" {
  let buffer = Buffer::new()
  inspect(buffer.format_i32(-1), content="-1")
  inspect(buffer.format_i32(-10), content="-10")
  inspect(buffer.format_i32(-100), content="-100")
  inspect(buffer.format_i64(-1000L), content="-1000")
}

///|
test "test_large_numbers" {
  let buffer = Buffer::new()
  inspect(buffer.format_u32(4294967295U), content="4294967295") // UInt32.MAX
  inspect(buffer.format_i32(2147483647), content="2147483647") // Int32.MAX
  inspect(buffer.format_i32(-2147483648), content="-2147483648") // Int32.MIN
}

///|
test "test_powers_of_ten" {
  let buffer = Buffer::new()
  inspect(buffer.format_i32(1), content="1")
  inspect(buffer.format_i32(10), content="10")
  inspect(buffer.format_i32(100), content="100")
  inspect(buffer.format_i32(1000), content="1000")
  inspect(buffer.format_i32(10000), content="10000")
  inspect(buffer.format_i32(100000), content="100000")
  inspect(buffer.format_i32(1000000), content="1000000")
}
