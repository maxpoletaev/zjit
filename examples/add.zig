const std = @import("std");
const zjit = @import("zjit");

const Func = *const fn (i64, i64) callconv(.c) i64;

fn emitFunc(jit: zjit.State) Func {
    jit.prolog();
    const r0 = zjit.R(0);
    const r1 = zjit.R(1);
    const arg_a = jit.arg_l();
    const arg_b = jit.arg_l();
    jit.getarg_l(r0, arg_a);
    jit.getarg_l(r1, arg_b);
    _ = jit.addr(r0, r0, r1);
    jit.retr(r0);
    jit.epilog();

    const code_ptr = jit.emit();
    return @ptrCast(@alignCast(code_ptr));
}

pub fn main() !void {
    zjit.init("example");
    defer zjit.deinit();

    const jit = zjit.State.init();
    defer jit.deinit();

    const add = emitFunc(jit);
    const result = add(3, 4);

    std.debug.print("add.zig: 3 + 4 = {d}\n", .{result});
    std.debug.assert(result == 7);
}
