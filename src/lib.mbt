// This file is port from https://github.com/dtolnay/itoa/blob/1ca7e009a324b9ef35c0d519a87ca90d5b6597fe/src/lib.rs
// Copyright Apache-2.0 dtolnay. All rights reserved.

/// Fast conversion of integer primitives to decimal strings.
/// 
/// This implementation provides efficient integer-to-string conversion
/// without going through formatting overhead.
///
/// # Example
///
/// ```moonbit
/// let buffer = Buffer::new()
/// let printed = buffer.format_u64(128UL)
/// inspect(printed, content="128")
/// ```

///| A correctly sized stack allocation for the formatted integer to be written into.
pub struct Buffer {
  bytes : FixedArray[Byte]
}

///| Create a new buffer for integer formatting.
/// This is a cheap operation; you don't need to worry about reusing buffers for efficiency.
pub fn Buffer::new() -> Buffer {
  { bytes: FixedArray::make(40, b'\x00') } // Max size for i128 is 40 chars
}

///| Print an Int into this buffer and return a string representation.
pub fn Buffer::format_i32(self : Buffer, i : Int) -> String {
  let _ = self // Use self parameter
  let buf = FixedArray::make(11, b'\x00') // i32 max length is 11
  let result = write_i32(i, buf)
  bytes_to_string(result)
}

///| Print a UInt into this buffer and return a string representation.
pub fn Buffer::format_u32(self : Buffer, i : UInt) -> String {
  let _ = self // Use self parameter
  let buf = FixedArray::make(10, b'\x00') // u32 max length is 10
  let result = write_u32(i, buf)
  bytes_to_string(result)
}

///| Print an Int64 into this buffer and return a string representation.
pub fn Buffer::format_i64(self : Buffer, i : Int64) -> String {
  let _ = self // Use self parameter
  let buf = FixedArray::make(20, b'\x00') // i64 max length is 20
  let result = write_i64(i, buf)
  bytes_to_string(result)
}

///| Print a UInt64 into this buffer and return a string representation.
pub fn Buffer::format_u64(self : Buffer, i : UInt64) -> String {
  let _ = self // Use self parameter
  let buf = FixedArray::make(20, b'\x00') // u64 max length is 20
  let result = write_u64(i, buf)
  bytes_to_string(result)
}

///| Convert byte array to string
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

///| Lookup table for decimal digits (00, 01, 02, ..., 99)
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

///| Write an Int32 to the buffer and return the byte array slice
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
  if not(is_nonnegative) {
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

///| Write a UInt32 to the buffer and return the byte array slice
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

///| Write an Int64 to the buffer and return the byte array slice
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
  if not(is_nonnegative) {
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

///| Write a UInt64 to the buffer and return the byte array slice
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

///| Additional test cases for edge conditions
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
