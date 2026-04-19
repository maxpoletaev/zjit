const std = @import("std");
const zasm = @import("zjit");

fn nativeFunc(a: i64, b: i64) callconv(.c) void {
    std.debug.print("callback.zig: called with a={d}, b={d}\n", .{ a, b });
}

const Func = *const fn (i64, i64) callconv(.c) void;

fn emitFunc(jit: zasm.State) Func {
    jit.prolog();
    const arg_a = jit.argL();
    const arg_b = jit.argL();
    const r0 = zasm.R(0);
    const r1 = zasm.R(1);
    jit.getargL(r0, arg_a);
    jit.getargL(r1, arg_b);
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
    zasm.init("example");
    defer zasm.deinit();

    const jit = zasm.State.init();
    defer jit.deinit();

    const func = emitFunc(jit);
    func(6, 7);
}
