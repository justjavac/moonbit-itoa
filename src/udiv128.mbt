///| Multiply unsigned 64 bit integers, return upper 64 bits of the result
fn u64_mulhi(x : UInt64, y : UInt64) -> UInt64 {
  let x_lo = x & 0xFFFFFFFFUL
  let x_hi = x >> 32
  let y_lo = y & 0xFFFFFFFFUL
  let y_hi = y >> 32

  // handle possibility of overflow
  let carry = (x_lo * y_lo) >> 32
  let m = x_lo * y_hi + carry
  let high1 = m >> 32
  let m_lo = m & 0xFFFFFFFFUL
  let high2 = (x_hi * y_lo + m_lo) >> 32
  x_hi * y_hi + high1 + high2
}

///| Divide `n` by 1e19 and return quotient and remainder
///
/// Integer division algorithm is based on the following paper:
///
///   T. Granlund and P. Montgomery, "Division by Invariant Integers Using Multiplication"
///   in Proc. of the SIGPLAN94 Conference on Programming Language Design and
///   Implementation, 1994, pp. 61–72
///
pub fn udivmod_1e19(n : UInt64) -> (UInt64, UInt64) {
  let d = 10000000000000000000UL // 10^19
  let quot = if n < 1UL << 51 {
    (n >> 19) / (d >> 19)
  } else {
    // Use a smaller multiplier that fits in UInt64
    // This is an approximation of the original algorithm
    let multiplier = 1844674407370955161UL // approximation for division by 1e19
    u64_mulhi(n, multiplier) >> 26
  }
  let rem = n - quot * d
  (quot, rem)
}
