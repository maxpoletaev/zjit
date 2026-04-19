const std = @import("std");
const zasm = @import("zjit");

const Func = *const fn (i64, i64) callconv(.c) i64;

fn emitFunc(jit: zasm.State) Func {
    jit.prolog();
    const arg_a = jit.argL();
    const arg_b = jit.argL();
    const r0 = zasm.R(0);
    const r1 = zasm.R(1);
    jit.getargL(r0, arg_a);
    jit.getargL(r1, arg_b);
    _ = jit.addr(r0, r0, r1);
    jit.retr(r0);
    jit.epilog();

    const code_ptr = jit.emit();
    return @ptrCast(@alignCast(code_ptr));
}

pub fn main() !void {
    zasm.init("example");
    defer zasm.deinit();

    const jit = zasm.State.init();
    defer jit.destroy();

    const add = emitFunc(jit);
    const result = add(3, 4);

    std.debug.print("add.zig: 3 + 4 = {d}\n", .{result});
    std.debug.assert(result == 7);
}
