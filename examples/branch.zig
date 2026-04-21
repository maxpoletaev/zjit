const std = @import("std");
const zjit = @import("zjit");

const Func = *const fn (i64, i64) callconv(.c) i64;

fn emitMax(jit: *zjit.State) Func {
    const r0 = zjit.R(0);
    const r1 = zjit.R(1);

    jit.prolog();
    const arg_a = jit.arg_l();
    const arg_b = jit.arg_l();
    jit.getarg_l(r0, arg_a);
    jit.getarg_l(r1, arg_b);
    const done = jit.bger(r0, r1); // if r0 >= r1 jump to done
    jit.movr(r0, r1); // r0 = r1 (b is larger)
    jit.patch(done); // done: (r0 is the max)
    jit.retr(r0);
    jit.epilog();

    return @ptrCast(@alignCast(jit.emit()));
}

pub fn main() !void {
    zjit.init("branch");
    defer zjit.deinit();

    var jit = zjit.State.init();
    defer jit.deinit();

    const max = emitMax(&jit);

    std.debug.print("max(3, 7) = {d}\n", .{max(3, 7)});
    std.debug.print("max(9, 2) = {d}\n", .{max(9, 2)});
    std.debug.print("max(5, 5) = {d}\n", .{max(5, 5)});
}
