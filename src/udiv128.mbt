// This file is port from https://github.com/dtolnay/itoa/blob/1ca7e009a324b9ef35c0d519a87ca90d5b6597fe/src/udiv128.rs
// Copyright Apache-2.0 dtolnay. All rights reserved.

///|
/// Divide `n` by `10^19` and return the quotient and remainder.
///
/// This helper is useful when splitting a very large decimal value into a high
/// chunk and a low 19-digit remainder.
///
/// # Example
/// ```mbt check
/// test "split by 1e19" {
///   let (quot, rem) = udivmod_1e19(18446744073709551615UL)
///   inspect(quot, content="1")
///   inspect(rem, content="8446744073709551615")
/// }
/// ```
pub fn udivmod_1e19(n : UInt64) -> (UInt64, UInt64) {
  let d = 10000000000000000000UL // 10^19
  let quot = n / d
  let rem = n % d
  (quot, rem)
}
