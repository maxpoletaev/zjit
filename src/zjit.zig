// zig fmt: off
const std = @import("std");
const c = @import("c");

test {
    _ = std.testing.refAllDecls(@This());
}

pub const Word = c.jit_word_t;
pub const UWord = c.jit_uword_t;
pub const Gpr = c.jit_gpr_t;
pub const Fpr = c.jit_fpr_t;
pub const Pointer = c.jit_pointer_t;
pub const Node = c.jit_node_t;

pub fn init(program_name: [*:0]const u8) void { c.init_jit(program_name); }
pub fn initWithDebug(program_name: [*:0]const u8, file: *c.FILE) void {
    c.init_jit_with_debug(program_name, file); 
}
pub fn deinit() void { c.finish_jit(); }

// Registers
pub fn R(index: c_int) Gpr { return c.jit_r(index); }
pub fn V(index: c_int) Gpr { return c.jit_v(index); }
pub fn F(index: c_int) Fpr { return c.jit_f(index); }
pub fn rNum() c_int { return c.jit_r_num(); }
pub fn vNum() c_int { return c.jit_v_num(); }
pub fn fNum() c_int { return c.jit_f_num(); }

// Emitter state
pub const State = struct {
    ptr: *c.jit_state_t,

    pub fn init() State { return .{ .ptr = c.jit_new_state().? }; }
    pub fn clear(self: State) void { c._jit_clear_state(self.ptr); }
    pub fn deinit(self: State) void { c._jit_destroy_state(self.ptr); }

    // ---- Code generation control ----

    pub fn prolog(self: State) void { c._jit_prolog(self.ptr); }
    pub fn epilog(self: State) void { c._jit_epilog(self.ptr); }
    pub fn realize(self: State) void { c._jit_realize(self.ptr); }
    pub fn emit(self: State) Pointer { return c._jit_emit(self.ptr); }
    pub fn protect(self: State) void { c._jit_protect(self.ptr); }
    pub fn unprotect(self: State) void { c._jit_unprotect(self.ptr); }
    pub fn print(self: State) void { c._jit_print(self.ptr); }

    // ---- Labels and patching ----

    pub fn label(self: State) *Node { return c._jit_label(self.ptr).?; }
    pub fn forward(self: State) *Node { return c._jit_forward(self.ptr).?; }
    pub fn indirect(self: State) *Node { return c._jit_indirect(self.ptr).?; }
    pub fn forwardP(self: State, node: *Node) bool { return c._jit_forward_p(self.ptr, node) != 0; }
    pub fn indirectP(self: State, node: *Node) bool { return c._jit_indirect_p(self.ptr, node) != 0; }
    pub fn targetP(self: State, node: *Node) bool { return c._jit_target_p(self.ptr, node) != 0; }
    pub fn link(self: State, node: *Node) void { c._jit_link(self.ptr, node); }
    pub fn patch(self: State, node: *Node) void { c._jit_patch(self.ptr, node); }
    pub fn patchAt(self: State, node: *Node, target: *Node) void { c._jit_patch_at(self.ptr, node, target); }
    pub fn patchAbs(self: State, node: *Node, ptr: Pointer) void { c._jit_patch_abs(self.ptr, node, ptr); }
    pub fn address(self: State, node: *Node) Pointer { return c._jit_address(self.ptr, node); }
    pub fn argRegisterP(self: State, node: *Node) bool { return c._jit_arg_register_p(self.ptr, node) != 0; }
    pub fn calleeSaveP(self: State, reg: Gpr) bool { return c._jit_callee_save_p(self.ptr, reg) != 0; }
    pub fn pointerP(self: State, ptr: Pointer) bool { return c._jit_pointer_p(self.ptr, ptr) != 0; }
    pub fn getNote(self: State, ptr: Pointer, file: *[*:0]u8, sym: *[*:0]u8, line: *c_int) bool { 
        return c._jit_get_note(self.ptr, ptr, @ptrCast(file), @ptrCast(sym), line) != 0; 
    }
    pub fn getReg(self: State, spec: i32) i32 { return c._jit_get_reg(self.ptr, spec); }
    pub fn ungetReg(self: State, reg: i32) void { c._jit_unget_reg(self.ptr, reg); }

    // ---- Stack allocation ----

    pub fn allocai(self: State, size: i32) i32 { return c._jit_allocai(self.ptr, size); }
    pub fn allocar(self: State, off: i32, len: i32) void { c._jit_allocar(self.ptr, off, len); }

    // ---- Arguments ----

    pub fn arg_c(self: State) *Node { return c._jit_arg(self.ptr, c.jit_code_arg_c).?; }
    pub fn arg_s(self: State) *Node { return c._jit_arg(self.ptr, c.jit_code_arg_s).?; }
    pub fn arg_i(self: State) *Node { return c._jit_arg(self.ptr, c.jit_code_arg_i).?; }
    pub fn arg_l(self: State) *Node { return c._jit_arg(self.ptr, c.jit_code_arg_l).?; }
    pub fn arg_f(self: State) *Node { return c._jit_arg_f(self.ptr).?; }
    pub fn arg_d(self: State) *Node { return c._jit_arg_d(self.ptr).?; }

    pub fn getarg_c(self: State, reg: Gpr, a: *Node) void { c._jit_getarg_c(self.ptr, reg, a); }
    pub fn getarg_uc(self: State, reg: Gpr, a: *Node) void { c._jit_getarg_uc(self.ptr, reg, a); }
    pub fn getarg_s(self: State, reg: Gpr, a: *Node) void { c._jit_getarg_s(self.ptr, reg, a); }
    pub fn getarg_us(self: State, reg: Gpr, a: *Node) void { c._jit_getarg_us(self.ptr, reg, a); }
    pub fn getarg_i(self: State, reg: Gpr, a: *Node) void { c._jit_getarg_i(self.ptr, reg, a); }
    pub fn getarg_ui(self: State, reg: Gpr, a: *Node) void { c._jit_getarg_ui(self.ptr, reg, a); }
    pub fn getarg_l(self: State, reg: Gpr, a: *Node) void { c._jit_getarg_l(self.ptr, reg, a); }
    pub fn getarg_f(self: State, reg: Fpr, a: *Node) void { c._jit_getarg_f(self.ptr, reg, a); }
    pub fn getarg_d(self: State, reg: Fpr, a: *Node) void { c._jit_getarg_d(self.ptr, reg, a); }

    // ---- Call setup ----

    pub fn prepare(self: State) void { c._jit_prepare(self.ptr); }
    pub fn ellipsis(self: State) void { c._jit_ellipsis(self.ptr); }

    pub fn pushargr_c(self: State, reg: Gpr) void { c._jit_pushargr(self.ptr, reg, c.jit_code_pushargr_c); }
    pub fn pushargi_c(self: State, val: Word) void { c._jit_pushargi(self.ptr, val, c.jit_code_pushargi_c); }
    pub fn pushargr_uc(self: State, reg: Gpr) void { c._jit_pushargr(self.ptr, reg, c.jit_code_pushargr_uc); }
    pub fn pushargi_uc(self: State, val: Word) void { c._jit_pushargi(self.ptr, val, c.jit_code_pushargi_uc); }
    pub fn pushargr_s(self: State, reg: Gpr) void { c._jit_pushargr(self.ptr, reg, c.jit_code_pushargr_s); }
    pub fn pushargi_s(self: State, val: Word) void { c._jit_pushargi(self.ptr, val, c.jit_code_pushargi_s); }
    pub fn pushargr_us(self: State, reg: Gpr) void { c._jit_pushargr(self.ptr, reg, c.jit_code_pushargr_us); }
    pub fn pushargi_us(self: State, val: Word) void { c._jit_pushargi(self.ptr, val, c.jit_code_pushargi_us); }
    pub fn pushargr_i(self: State, reg: Gpr) void { c._jit_pushargr(self.ptr, reg, c.jit_code_pushargr_i); }
    pub fn pushargi_i(self: State, val: Word) void { c._jit_pushargi(self.ptr, val, c.jit_code_pushargi_i); }
    pub fn pushargr_ui(self: State, reg: Gpr) void { c._jit_pushargr(self.ptr, reg, c.jit_code_pushargr_ui); }
    pub fn pushargi_ui(self: State, val: Word) void { c._jit_pushargi(self.ptr, val, c.jit_code_pushargi_ui); }
    pub fn pushargr(self: State, reg: Gpr) void { c._jit_pushargr(self.ptr, reg, c.jit_code_pushargr_l); }
    pub fn pushargi(self: State, val: Word) void { c._jit_pushargi(self.ptr, val, c.jit_code_pushargi_l); }
    pub fn pushargr_f(self: State, reg: Fpr) void { c._jit_pushargr_f(self.ptr, reg); }
    pub fn pushargi_f(self: State, val: f32) void { c._jit_pushargi_f(self.ptr, val); }
    pub fn pushargr_d(self: State, reg: Fpr) void { c._jit_pushargr_d(self.ptr, reg); }
    pub fn pushargi_d(self: State, val: f64) void { c._jit_pushargi_d(self.ptr, val); }

    pub fn finishr(self: State, reg: Gpr) void { c._jit_finishr(self.ptr, reg); }
    pub fn finishi(self: State, ptr: Pointer) *Node { return c._jit_finishi(self.ptr, ptr).?; }

    pub fn putargr_c(self: State, reg: Gpr, a: *Node) void { c._jit_putargr(self.ptr, reg, a, c.jit_code_putargr_c); }
    pub fn putargi_c(self: State, val: Word, a: *Node) void { c._jit_putargi(self.ptr, val, a, c.jit_code_putargi_c); }
    pub fn putargr_uc(self: State, reg: Gpr, a: *Node) void { c._jit_putargr(self.ptr, reg, a, c.jit_code_putargr_uc); }
    pub fn putargi_uc(self: State, val: Word, a: *Node) void { c._jit_putargi(self.ptr, val, a, c.jit_code_putargi_uc); }
    pub fn putargr_s(self: State, reg: Gpr, a: *Node) void { c._jit_putargr(self.ptr, reg, a, c.jit_code_putargr_s); }
    pub fn putargi_s(self: State, val: Word, a: *Node) void { c._jit_putargi(self.ptr, val, a, c.jit_code_putargi_s); }
    pub fn putargr_us(self: State, reg: Gpr, a: *Node) void { c._jit_putargr(self.ptr, reg, a, c.jit_code_putargr_us); }
    pub fn putargi_us(self: State, val: Word, a: *Node) void { c._jit_putargi(self.ptr, val, a, c.jit_code_putargi_us); }
    pub fn putargr_i(self: State, reg: Gpr, a: *Node) void { c._jit_putargr(self.ptr, reg, a, c.jit_code_putargr_i); }
    pub fn putargi_i(self: State, val: Word, a: *Node) void { c._jit_putargi(self.ptr, val, a, c.jit_code_putargi_i); }
    pub fn putargr_ui(self: State, reg: Gpr, a: *Node) void { c._jit_putargr(self.ptr, reg, a, c.jit_code_putargr_ui); }
    pub fn putargi_ui(self: State, val: Word, a: *Node) void { c._jit_putargi(self.ptr, val, a, c.jit_code_putargi_ui); }
    pub fn putargr(self: State, reg: Gpr, a: *Node) void { c._jit_putargr(self.ptr, reg, a, c.jit_code_putargr_l); }
    pub fn putargi(self: State, val: Word, a: *Node) void { c._jit_putargi(self.ptr, val, a, c.jit_code_putargi_l); }
    pub fn putargr_f(self: State, reg: Fpr, a: *Node) void { c._jit_putargr_f(self.ptr, reg, a); }
    pub fn putargi_f(self: State, val: f32, a: *Node) void { c._jit_putargi_f(self.ptr, val, a); }
    pub fn putargr_d(self: State, reg: Fpr, a: *Node) void { c._jit_putargr_d(self.ptr, reg, a); }
    pub fn putargi_d(self: State, val: f64, a: *Node) void { c._jit_putargi_d(self.ptr, val, a); }

    // ---- Return values ----

    pub fn ret(self: State) void { c._jit_ret(self.ptr); }
    pub fn retr_c(self: State, reg: Gpr) void { c._jit_retr(self.ptr, reg, c.jit_code_retr_c); }
    pub fn reti_c(self: State, val: Word) void { c._jit_reti(self.ptr, val, c.jit_code_reti_c); }
    pub fn retr_uc(self: State, reg: Gpr) void { c._jit_retr(self.ptr, reg, c.jit_code_retr_uc); }
    pub fn reti_uc(self: State, val: Word) void { c._jit_reti(self.ptr, val, c.jit_code_reti_uc); }
    pub fn retr_s(self: State, reg: Gpr) void { c._jit_retr(self.ptr, reg, c.jit_code_retr_s); }
    pub fn reti_s(self: State, val: Word) void { c._jit_reti(self.ptr, val, c.jit_code_reti_s); }
    pub fn retr_us(self: State, reg: Gpr) void { c._jit_retr(self.ptr, reg, c.jit_code_retr_us); }
    pub fn reti_us(self: State, val: Word) void { c._jit_reti(self.ptr, val, c.jit_code_reti_us); }
    pub fn retr_i(self: State, reg: Gpr) void { c._jit_retr(self.ptr, reg, c.jit_code_retr_i); }
    pub fn reti_i(self: State, val: Word) void { c._jit_reti(self.ptr, val, c.jit_code_reti_i); }
    pub fn retr_ui(self: State, reg: Gpr) void { c._jit_retr(self.ptr, reg, c.jit_code_retr_ui); }
    pub fn reti_ui(self: State, val: Word) void { c._jit_reti(self.ptr, val, c.jit_code_reti_ui); }
    pub fn retr(self: State, reg: Gpr) void { c._jit_retr(self.ptr, reg, c.jit_code_retr_l); }
    pub fn reti(self: State, val: Word) void { c._jit_reti(self.ptr, val, c.jit_code_reti_l); }
    pub fn retr_f(self: State, reg: Fpr) void { c._jit_retr_f(self.ptr, reg); }
    pub fn reti_f(self: State, val: f32) void { c._jit_reti_f(self.ptr, val); }
    pub fn retr_d(self: State, reg: Fpr) void { c._jit_retr_d(self.ptr, reg); }
    pub fn reti_d(self: State, val: f64) void { c._jit_reti_d(self.ptr, val); }

    pub fn retval_c(self: State, reg: Gpr) void { c._jit_retval_c(self.ptr, reg); }
    pub fn retval_uc(self: State, reg: Gpr) void { c._jit_retval_uc(self.ptr, reg); }
    pub fn retval_s(self: State, reg: Gpr) void { c._jit_retval_s(self.ptr, reg); }
    pub fn retval_us(self: State, reg: Gpr) void { c._jit_retval_us(self.ptr, reg); }
    pub fn retval_i(self: State, reg: Gpr) void { c._jit_retval_i(self.ptr, reg); }
    pub fn retval_ui(self: State, reg: Gpr) void { c._jit_retval_ui(self.ptr, reg); }
    pub fn retval_l(self: State, reg: Gpr) void { c._jit_retval_l(self.ptr, reg); }

    // ---- Code / data buffer management ----

    pub fn getCode(self: State, size: *Word) Pointer { return c._jit_get_code(self.ptr, size); }
    pub fn setCode(self: State, ptr: Pointer, size: Word) void { c._jit_set_code(self.ptr, ptr, size); }
    pub fn getData(self: State, data_size: *Word, note_size: *Word) Pointer { return c._jit_get_data(self.ptr, data_size, note_size); }
    pub fn setData(self: State, ptr: Pointer, size: Word, flags: Word) void { c._jit_set_data(self.ptr, ptr, size, flags); }
    pub fn frame(self: State, size: i32) void { c._jit_frame(self.ptr, size); }
    pub fn tramp(self: State, size: i32) void { c._jit_tramp(self.ptr, size); }

    // ---- Miscellaneous ----

    pub fn live(self: State, u: Gpr) *Node { return c._jit_new_node_w(self.ptr, c.jit_code_live, u).?; }
    pub fn alignInsn(self: State, u: Word) *Node { return c._jit_new_node_w(self.ptr, c.jit_code_align, u).?; }
    pub fn name(self: State, str: [*:0]const u8) *Node { return c._jit_name(self.ptr, str).?; }
    pub fn note(self: State, file: [*:0]const u8, line: c_int) *Node { return c._jit_note(self.ptr, file, line).?; }

    // ---- Varargs ----

    pub fn va_push(self: State, u: Gpr) void { c._jit_va_push(self.ptr, u); }
    pub fn va_start(self: State, u: Gpr) *Node { return c._jit_new_node_w(self.ptr, c.jit_code_va_start, u).?; }
    pub fn va_arg(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_va_arg, u, v).?; }
    pub fn va_arg_d(self: State, u: Fpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_va_arg_d, u, v).?; }
    pub fn va_end(self: State, u: Gpr) *Node { return c._jit_new_node_w(self.ptr, c.jit_code_va_end, u).?; }

    // ---- Integer arithmetic (dst, src1, src2/imm) ----

    pub fn addr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addr, u, v, w).?; }
    pub fn addi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addi, u, v, w).?; }
    pub fn addcr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addcr, u, v, w).?; }
    pub fn addci(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addci, u, v, w).?; }
    pub fn addxr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addxr, u, v, w).?; }
    pub fn addxi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addxi, u, v, w).?; }

    pub fn subr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subr, u, v, w).?; }
    pub fn subi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subi, u, v, w).?; }
    pub fn subcr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subcr, u, v, w).?; }
    pub fn subci(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subci, u, v, w).?; }
    pub fn subxr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subxr, u, v, w).?; }
    pub fn subxi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subxi, u, v, w).?; }
    pub fn rsbr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subr, u, w, v).?; }
    pub fn rsbi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_rsbi, u, v, w).?; }

    pub fn mulr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_mulr, u, v, w).?; }
    pub fn muli(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_muli, u, v, w).?; }
    pub fn hmulr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_hmulr, u, v, w).?; }
    pub fn hmuli(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_hmuli, u, v, w).?; }
    pub fn hmulr_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_hmulr_u, u, v, w).?; }
    pub fn hmuli_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_hmuli_u, u, v, w).?; }
    pub fn divr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_divr, u, v, w).?; }
    pub fn divi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_divi, u, v, w).?; }
    pub fn divr_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_divr_u, u, v, w).?; }
    pub fn divi_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_divi_u, u, v, w).?; }
    pub fn remr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_remr, u, v, w).?; }
    pub fn remi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_remi, u, v, w).?; }
    pub fn remr_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_remr_u, u, v, w).?; }
    pub fn remi_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_remi_u, u, v, w).?; }

    // Widening multiply/divide (lo_dst, hi_dst, src1, src2)
    pub fn qmulr(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qmulr, lo, hi, v, w).?; }
    pub fn qmuli(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qmuli, lo, hi, v, w).?; }
    pub fn qmulr_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qmulr_u, lo, hi, v, w).?; }
    pub fn qmuli_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qmuli_u, lo, hi, v, w).?; }
    pub fn qdivr(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qdivr, lo, hi, v, w).?; }
    pub fn qdivi(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qdivi, lo, hi, v, w).?; }
    pub fn qdivr_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qdivr_u, lo, hi, v, w).?; }
    pub fn qdivi_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qdivi_u, lo, hi, v, w).?; }

    // ---- Bitwise (dst, src1, src2/imm) ----

    pub fn andr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_andr, u, v, w).?; }
    pub fn andi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_andi, u, v, w).?; }
    pub fn orr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_orr, u, v, w).?; }
    pub fn ori(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ori, u, v, w).?; }
    pub fn xorr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_xorr, u, v, w).?; }
    pub fn xori(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_xori, u, v, w).?; }
    pub fn lshr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lshr, u, v, w).?; }
    pub fn lshi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lshi, u, v, w).?; }
    pub fn rshr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_rshr, u, v, w).?; }
    pub fn rshi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_rshi, u, v, w).?; }
    pub fn rshr_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_rshr_u, u, v, w).?; }
    pub fn rshi_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_rshi_u, u, v, w).?; }
    pub fn lrotr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lrotr, u, v, w).?; }
    pub fn lroti(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lroti, u, v, w).?; }
    pub fn rrotr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_rrotr, u, v, w).?; }
    pub fn rroti(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_rroti, u, v, w).?; }

    // Widening shifts (lo_dst, hi_dst, src, amount)
    pub fn qlshr(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qlshr, lo, hi, v, w).?; }
    pub fn qlshi(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qlshi, lo, hi, v, w).?; }
    pub fn qlshr_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qlshr_u, lo, hi, v, w).?; }
    pub fn qlshi_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qlshi_u, lo, hi, v, w).?; }
    pub fn qrshr(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qrshr, lo, hi, v, w).?; }
    pub fn qrshi(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qrshi, lo, hi, v, w).?; }
    pub fn qrshr_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qrshr_u, lo, hi, v, w).?; }
    pub fn qrshi_u(self: State, lo: Gpr, hi: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_qww(self.ptr, c.jit_code_qrshi_u, lo, hi, v, w).?; }

    // ---- Unary (dst, src) ----

    pub fn negr(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_negr, u, v).?; }
    pub fn negi(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_negi, u, v).?; }
    pub fn comr(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_comr, u, v).?; }
    pub fn comi(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_comi, u, v).?; }
    pub fn clor(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_clor, u, v).?; }
    pub fn cloi(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_cloi, u, v).?; }
    pub fn clzr(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_clzr, u, v).?; }
    pub fn clzi(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_clzi, u, v).?; }
    pub fn ctor(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ctor, u, v).?; }
    pub fn ctoi(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ctoi, u, v).?; }
    pub fn ctzr(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ctzr, u, v).?; }
    pub fn ctzi(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ctzi, u, v).?; }
    pub fn rbitr(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_rbitr, u, v).?; }
    pub fn rbiti(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_rbiti, u, v).?; }
    pub fn popcntr(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_popcntr, u, v).?; }
    pub fn popcnti(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_popcnti, u, v).?; }

    // ---- Comparison (dst, src1, src2/imm) → dst = 0 or 1 ----

    pub fn ltr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ltr, u, v, w).?; }
    pub fn lti(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lti, u, v, w).?; }
    pub fn ltr_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ltr_u, u, v, w).?; }
    pub fn lti_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lti_u, u, v, w).?; }
    pub fn ler(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ler, u, v, w).?; }
    pub fn lei(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lei, u, v, w).?; }
    pub fn ler_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ler_u, u, v, w).?; }
    pub fn lei_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_lei_u, u, v, w).?; }
    pub fn eqr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_eqr, u, v, w).?; }
    pub fn eqi(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_eqi, u, v, w).?; }
    pub fn ger(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ger, u, v, w).?; }
    pub fn gei(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gei, u, v, w).?; }
    pub fn ger_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ger_u, u, v, w).?; }
    pub fn gei_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gei_u, u, v, w).?; }
    pub fn gtr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gtr, u, v, w).?; }
    pub fn gti(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gti, u, v, w).?; }
    pub fn gtr_u(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gtr_u, u, v, w).?; }
    pub fn gti_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gti_u, u, v, w).?; }
    pub fn ner(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ner, u, v, w).?; }
    pub fn nei(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_nei, u, v, w).?; }

    // ---- Move ----

    pub fn movr(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movr, u, v).?; }
    pub fn movi(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movi, u, v).?; }
    pub fn movnr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_movnr, u, v, w).?; }
    pub fn movzr(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_movzr, u, v, w).?; }

    // ---- Sign/zero extension ----

    pub fn extr_c(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_c, u, v).?; }
    pub fn extr_uc(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_uc, u, v).?; }
    pub fn extr_s(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_s, u, v).?; }
    pub fn extr_us(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_us, u, v).?; }
    pub fn extr_i(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_i, u, v).?; }
    pub fn extr_ui(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_ui, u, v).?; }
    pub fn exti_c(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_exti_c, u, v).?; }
    pub fn exti_uc(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_exti_uc, u, v).?; }
    pub fn exti_s(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_exti_s, u, v).?; }
    pub fn exti_us(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_exti_us, u, v).?; }
    pub fn exti_i(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_exti_i, u, v).?; }
    pub fn exti_ui(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_exti_ui, u, v).?; }

    // Bitfield extract/deposit (dst, src, lsb, len)
    pub fn extr(self: State, u: Gpr, v: Gpr, lsb: i32, len: i32) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_extr, u, v, lsb, len).?; }
    pub fn extr_u(self: State, u: Gpr, v: Gpr, lsb: i32, len: i32) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_extr_u, u, v, lsb, len).?; }
    pub fn exti(self: State, u: Gpr, v: Word, lsb: i32, len: i32) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_exti, u, v, lsb, len).?; }
    pub fn exti_u(self: State, u: Gpr, v: Word, lsb: i32, len: i32) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_exti_u, u, v, lsb, len).?; }
    pub fn depr(self: State, u: Gpr, v: Gpr, lsb: i32, len: i32) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_depr, u, v, lsb, len).?; }
    pub fn depi(self: State, u: Gpr, v: Word, lsb: i32, len: i32) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_depi, u, v, lsb, len).?; }

    // Compare-and-swap (dst, ptr_reg, expected_lo, expected_hi)
    pub fn casr(self: State, u: Gpr, v: Gpr, lo: Gpr, hi: Gpr) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_casr, u, v, lo, hi).?; }
    pub fn casi(self: State, u: Gpr, v: Pointer, lo: i32, hi: i32) *Node { return c._jit_new_node_wwq(self.ptr, c.jit_code_casi, u, @intCast(@intFromPtr(v)), lo, hi).?; }

    // Byte swap
    pub fn bswapr_us(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_bswapr_us, u, v).?; }
    pub fn bswapi_us(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_bswapi_us, u, v).?; }
    pub fn bswapr_ui(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_bswapr_ui, u, v).?; }
    pub fn bswapi_ui(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_bswapi_ui, u, v).?; }
    pub fn bswapr_ul(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_bswapr_ul, u, v).?; }
    pub fn bswapi_ul(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_bswapi_ul, u, v).?; }
    pub fn htonr_us(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_htonr_us, u, v).?; }
    pub fn htoni_us(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_htoni_us, u, v).?; }
    pub fn htonr_ui(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_htonr_ui, u, v).?; }
    pub fn htoni_ui(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_htoni_ui, u, v).?; }
    pub fn htonr_ul(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_htonr_ul, u, v).?; }
    pub fn htoni_ul(self: State, u: Gpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_htoni_ul, u, v).?; }

    // ---- Load (dst, addr_reg) ----

    pub fn ldr_c(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_c, u, v).?; }
    pub fn ldr_uc(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_uc, u, v).?; }
    pub fn ldr_s(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_s, u, v).?; }
    pub fn ldr_us(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_us, u, v).?; }
    pub fn ldr_i(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_i, u, v).?; }
    pub fn ldr_ui(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_ui, u, v).?; }
    pub fn ldr_l(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_l, u, v).?; }

    // Load from immediate address (dst, addr_ptr)
    pub fn ldi_c(self: State, u: Gpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_c, u, v).?; }
    pub fn ldi_uc(self: State, u: Gpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_uc, u, v).?; }
    pub fn ldi_s(self: State, u: Gpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_s, u, v).?; }
    pub fn ldi_us(self: State, u: Gpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_us, u, v).?; }
    pub fn ldi_i(self: State, u: Gpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_i, u, v).?; }
    pub fn ldi_ui(self: State, u: Gpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_ui, u, v).?; }
    pub fn ldi_l(self: State, u: Gpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_l, u, v).?; }

    // Load indexed (dst, base_reg, offset_reg/imm)
    pub fn ldxr_c(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_c, u, v, w).?; }
    pub fn ldxi_c(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_c, u, v, w).?; }
    pub fn ldxr_uc(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_uc, u, v, w).?; }
    pub fn ldxi_uc(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_uc, u, v, w).?; }
    pub fn ldxr_s(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_s, u, v, w).?; }
    pub fn ldxi_s(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_s, u, v, w).?; }
    pub fn ldxr_us(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_us, u, v, w).?; }
    pub fn ldxi_us(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_us, u, v, w).?; }
    pub fn ldxr_i(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_i, u, v, w).?; }
    pub fn ldxi_i(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_i, u, v, w).?; }
    pub fn ldxr_ui(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_ui, u, v, w).?; }
    pub fn ldxi_ui(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_ui, u, v, w).?; }
    pub fn ldxr_l(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_l, u, v, w).?; }
    pub fn ldxi_l(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_l, u, v, w).?; }

    // Pre/post-increment indexed load
    pub fn ldxbr_c(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_c, u, v, w).?; }
    pub fn ldxbi_c(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_c, u, v, w).?; }
    pub fn ldxar_c(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_c, u, v, w).?; }
    pub fn ldxai_c(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_c, u, v, w).?; }
    pub fn ldxbr_s(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_s, u, v, w).?; }
    pub fn ldxbi_s(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_s, u, v, w).?; }
    pub fn ldxar_s(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_s, u, v, w).?; }
    pub fn ldxai_s(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_s, u, v, w).?; }
    pub fn ldxbr_i(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_i, u, v, w).?; }
    pub fn ldxbi_i(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_i, u, v, w).?; }
    pub fn ldxar_i(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_i, u, v, w).?; }
    pub fn ldxai_i(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_i, u, v, w).?; }
    pub fn ldxbr_uc(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_uc, u, v, w).?; }
    pub fn ldxbi_uc(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_uc, u, v, w).?; }
    pub fn ldxar_uc(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_uc, u, v, w).?; }
    pub fn ldxai_uc(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_uc, u, v, w).?; }
    pub fn ldxbr_us(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_us, u, v, w).?; }
    pub fn ldxbi_us(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_us, u, v, w).?; }
    pub fn ldxar_us(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_us, u, v, w).?; }
    pub fn ldxai_us(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_us, u, v, w).?; }
    pub fn ldxbr_ui(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_ui, u, v, w).?; }
    pub fn ldxbi_ui(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_ui, u, v, w).?; }
    pub fn ldxar_ui(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_ui, u, v, w).?; }
    pub fn ldxai_ui(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_ui, u, v, w).?; }
    pub fn ldxbr_l(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_l, u, v, w).?; }
    pub fn ldxbi_l(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_l, u, v, w).?; }
    pub fn ldxar_l(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_l, u, v, w).?; }
    pub fn ldxai_l(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_l, u, v, w).?; }
    pub fn ldxbr_f(self: State, u: Fpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_f, u, v, w).?; }
    pub fn ldxbi_f(self: State, u: Fpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_f, u, v, w).?; }
    pub fn ldxar_f(self: State, u: Fpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_f, u, v, w).?; }
    pub fn ldxai_f(self: State, u: Fpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_f, u, v, w).?; }
    pub fn ldxbr_d(self: State, u: Fpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbr_d, u, v, w).?; }
    pub fn ldxbi_d(self: State, u: Fpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxbi_d, u, v, w).?; }
    pub fn ldxar_d(self: State, u: Fpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxar_d, u, v, w).?; }
    pub fn ldxai_d(self: State, u: Fpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxai_d, u, v, w).?; }

    // Unaligned load (dst, addr_reg, size)
    pub fn unldr(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unldr, u, v, w).?; }
    pub fn unldi(self: State, u: Gpr, v: Pointer, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unldi, u, @intCast(@intFromPtr(v)), w).?; }
    pub fn unldr_u(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unldr_u, u, v, w).?; }
    pub fn unldi_u(self: State, u: Gpr, v: Pointer, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unldi_u, u, @intCast(@intFromPtr(v)), w).?; }

    // ---- Store ----

    pub fn str_c(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_str_c, u, v).?; }
    pub fn str_s(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_str_s, u, v).?; }
    pub fn str_i(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_str_i, u, v).?; }
    pub fn str_l(self: State, u: Gpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_str_l, u, v).?; }

    pub fn sti_c(self: State, u: Pointer, v: Gpr) *Node { return c._jit_new_node_pw(self.ptr, c.jit_code_sti_c, u, v).?; }
    pub fn sti_s(self: State, u: Pointer, v: Gpr) *Node { return c._jit_new_node_pw(self.ptr, c.jit_code_sti_s, u, v).?; }
    pub fn sti_i(self: State, u: Pointer, v: Gpr) *Node { return c._jit_new_node_pw(self.ptr, c.jit_code_sti_i, u, v).?; }
    pub fn sti_l(self: State, u: Pointer, v: Gpr) *Node { return c._jit_new_node_pw(self.ptr, c.jit_code_sti_l, u, v).?; }

    pub fn stxr_c(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxr_c, u, v, w).?; }
    pub fn stxi_c(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxi_c, u, v, w).?; }
    pub fn stxr_s(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxr_s, u, v, w).?; }
    pub fn stxi_s(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxi_s, u, v, w).?; }
    pub fn stxr_i(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxr_i, u, v, w).?; }
    pub fn stxi_i(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxi_i, u, v, w).?; }
    pub fn stxr_l(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxr_l, u, v, w).?; }
    pub fn stxi_l(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxi_l, u, v, w).?; }

    // Pre/post-increment store
    pub fn stxbr_c(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbr_c, u, v, w).?; }
    pub fn stxbi_c(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbi_c, u, v, w).?; }
    pub fn stxar_c(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxar_c, u, v, w).?; }
    pub fn stxai_c(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxai_c, u, v, w).?; }
    pub fn stxbr_s(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbr_s, u, v, w).?; }
    pub fn stxbi_s(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbi_s, u, v, w).?; }
    pub fn stxar_s(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxar_s, u, v, w).?; }
    pub fn stxai_s(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxai_s, u, v, w).?; }
    pub fn stxbr_i(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbr_i, u, v, w).?; }
    pub fn stxbi_i(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbi_i, u, v, w).?; }
    pub fn stxar_i(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxar_i, u, v, w).?; }
    pub fn stxai_i(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxai_i, u, v, w).?; }
    pub fn stxbr_l(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbr_l, u, v, w).?; }
    pub fn stxbi_l(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbi_l, u, v, w).?; }
    pub fn stxar_l(self: State, u: Gpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxar_l, u, v, w).?; }
    pub fn stxai_l(self: State, u: Word, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxai_l, u, v, w).?; }
    pub fn stxbr_f(self: State, u: Gpr, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbr_f, u, v, w).?; }
    pub fn stxbi_f(self: State, u: Word, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbi_f, u, v, w).?; }
    pub fn stxar_f(self: State, u: Gpr, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxar_f, u, v, w).?; }
    pub fn stxai_f(self: State, u: Word, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxai_f, u, v, w).?; }
    pub fn stxbr_d(self: State, u: Gpr, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbr_d, u, v, w).?; }
    pub fn stxbi_d(self: State, u: Word, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxbi_d, u, v, w).?; }
    pub fn stxar_d(self: State, u: Gpr, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxar_d, u, v, w).?; }
    pub fn stxai_d(self: State, u: Word, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxai_d, u, v, w).?; }

    pub fn unstr(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unstr, u, v, w).?; }
    pub fn unsti(self: State, u: Pointer, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unsti, @intCast(@intFromPtr(u)), v, w).?; }
    pub fn unldr_x(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unldr_x, u, v, w).?; }
    pub fn unldi_x(self: State, u: Gpr, v: Pointer, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unldi_x, u, @intCast(@intFromPtr(v)), w).?; }
    pub fn unstr_x(self: State, u: Gpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unstr_x, u, v, w).?; }
    pub fn unsti_x(self: State, u: Pointer, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unsti_x, @intCast(@intFromPtr(u)), v, w).?; }

    // ---- Branches (return node; patch to label with patchAt) ----

    pub fn bltr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bltr, null, v, w).?; }
    pub fn blti(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_blti, null, v, w).?; }
    pub fn bltr_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bltr_u, null, v, w).?; }
    pub fn blti_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_blti_u, null, v, w).?; }
    pub fn bler(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bler, null, v, w).?; }
    pub fn blei(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_blei, null, v, w).?; }
    pub fn bler_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bler_u, null, v, w).?; }
    pub fn blei_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_blei_u, null, v, w).?; }
    pub fn beqr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_beqr, null, v, w).?; }
    pub fn beqi(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_beqi, null, v, w).?; }
    pub fn bger(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bger, null, v, w).?; }
    pub fn bgei(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgei, null, v, w).?; }
    pub fn bger_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bger_u, null, v, w).?; }
    pub fn bgei_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgei_u, null, v, w).?; }
    pub fn bgtr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgtr, null, v, w).?; }
    pub fn bgti(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgti, null, v, w).?; }
    pub fn bgtr_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgtr_u, null, v, w).?; }
    pub fn bgti_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgti_u, null, v, w).?; }
    pub fn bner(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bner, null, v, w).?; }
    pub fn bnei(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bnei, null, v, w).?; }
    pub fn bmsr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bmsr, null, v, w).?; }
    pub fn bmsi(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bmsi, null, v, w).?; }
    pub fn bmcr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bmcr, null, v, w).?; }
    pub fn bmci(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bmci, null, v, w).?; }
    pub fn boaddr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_boaddr, null, v, w).?; }
    pub fn boaddi(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_boaddi, null, v, w).?; }
    pub fn boaddr_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_boaddr_u, null, v, w).?; }
    pub fn boaddi_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_boaddi_u, null, v, w).?; }
    pub fn bxaddr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxaddr, null, v, w).?; }
    pub fn bxaddi(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxaddi, null, v, w).?; }
    pub fn bxaddr_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxaddr_u, null, v, w).?; }
    pub fn bxaddi_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxaddi_u, null, v, w).?; }
    pub fn bosubr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bosubr, null, v, w).?; }
    pub fn bosubi(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bosubi, null, v, w).?; }
    pub fn bosubr_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bosubr_u, null, v, w).?; }
    pub fn bosubi_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bosubi_u, null, v, w).?; }
    pub fn bxsubr(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxsubr, null, v, w).?; }
    pub fn bxsubi(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxsubi, null, v, w).?; }
    pub fn bxsubr_u(self: State, v: Gpr, w: Gpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxsubr_u, null, v, w).?; }
    pub fn bxsubi_u(self: State, v: Gpr, w: Word) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bxsubi_u, null, v, w).?; }

    // ---- Jump and call ----

    pub fn jmpr(self: State, u: Gpr) *Node { return c._jit_new_node_w(self.ptr, c.jit_code_jmpr, u).?; }
    pub fn jmpi(self: State) *Node { return c._jit_new_node_p(self.ptr, c.jit_code_jmpi, null).?; }
    pub fn callr(self: State, u: Gpr) *Node { return c._jit_new_node_w(self.ptr, c.jit_code_callr, u).?; }
    pub fn calli(self: State, ptr: Pointer) *Node { return c._jit_new_node_p(self.ptr, c.jit_code_calli, ptr).?; }

    // ---- Float f32 ----

    pub fn addr_f(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addr_f, u, v, w).?; }
    pub fn subr_f(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subr_f, u, v, w).?; }
    pub fn mulr_f(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_mulr_f, u, v, w).?; }
    pub fn divr_f(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_divr_f, u, v, w).?; }
    pub fn negr_f(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_negr_f, u, v).?; }
    pub fn absr_f(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_absr_f, u, v).?; }
    pub fn sqrtr_f(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_sqrtr_f, u, v).?; }
    pub fn movr_f(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movr_f, u, v).?; }
    pub fn movi_f(self: State, u: Fpr, v: f32) *Node { return c._jit_new_node_wf(self.ptr, c.jit_code_movi_f, u, v).?; }
    pub fn extr_f(self: State, u: Fpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_f, u, v).?; }
    pub fn extr_d_f(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_d_f, u, v).?; }
    pub fn truncr_f_i(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_truncr_f_i, u, v).?; }
    pub fn truncr_f_l(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_truncr_f_l, u, v).?; }
    pub fn ltr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ltr_f, u, v, w).?; }
    pub fn ler_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ler_f, u, v, w).?; }
    pub fn eqr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_eqr_f, u, v, w).?; }
    pub fn ger_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ger_f, u, v, w).?; }
    pub fn gtr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gtr_f, u, v, w).?; }
    pub fn ner_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ner_f, u, v, w).?; }
    pub fn ldr_f(self: State, u: Fpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_f, u, v).?; }
    pub fn ldi_f(self: State, u: Fpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_f, u, v).?; }
    pub fn ldxr_f(self: State, u: Fpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_f, u, v, w).?; }
    pub fn ldxi_f(self: State, u: Fpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_f, u, v, w).?; }
    pub fn str_f(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_str_f, u, v).?; }
    pub fn sti_f(self: State, u: Pointer, v: Fpr) *Node { return c._jit_new_node_pw(self.ptr, c.jit_code_sti_f, u, v).?; }
    pub fn stxr_f(self: State, u: Gpr, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxr_f, u, v, w).?; }
    pub fn stxi_f(self: State, u: Word, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxi_f, u, v, w).?; }
    pub fn bltr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bltr_f, null, v, w).?; }
    pub fn bler_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bler_f, null, v, w).?; }
    pub fn beqr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_beqr_f, null, v, w).?; }
    pub fn bger_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bger_f, null, v, w).?; }
    pub fn bgtr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgtr_f, null, v, w).?; }
    pub fn bner_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bner_f, null, v, w).?; }
    pub fn bunordr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunordr_f, null, v, w).?; }

    // ---- Float f64 ----

    pub fn addr_d(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_addr_d, u, v, w).?; }
    pub fn subr_d(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_subr_d, u, v, w).?; }
    pub fn mulr_d(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_mulr_d, u, v, w).?; }
    pub fn divr_d(self: State, u: Fpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_divr_d, u, v, w).?; }
    pub fn negr_d(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_negr_d, u, v).?; }
    pub fn absr_d(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_absr_d, u, v).?; }
    pub fn sqrtr_d(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_sqrtr_d, u, v).?; }
    pub fn movr_d(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movr_d, u, v).?; }
    pub fn movi_d(self: State, u: Fpr, v: f64) *Node { return c._jit_new_node_wd(self.ptr, c.jit_code_movi_d, u, v).?; }
    pub fn extr_d(self: State, u: Fpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_d, u, v).?; }
    pub fn extr_f_d(self: State, u: Fpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_extr_f_d, u, v).?; }
    pub fn truncr_d_i(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_truncr_d_i, u, v).?; }
    pub fn truncr_d_l(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_truncr_d_l, u, v).?; }
    pub fn ltr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ltr_d, u, v, w).?; }
    pub fn ler_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ler_d, u, v, w).?; }
    pub fn eqr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_eqr_d, u, v, w).?; }
    pub fn ger_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ger_d, u, v, w).?; }
    pub fn gtr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_gtr_d, u, v, w).?; }
    pub fn ner_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ner_d, u, v, w).?; }
    pub fn ldr_d(self: State, u: Fpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_ldr_d, u, v).?; }
    pub fn ldi_d(self: State, u: Fpr, v: Pointer) *Node { return c._jit_new_node_wp(self.ptr, c.jit_code_ldi_d, u, v).?; }
    pub fn ldxr_d(self: State, u: Fpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxr_d, u, v, w).?; }
    pub fn ldxi_d(self: State, u: Fpr, v: Gpr, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ldxi_d, u, v, w).?; }
    pub fn str_d(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_str_d, u, v).?; }
    pub fn sti_d(self: State, u: Pointer, v: Fpr) *Node { return c._jit_new_node_pw(self.ptr, c.jit_code_sti_d, u, v).?; }
    pub fn stxr_d(self: State, u: Gpr, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxr_d, u, v, w).?; }
    pub fn stxi_d(self: State, u: Word, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_stxi_d, u, v, w).?; }
    pub fn bltr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bltr_d, null, v, w).?; }
    pub fn bler_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bler_d, null, v, w).?; }
    pub fn beqr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_beqr_d, null, v, w).?; }
    pub fn bger_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bger_d, null, v, w).?; }
    pub fn bgtr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bgtr_d, null, v, w).?; }
    pub fn bner_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bner_d, null, v, w).?; }
    pub fn bunordr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunordr_d, null, v, w).?; }

    pub fn retval_f(self: State, reg: Fpr) void { c._jit_retval_f(self.ptr, reg); }
    pub fn retval_d(self: State, reg: Fpr) void { c._jit_retval_d(self.ptr, reg); }

    // ---- Float f32 immediate arithmetic ----

    pub fn addi_f(self: State, u: Fpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_addi_f, u, v, w).?; }
    pub fn subi_f(self: State, u: Fpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_subi_f, u, v, w).?; }
    pub fn rsbi_f(self: State, u: Fpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_rsbi_f, u, v, w).?; }
    pub fn muli_f(self: State, u: Fpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_muli_f, u, v, w).?; }
    pub fn divi_f(self: State, u: Fpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_divi_f, u, v, w).?; }
    pub fn negi_f(self: State, u: Fpr, v: f32) void { c._jit_negi_f(self.ptr, u, v); }
    pub fn absi_f(self: State, u: Fpr, v: f32) void { c._jit_absi_f(self.ptr, u, v); }
    pub fn sqrti_f(self: State, u: Fpr, v: f32) void { c._jit_sqrti_f(self.ptr, u, v); }

    // ---- Float f32 immediate comparison ----

    pub fn lti_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_lti_f, u, v, w).?; }
    pub fn lei_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_lei_f, u, v, w).?; }
    pub fn eqi_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_eqi_f, u, v, w).?; }
    pub fn gei_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_gei_f, u, v, w).?; }
    pub fn gti_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_gti_f, u, v, w).?; }
    pub fn nei_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_nei_f, u, v, w).?; }
    pub fn unltr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unltr_f, u, v, w).?; }
    pub fn unlti_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_unlti_f, u, v, w).?; }
    pub fn unler_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unler_f, u, v, w).?; }
    pub fn unlei_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_unlei_f, u, v, w).?; }
    pub fn uneqr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_uneqr_f, u, v, w).?; }
    pub fn uneqi_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_uneqi_f, u, v, w).?; }
    pub fn unger_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unger_f, u, v, w).?; }
    pub fn ungei_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_ungei_f, u, v, w).?; }
    pub fn ungtr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ungtr_f, u, v, w).?; }
    pub fn ungti_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_ungti_f, u, v, w).?; }
    pub fn ltgtr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ltgtr_f, u, v, w).?; }
    pub fn ltgti_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_ltgti_f, u, v, w).?; }
    pub fn ordr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ordr_f, u, v, w).?; }
    pub fn ordi_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_ordi_f, u, v, w).?; }
    pub fn unordi_f(self: State, u: Gpr, v: Fpr, w: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_unordi_f, u, v, w).?; }
    pub fn unordr_f(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unordr_f, u, v, w).?; }

    // ---- Float f32 immediate branches ----

    pub fn blti_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_blti_f, null, v, w).?; }
    pub fn blei_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_blei_f, null, v, w).?; }
    pub fn beqi_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_beqi_f, null, v, w).?; }
    pub fn bgei_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bgei_f, null, v, w).?; }
    pub fn bgti_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bgti_f, null, v, w).?; }
    pub fn bnei_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bnei_f, null, v, w).?; }
    pub fn bunltr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunltr_f, null, v, w).?; }
    pub fn bunlti_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bunlti_f, null, v, w).?; }
    pub fn bunler_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunler_f, null, v, w).?; }
    pub fn bunlei_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bunlei_f, null, v, w).?; }
    pub fn buneqr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_buneqr_f, null, v, w).?; }
    pub fn buneqi_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_buneqi_f, null, v, w).?; }
    pub fn bunger_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunger_f, null, v, w).?; }
    pub fn bungei_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bungei_f, null, v, w).?; }
    pub fn bungtr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bungtr_f, null, v, w).?; }
    pub fn bungti_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bungti_f, null, v, w).?; }
    pub fn bltgtr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bltgtr_f, null, v, w).?; }
    pub fn bltgti_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bltgti_f, null, v, w).?; }
    pub fn bordr_f(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bordr_f, null, v, w).?; }
    pub fn bordi_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bordi_f, null, v, w).?; }
    pub fn bunordi_f(self: State, v: Fpr, w: f32) *Node { return c._jit_new_node_pwf(self.ptr, c.jit_code_bunordi_f, null, v, w).?; }

    // ---- Float f64 immediate arithmetic ----

    pub fn addi_d(self: State, u: Fpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_addi_d, u, v, w).?; }
    pub fn subi_d(self: State, u: Fpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_subi_d, u, v, w).?; }
    pub fn rsbi_d(self: State, u: Fpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_rsbi_d, u, v, w).?; }
    pub fn muli_d(self: State, u: Fpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_muli_d, u, v, w).?; }
    pub fn divi_d(self: State, u: Fpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_divi_d, u, v, w).?; }
    pub fn negi_d(self: State, u: Fpr, v: f64) void { c._jit_negi_d(self.ptr, u, v); }
    pub fn absi_d(self: State, u: Fpr, v: f64) void { c._jit_absi_d(self.ptr, u, v); }
    pub fn sqrti_d(self: State, u: Fpr, v: f64) void { c._jit_sqrti_d(self.ptr, u, v); }

    // ---- Float f64 immediate comparison ----

    pub fn lti_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_lti_d, u, v, w).?; }
    pub fn lei_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_lei_d, u, v, w).?; }
    pub fn eqi_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_eqi_d, u, v, w).?; }
    pub fn gei_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_gei_d, u, v, w).?; }
    pub fn gti_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_gti_d, u, v, w).?; }
    pub fn nei_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_nei_d, u, v, w).?; }
    pub fn unltr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unltr_d, u, v, w).?; }
    pub fn unlti_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_unlti_d, u, v, w).?; }
    pub fn unler_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unler_d, u, v, w).?; }
    pub fn unlei_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_unlei_d, u, v, w).?; }
    pub fn uneqr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_uneqr_d, u, v, w).?; }
    pub fn uneqi_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_uneqi_d, u, v, w).?; }
    pub fn unger_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unger_d, u, v, w).?; }
    pub fn ungei_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_ungei_d, u, v, w).?; }
    pub fn ungtr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ungtr_d, u, v, w).?; }
    pub fn ungti_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_ungti_d, u, v, w).?; }
    pub fn ltgtr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ltgtr_d, u, v, w).?; }
    pub fn ltgti_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_ltgti_d, u, v, w).?; }
    pub fn ordr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_ordr_d, u, v, w).?; }
    pub fn ordi_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_ordi_d, u, v, w).?; }
    pub fn unordi_d(self: State, u: Gpr, v: Fpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_unordi_d, u, v, w).?; }
    pub fn unordr_d(self: State, u: Gpr, v: Fpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_unordr_d, u, v, w).?; }

    // ---- Float f64 immediate branches ----

    pub fn blti_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_blti_d, null, v, w).?; }
    pub fn blei_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_blei_d, null, v, w).?; }
    pub fn beqi_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_beqi_d, null, v, w).?; }
    pub fn bgei_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bgei_d, null, v, w).?; }
    pub fn bgti_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bgti_d, null, v, w).?; }
    pub fn bnei_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bnei_d, null, v, w).?; }
    pub fn bunltr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunltr_d, null, v, w).?; }
    pub fn bunlti_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bunlti_d, null, v, w).?; }
    pub fn bunler_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunler_d, null, v, w).?; }
    pub fn bunlei_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bunlei_d, null, v, w).?; }
    pub fn buneqr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_buneqr_d, null, v, w).?; }
    pub fn buneqi_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_buneqi_d, null, v, w).?; }
    pub fn bunger_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bunger_d, null, v, w).?; }
    pub fn bungei_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bungei_d, null, v, w).?; }
    pub fn bungtr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bungtr_d, null, v, w).?; }
    pub fn bungti_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bungti_d, null, v, w).?; }
    pub fn bltgtr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bltgtr_d, null, v, w).?; }
    pub fn bltgti_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bltgti_d, null, v, w).?; }
    pub fn bordr_d(self: State, v: Fpr, w: Fpr) *Node { return c._jit_new_node_pww(self.ptr, c.jit_code_bordr_d, null, v, w).?; }
    pub fn bordi_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bordi_d, null, v, w).?; }
    pub fn bunordi_d(self: State, v: Fpr, w: f64) *Node { return c._jit_new_node_pwd(self.ptr, c.jit_code_bunordi_d, null, v, w).?; }

    // ---- Fused multiply-add/sub (dst, src1, src2, src3/imm) ----

    pub fn fmar_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fmar_f, u, v, w, x).?; }
    pub fn fmsr_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fmsr_f, u, v, w, x).?; }
    pub fn fnmar_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fnmar_f, u, v, w, x).?; }
    pub fn fnmsr_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fnmsr_f, u, v, w, x).?; }
    pub fn fmai_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: f32) void { c._jit_fmai_f(self.ptr, u, v, w, x); }
    pub fn fmsi_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: f32) void { c._jit_fmsi_f(self.ptr, u, v, w, x); }
    pub fn fnmai_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: f32) void { c._jit_fnmai_f(self.ptr, u, v, w, x); }
    pub fn fnmsi_f(self: State, u: Fpr, v: Fpr, w: Fpr, x: f32) void { c._jit_fnmsi_f(self.ptr, u, v, w, x); }
    pub fn fmar_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fmar_d, u, v, w, x).?; }
    pub fn fmsr_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fmsr_d, u, v, w, x).?; }
    pub fn fnmar_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fnmar_d, u, v, w, x).?; }
    pub fn fnmsr_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: Fpr) *Node { return c._jit_new_node_wqw(self.ptr, c.jit_code_fnmsr_d, u, v, w, x).?; }
    pub fn fmai_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: f64) void { c._jit_fmai_d(self.ptr, u, v, w, x); }
    pub fn fmsi_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: f64) void { c._jit_fmsi_d(self.ptr, u, v, w, x); }
    pub fn fnmai_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: f64) void { c._jit_fnmai_d(self.ptr, u, v, w, x); }
    pub fn fnmsi_d(self: State, u: Fpr, v: Fpr, w: Fpr, x: f64) void { c._jit_fnmsi_d(self.ptr, u, v, w, x); }

    // ---- Float/int move reinterpretations ----

    pub fn movr_w_f(self: State, u: Fpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movr_w_f, u, v).?; }
    pub fn movi_w_f(self: State, u: Fpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movi_w_f, u, v).?; }
    pub fn movr_f_w(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movr_f_w, u, v).?; }
    pub fn movi_f_w(self: State, u: Gpr, v: f32) *Node { return c._jit_new_node_wwf(self.ptr, c.jit_code_movi_f_w, u, v, 0).?; }
    pub fn movr_ww_d(self: State, u: Fpr, v: Gpr, w: Gpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_movr_ww_d, u, v, w).?; }
    pub fn movi_ww_d(self: State, u: Fpr, v: Word, w: Word) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_movi_ww_d, u, v, w).?; }
    pub fn movr_d_ww(self: State, u: Gpr, v: Gpr, w: Fpr) *Node { return c._jit_new_node_www(self.ptr, c.jit_code_movr_d_ww, u, v, w).?; }
    pub fn movi_d_ww(self: State, u: Gpr, v: Gpr, w: f64) *Node { return c._jit_new_node_wwd(self.ptr, c.jit_code_movi_d_ww, u, v, w).?; }
    pub fn movr_w_d(self: State, u: Fpr, v: Gpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movr_w_d, u, v).?; }
    pub fn movi_w_d(self: State, u: Fpr, v: Word) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movi_w_d, u, v).?; }
    pub fn movr_d_w(self: State, u: Gpr, v: Fpr) *Node { return c._jit_new_node_ww(self.ptr, c.jit_code_movr_d_w, u, v).?; }
    pub fn movi_d_w(self: State, u: Gpr, v: f64) *Node { return c._jit_new_node_wd(self.ptr, c.jit_code_movi_d_w, u, v).?; }
};
