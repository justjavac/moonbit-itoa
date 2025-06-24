///| Comprehensive test cases for the itoa library
test "test_basic_formatting" {
  let buffer = Buffer::new()

  // Test basic positive numbers
  inspect(buffer.format_i32(0), content="0")
  inspect(buffer.format_i32(1), content="1")
  inspect(buffer.format_i32(42), content="42")
  inspect(buffer.format_i32(123), content="123")
  inspect(buffer.format_i32(9999), content="9999")

  // Test basic unsigned numbers
  inspect(buffer.format_u32(0U), content="0")
  inspect(buffer.format_u32(1U), content="1")
  inspect(buffer.format_u32(42U), content="42")
  inspect(buffer.format_u32(123U), content="123")
  inspect(buffer.format_u32(9999U), content="9999")
}

///|
test "test_negative_numbers" {
  let buffer = Buffer::new()

  // Test negative numbers
  inspect(buffer.format_i32(-1), content="-1")
  inspect(buffer.format_i32(-42), content="-42")
  inspect(buffer.format_i32(-123), content="-123")
  inspect(buffer.format_i32(-9999), content="-9999")

  // Test negative Int64
  inspect(buffer.format_i64(-1L), content="-1")
  inspect(buffer.format_i64(-12345L), content="-12345")
}

///|
test "test_boundary_values_i32" {
  let buffer = Buffer::new()

  // Test Int32 boundary values
  inspect(buffer.format_i32(2147483647), content="2147483647") // Int32.MAX
  inspect(buffer.format_i32(-2147483648), content="-2147483648") // Int32.MIN

  // Test powers of 10
  inspect(buffer.format_i32(10), content="10")
  inspect(buffer.format_i32(100), content="100")
  inspect(buffer.format_i32(1000), content="1000")
  inspect(buffer.format_i32(10000), content="10000")
  inspect(buffer.format_i32(100000), content="100000")
  inspect(buffer.format_i32(1000000), content="1000000")
}

///|
test "test_boundary_values_u32" {
  let buffer = Buffer::new()

  // Test UInt32 boundary values
  inspect(buffer.format_u32(4294967295U), content="4294967295") // UInt32.MAX

  // Test powers of 10
  inspect(buffer.format_u32(10U), content="10")
  inspect(buffer.format_u32(100U), content="100")
  inspect(buffer.format_u32(1000U), content="1000")
  inspect(buffer.format_u32(10000U), content="10000")
  inspect(buffer.format_u32(100000U), content="100000")
  inspect(buffer.format_u32(1000000U), content="1000000")
}

///|
test "test_boundary_values_i64" {
  let buffer = Buffer::new()

  // Test Int64 boundary values
  inspect(
    buffer.format_i64(9223372036854775807L),
    content="9223372036854775807",
  ) // Int64.MAX
  inspect(
    buffer.format_i64(-9223372036854775808L),
    content="-9223372036854775808",
  ) // Int64.MIN

  // Test large numbers
  inspect(
    buffer.format_i64(1234567890123456789L),
    content="1234567890123456789",
  )
  inspect(
    buffer.format_i64(-1234567890123456789L),
    content="-1234567890123456789",
  )
}

///|
test "test_boundary_values_u64" {
  let buffer = Buffer::new()

  // Test UInt64 boundary values
  inspect(
    buffer.format_u64(18446744073709551615UL),
    content="18446744073709551615",
  ) // UInt64.MAX

  // Test large numbers
  inspect(
    buffer.format_u64(1234567890123456789UL),
    content="1234567890123456789",
  )
  inspect(
    buffer.format_u64(9876543210987654321UL),
    content="9876543210987654321",
  )
}

///|
test "test_special_patterns" {
  let buffer = Buffer::new()

  // Test numbers that trigger different code paths
  inspect(buffer.format_i32(9), content="9") // Single digit
  inspect(buffer.format_i32(99), content="99") // Two digits
  inspect(buffer.format_i32(999), content="999") // Three digits
  inspect(buffer.format_i32(9999), content="9999") // Four digits
  inspect(buffer.format_i32(99999), content="99999") // Five digits

  // Test numbers around 10000 (triggers 4-digit grouping)
  inspect(buffer.format_i32(9999), content="9999")
  inspect(buffer.format_i32(10000), content="10000")
  inspect(buffer.format_i32(10001), content="10001")

  // Test numbers around 100 (triggers 2-digit grouping)
  inspect(buffer.format_i32(99), content="99")
  inspect(buffer.format_i32(100), content="100")
  inspect(buffer.format_i32(101), content="101")
}

///|
test "test_performance_critical_numbers" {
  let buffer = Buffer::new()

  // Test numbers that exercise different algorithm paths
  inspect(buffer.format_u64(1UL), content="1")
  inspect(buffer.format_u64(12UL), content="12")
  inspect(buffer.format_u64(123UL), content="123")
  inspect(buffer.format_u64(1234UL), content="1234")
  inspect(buffer.format_u64(12345UL), content="12345")
  inspect(buffer.format_u64(123456UL), content="123456")
  inspect(buffer.format_u64(1234567UL), content="1234567")
  inspect(buffer.format_u64(12345678UL), content="12345678")
  inspect(buffer.format_u64(123456789UL), content="123456789")
  inspect(buffer.format_u64(1234567890UL), content="1234567890")
}

///|
test "test_alternating_patterns" {
  let buffer = Buffer::new()

  // Test numbers with alternating digits
  inspect(buffer.format_i32(1010), content="1010")
  inspect(buffer.format_i32(2020), content="2020")
  inspect(buffer.format_i32(12121212), content="12121212")

  // Test repeating digits
  inspect(buffer.format_i32(1111), content="1111")
  inspect(buffer.format_i32(2222), content="2222")
  inspect(buffer.format_i32(9999), content="9999")

  // Test sequential patterns
  inspect(buffer.format_i32(1234), content="1234")
  inspect(buffer.format_i32(4321), content="4321")
  inspect(buffer.format_i32(123456789), content="123456789")
}

///|
test "test_edge_cases_around_powers_of_10" {
  let buffer = Buffer::new()

  // Test numbers just before and after powers of 10
  inspect(buffer.format_u64(9UL), content="9")
  inspect(buffer.format_u64(10UL), content="10")
  inspect(buffer.format_u64(11UL), content="11")
  inspect(buffer.format_u64(99UL), content="99")
  inspect(buffer.format_u64(100UL), content="100")
  inspect(buffer.format_u64(101UL), content="101")
  inspect(buffer.format_u64(999UL), content="999")
  inspect(buffer.format_u64(1000UL), content="1000")
  inspect(buffer.format_u64(1001UL), content="1001")
  inspect(buffer.format_u64(9999UL), content="9999")
  inspect(buffer.format_u64(10000UL), content="10000")
  inspect(buffer.format_u64(10001UL), content="10001")
}

///|
test "test_negative_edge_cases" {
  let buffer = Buffer::new()

  // Test negative numbers around powers of 10
  inspect(buffer.format_i32(-9), content="-9")
  inspect(buffer.format_i32(-10), content="-10")
  inspect(buffer.format_i32(-11), content="-11")
  inspect(buffer.format_i32(-99), content="-99")
  inspect(buffer.format_i32(-100), content="-100")
  inspect(buffer.format_i32(-101), content="-101")
  inspect(buffer.format_i32(-999), content="-999")
  inspect(buffer.format_i32(-1000), content="-1000")
  inspect(buffer.format_i32(-1001), content="-1001")
  inspect(buffer.format_i32(-9999), content="-9999")
  inspect(buffer.format_i32(-10000), content="-10000")
  inspect(buffer.format_i32(-10001), content="-10001")
}

///|
test "test_buffer_reuse" {
  // Test that the same buffer can be used multiple times
  let buffer = Buffer::new()

  // Multiple calls should work fine
  let result1 = buffer.format_i32(123)
  let result2 = buffer.format_i32(456)
  let result3 = buffer.format_u64(789UL)
  inspect(result1, content="123")
  inspect(result2, content="456")
  inspect(result3, content="789")
}

///|
test "test_all_single_digits" {
  let buffer = Buffer::new()

  // Test all single digits
  inspect(buffer.format_i32(0), content="0")
  inspect(buffer.format_i32(1), content="1")
  inspect(buffer.format_i32(2), content="2")
  inspect(buffer.format_i32(3), content="3")
  inspect(buffer.format_i32(4), content="4")
  inspect(buffer.format_i32(5), content="5")
  inspect(buffer.format_i32(6), content="6")
  inspect(buffer.format_i32(7), content="7")
  inspect(buffer.format_i32(8), content="8")
  inspect(buffer.format_i32(9), content="9")
}

///|
test "test_random_numbers" {
  let buffer = Buffer::new()

  // Test some "random" numbers to catch edge cases
  inspect(buffer.format_i32(42), content="42")
  inspect(buffer.format_i32(137), content="137")
  inspect(buffer.format_i32(256), content="256")
  inspect(buffer.format_i32(512), content="512")
  inspect(buffer.format_i32(1024), content="1024")
  inspect(buffer.format_i32(2048), content="2048")
  inspect(buffer.format_i32(4096), content="4096")
  inspect(buffer.format_i32(8192), content="8192")
  inspect(buffer.format_i32(16384), content="16384")
  inspect(buffer.format_i32(32768), content="32768")
  inspect(buffer.format_i32(65536), content="65536")
  inspect(buffer.format_i32(131072), content="131072")
  inspect(buffer.format_i32(262144), content="262144")
  inspect(buffer.format_i32(524288), content="524288")
  inspect(buffer.format_i32(1048576), content="1048576")
  inspect(buffer.format_i32(2097152), content="2097152")
  inspect(buffer.format_i32(4194304), content="4194304")
  inspect(buffer.format_i32(8388608), content="8388608")
  inspect(buffer.format_i32(16777216), content="16777216")
}
