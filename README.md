# zjit

zjit is a bare-bones JIT code emitter for Zig wrapping [GNU Lightning](https://www.gnu.org/software/lightning/) library. Supports x86_64, aarch64 and other architectures. Lightning manual and instruction set is available at https://www.gnu.org/software/lightning/manual/

## Add to your project

```
zig fetch --save https://github.com/maxpoletaev/zjit.git
```

```zig
const zjit = b.dependency("zjit", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zjit", zjit.module("root"));
```

## Example

```zig
const zjit = @import("zjit");

const AddFunc = *const fn (i64, i64) callconv(.c) i64;

fn emitAddFunc(jit: zjit.State) AddFunc {
    jit.prolog();
    const r0 = zjit.R(0);
    const r1 = zjit.R(1);
    const a = jit.arg_l();
    const b = jit.arg_l();
    jit.getarg_l(r0, a);
    jit.getarg_l(r1, b);
    _ = jit.addr(r0, r0, r1);
    jit.retr(r0);
    jit.epilog();
    return @ptrCast(@alignCast(jit.emit()));
}

pub fn main() !void {
    zjit.init("myapp");
    defer zjit.deinit();

    const jit = zjit.State.init();
    defer jit.deinit();

    const add = emitAddFunc(jit);
    const result = add(3, 4);
    std.debug.print("{d}\n", .{result}); // 7
}
```

## Quick Overview

Lightning exposes a portable RISC-like instruction set.

There are around 60 base instructions like `add`, `mul`, `mov`, etc., which come in different variants for different operand types.

* `r` - all operands are registers
* `i` - one operand is an immediate constant

All instructions are signed and use native word size by default, but there are additional suffixes to specify the operand size:

* `_l` — 64-bit integer
* `_i` — 32-bit integer
* `_s` — 16-bit integer
* `_c` — 8-bit integer
* `_f` — float
* `_d` — double
* `_u` — unsigned

Depending on the architecture, there are (at least) six general purpose registers: `R(0-2)` (caller-save), `V(0-2)` (callee-save), and six floating point registers: `F(0-5)`.


## Dynamic Linking

The library is built statically by default. For the sake of proper licensing: GNU Lightning is under LGPL, which means you may want to link to it dynamically. This can be changed via `linkage` option:

```zig
const zjit = b.dependency("zjit", .{
    .target = target,
    .optimize = optimize,
    .linkage = .dynamic,
});
```

