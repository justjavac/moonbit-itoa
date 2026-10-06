# `justjavac/itoa`

[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-itoa/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-itoa)

Small and fast decimal formatting for `Int`, `UInt`, `Int64`, and `UInt64`.

## Install

```bash
moon add justjavac/itoa
```

## Quick Start

```mbt check
///|
test "format signed and unsigned values" {
  let buffer = @itoa.Buffer::new()
  inspect(buffer.format_i32(-42), content="-42")
  inspect(
    buffer.format_u64(18446744073709551615UL),
    content="18446744073709551615",
  )
}
```

## Reuse One Buffer

Create one `Buffer` and reuse it across calls when formatting multiple values.

```mbt check
///|
test "reuse the same buffer" {
  let buffer = @itoa.Buffer::new()
  inspect(buffer.format_u32(7U), content="7")
  inspect(buffer.format_i64(-9000000000000L), content="-9000000000000")
}
```
