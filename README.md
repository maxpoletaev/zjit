# zjit

zjit is a bare-bones JIT code emitter for Zig wrapping [GNU Lightning](https://www.gnu.org/software/lightning/) library. GNU Lightning manual and instruction set is available at https://www.gnu.org/software/lightning/manual/

## Add to your project

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

const Func = *const fn (i64, i64) callconv(.c) i64;

fn emitAdd(jit: zjit.State) Func {
    jit.prolog();
    const a = jit.argL();
    const b = jit.argL();
    const r0 = zjit.R(0);
    const r1 = zjit.R(1);
    jit.getargL(r0, a);
    jit.getargL(r1, b);
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

    const add = emitAdd(jit);
    const result = add(3, 4);
    std.debug.print("{d}\n", .{result}); // 7
}
```

## Dynamic Linking

For the sake of proper licensing: GNU Lightning is under LGPL, which means you may want to link to it dynamically. The library is built statically by default but this can be changed via `linkage` option:

```zig
const zjit = b.dependency("zjit", .{
    .target = target,
    .optimize = optimize,
    .linkage = .dynamic,
});
```

