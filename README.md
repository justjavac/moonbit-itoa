# `justjavac/itoa`

[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-itoa/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-itoa)

Fast decimal formatting for `Int`, `UInt`, `Int64`, and `UInt64`, inspired by
Rust's [`itoa`](https://github.com/dtolnay/itoa) crate.

## Install

```bash
moon add justjavac/itoa
```

## Example

```moonbit
let buffer = @itoa.Buffer::new()

let signed = buffer.format_i32(-42)
let unsigned = buffer.format_u64(18446744073709551615UL)

println(signed)   // "-42"
println(unsigned) // "18446744073709551615"
```

## API

- `Buffer::new()`
- `Buffer::format_i32()`
- `Buffer::format_u32()`
- `Buffer::format_i64()`
- `Buffer::format_u64()`
- `udivmod_1e19()` for low-level `UInt64` splitting by `10^19`

## Notes

- Reuse one `Buffer` across many formatting calls to avoid rebuilding working
  storage.
- The checked examples used for package documentation live in
  [`README.mbt.md`](README.mbt.md).
- Run `moon test` to execute unit tests and README examples.
