// -----------------------------------------------------------------------
// pc.sv — Program Counter register, Phase 1 scalar core
// -----------------------------------------------------------------------
//
// Original work for this project (docs/00_project_charter.md, Phase 1).
// No third-party source reproduced. Conceptual grounding drawn from the
// RISC-V Unprivileged ISA spec (control-transfer instructions, Sec. 2.5)
// and RISC-V Privileged ISA spec (reset behaviour, Ch. 3.4) — see
// docs/references.md for full citations, per the attribution practice
// this project follows under LICENSE.md Section 11.
//
// WHAT THIS MODULE IS
//   The PC is the one piece of architectural state that exists before
//   there is even an instruction to execute: it is what tells the fetch
//   logic which address to read next. Every other fetch-related module
//   we build (instruction memory, branch/jump resolution) exists to
//   compute the *next* value this register should hold.
//
// DESIGN DECISIONS AND WHY
//   - Synchronous reset. Registering reset synchronously (checked only
//     on a clock edge, inside always_ff) rather than asynchronously is
//     the convention used by lowRISC's Ibex and OpenHW's CVA6 style
//     guides, because asynchronous resets can complicate static timing
//     analysis and reset-recovery/removal checks in FPGA and ASIC flows.
//     There is only one clock domain in Phase 1, so nothing is lost by
//     this choice, and it is one fewer non-standard timing path to
//     explain later when this design is synthesized.
//   - pc_next is a plain input, computed OUTSIDE this module, not derived
//     in here. The PC register itself does not decide *why* the next
//     address is what it is (sequential fetch, taken branch, jump, trap
//     vector) — that decision belongs entirely to logic built on top of
//     this module. Keeping control decisions out of datapath registers
//     is a principle you will see again, at larger scale, in the
//     hazard/forwarding unit once the pipeline exists: a register should
//     hold state, not decide policy.
//   - RESET_VECTOR is a parameter, not a hard-coded constant, because the
//     real reset address depends on where the boot ROM ends up living in
//     the memory map (docs/04_memory_map.md, not finalized yet — the
//     RISC-V Privileged spec deliberately leaves the reset PC
//     implementation-defined). Parameterizing it now means the later
//     integration step is "set one value," not "edit this file."
//   - XLEN is a parameter so the same file serves an RV32 or RV64 build
//     without modification. docs/01_architecture_mvp.md records XLEN=32
//     as the current Phase 1 decision and explains why.
//
// TESTED BY
//   sim/cocotb/pc/test_pc.py — reset value, sequential increment,
//   stall-holds-value, and arbitrary-redirect behaviour.
// -----------------------------------------------------------------------

module pc #(
    parameter int XLEN = 32,
    parameter logic [XLEN-1:0] RESET_VECTOR = '0
) (
    input  logic            clk,      // Core clock
    input  logic            rst_n,    // Active-low synchronous reset
    input  logic            stall,    // Hold current PC (e.g. a later stage is not ready)
    input  logic [XLEN-1:0] pc_next,  // Address to adopt on the next clock edge, when not stalled
    output logic [XLEN-1:0] pc_out    // Current program counter value, valid this cycle
);

    // The only state this module owns: the architectural PC register.
    logic [XLEN-1:0] pc_q;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Synchronous reset: on a rising edge sampled with rst_n low,
            // force PC back to the reset vector. This models the state
            // of the core at power-on / external reset, before any
            // instruction has been fetched.
            pc_q <= RESET_VECTOR;
        end else if (!stall) begin
            // Normal operation: adopt whatever address upstream logic
            // has decided is next. This module has no opinion on
            // whether that is pc_q+4, a branch target, a jump target,
            // or a trap vector.
            pc_q <= pc_next;
        end
        // else (stall == 1, rst_n == 1): hold pc_q by simply not
        // assigning it this cycle. No explicit "else" branch is needed;
        // an unassigned always_ff register retains its value, which is
        // exactly the semantics we want, but the comment is left here so
        // the omission reads as intentional rather than forgotten.
    end

    // Combinational read-out of current PC, kept as a separate signal
    // (rather than exposing pc_q directly) so the internal register name
    // can change later without touching this module's external contract.
    assign pc_out = pc_q;

endmodule
