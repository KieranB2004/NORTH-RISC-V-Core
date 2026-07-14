"""
test_pc.py — cocotb testbench for rtl/core/pc.sv

What this test proves, in order:

  1. test_reset_value — after asserting rst_n low and clocking, pc_out
     must equal RESET_VECTOR (0 for this instantiation).
  2. test_sequential_increment — if the testbench always drives
     pc_next = pc_out + 4 (exactly what the fetch stage will do once it
     exists), pc_out must advance by 4 on every clock edge.
  3. test_stall_holds_pc — while stall=1, pc_out must NOT change, even
     if pc_next is driving a different value. This is what will let a
     later pipeline stage hold fetch in place while, e.g., a multi-cycle
     memory access completes.
  4. test_arbitrary_redirect — with stall=0, pc_out must adopt ANY
     pc_next value, not only pc_out+4. This is intentionally not a
     "branch" test in the ISA sense (there is no branch/jump decode yet);
     it exists to prove this module carries no hidden assumption that
     pc_next is always sequential. If it did, every future branch and
     jump would silently fail once built on top of it.

Run with:
    cd sim/cocotb/pc && make
    cd sim/cocotb/pc && make WAVES=1   # also writes a waveform for GTKWave/Surfer
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


async def _settle(dut):
    """Wait one simulation delta ("step") past the clock edge that just
    happened, before reading any DUT output.

    Why this is here: with Verilator's cocotb integration, a signal read
    performed in the instant a RisingEdge trigger fires can observe the
    register's value from BEFORE that edge's non-blocking update has been
    applied, not after. Reading one delta later (Timer(1, unit="step"))
    reliably observes the settled, post-edge value, and — unlike
    `await ReadOnly()` — does not lock out writing new stimulus
    afterwards. Confirmed empirically against this exact module before
    writing the assertions below; without this call, every test in this
    file appears to read one clock cycle "behind" reality.
    """
    await Timer(1, unit="step")


async def _start_clock(dut, period_ns=10):
    """Start a free-running clock on dut.clk.

    10 ns period = 100 MHz. This is an arbitrary but convenient
    simulation clock; it has no bearing on the eventual FPGA/ASIC target
    frequency, which will be constrained separately during physical
    implementation (Phase 5 of docs/00_project_charter.md).
    """
    cocotb.start_soon(Clock(dut.clk, period_ns, unit="ns").start())


async def _reset(dut):
    """Drive a clean synchronous reset.

    Holding rst_n low for two clock edges (rather than one) avoids any
    ambiguity about whether reset was actually sampled before we check
    anything, and is good practice for resetting any synchronous design,
    not just this one.
    """
    dut.rst_n.value = 0
    dut.stall.value = 0
    dut.pc_next.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1


@cocotb.test()
async def test_reset_value(dut):
    """After reset, pc_out must equal the RESET_VECTOR parameter (0)."""
    await _start_clock(dut)
    await _reset(dut)
    await RisingEdge(dut.clk)
    await _settle(dut)

    assert int(dut.pc_out.value) == 0, (
        f"Expected pc_out == 0 (RESET_VECTOR) after reset, "
        f"got {int(dut.pc_out.value)}"
    )


@cocotb.test()
async def test_sequential_increment(dut):
    """With stall=0 and pc_next always driven to pc_out+4, pc_out must
    advance by exactly 4 on every clock edge — the normal-operation case
    the fetch stage will rely on for every non-branch instruction."""
    await _start_clock(dut)
    await _reset(dut)
    await RisingEdge(dut.clk)
    await _settle(dut)

    dut.stall.value = 0
    previous_pc = int(dut.pc_out.value)

    for step in range(5):
        dut.pc_next.value = previous_pc + 4
        await RisingEdge(dut.clk)
        await _settle(dut)
        current_pc = int(dut.pc_out.value)
        assert current_pc == previous_pc + 4, (
            f"Step {step}: expected pc_out to advance from "
            f"{previous_pc} to {previous_pc + 4}, got {current_pc}"
        )
        previous_pc = current_pc


@cocotb.test()
async def test_stall_holds_pc(dut):
    """While stall=1, pc_out must not change, regardless of pc_next."""
    await _start_clock(dut)
    await _reset(dut)
    await RisingEdge(dut.clk)
    await _settle(dut)

    held_pc = int(dut.pc_out.value)
    dut.stall.value = 1

    for _ in range(3):
        # Deliberately drive a pc_next that would be obviously wrong if
        # it were ever adopted, so a bug that ignores `stall` is easy
        # to spot rather than accidentally passing by coincidence.
        dut.pc_next.value = held_pc + 1000
        await RisingEdge(dut.clk)
        await _settle(dut)
        assert int(dut.pc_out.value) == held_pc, (
            "pc_out changed while stall was asserted — the stall input "
            "is not being respected"
        )

    dut.stall.value = 0


@cocotb.test()
async def test_arbitrary_redirect(dut):
    """pc_out must adopt any pc_next value, not only pc_out+4 — proof
    this module makes no hidden sequential-fetch assumption that would
    silently break future branch/jump logic."""
    await _start_clock(dut)
    await _reset(dut)
    await RisingEdge(dut.clk)
    await _settle(dut)

    target = 0x0000_1000  # an arbitrary "branch target" for this test
    dut.stall.value = 0
    dut.pc_next.value = target
    await RisingEdge(dut.clk)
    await _settle(dut)

    assert int(dut.pc_out.value) == target, (
        f"Expected pc_out to redirect to {hex(target)}, "
        f"got {hex(int(dut.pc_out.value))}"
    )