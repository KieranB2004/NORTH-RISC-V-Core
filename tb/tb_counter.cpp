#include "Vcounter.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);

    // Enable waveform tracing
    Verilated::traceEverOn(true);

    // Create simulated hardware
    Vcounter *dut = new Vcounter;

    // Create waveform file
    VerilatedVcdC *trace = new VerilatedVcdC;

    dut->trace(trace, 99);
    trace->open("counter.vcd");

    vluint64_t time = 0;

    // Reset sequence
    dut->reset = 1;

    for (int i = 0; i < 20; i++)
    {
        // Clock low
        dut->clk = 0;
        dut->eval();
        trace->dump(time++);

        // Clock high
        dut->clk = 1;
        dut->eval();
        trace->dump(time++);

        // Release reset
        if (i == 2)
            dut->reset = 0;
    }

    trace->close();

    delete trace;
    delete dut;

    return 0;
}