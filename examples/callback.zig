const std = @import("std");
const zjit = @import("zjit");

fn nativeFunc(a: i64, b: i64) callconv(.c) void {
    std.debug.print("callback.zig: called with a={d}, b={d}\n", .{ a, b });
}

const Func = *const fn (i64, i64) callconv(.c) void;

fn emitFunc(jit: *zjit.State) Func {
    jit.prolog();
    const r0 = zjit.R(0);
    const r1 = zjit.R(1);
    const arg_a = jit.arg_l();
    const arg_b = jit.arg_l();
    jit.getarg_l(r0, arg_a);
    jit.getarg_l(r1, arg_b);
    jit.prepare();
    jit.pushargr(r0);
    jit.pushargr(r1);
    // calling to zig nativeFunc from jitted code
    _ = jit.finishi(@ptrCast(@constCast(&nativeFunc)));
    jit.epilog();

    const code_ptr = jit.emit();
    return @ptrCast(@alignCast(code_ptr));
}

pub fn main() !void {
    zjit.init("example");
    defer zjit.deinit();

    var jit = zjit.State.init();
    defer jit.deinit();

    const func = emitFunc(&jit);
    func(6, 7);
}
