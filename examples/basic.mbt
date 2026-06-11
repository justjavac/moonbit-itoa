fn main {
  let buffer = @itoa.Buffer::new()
  println(buffer.format_i32(-42))
  println(buffer.format_u64(123456789UL))
}
