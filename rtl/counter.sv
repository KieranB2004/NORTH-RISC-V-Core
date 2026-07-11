module counter (
    input logic clk,
    input logic reset,
    output logic [7:0] count
);

always_ff @(posedge clk) begin
    if (reset)
        count <= 8'b0;
    else
        count <= count + 1'b1;
end


// Verification assertion
property reset_clears_counter;
    @(posedge clk)
    reset |-> count == 0;
endproperty

assert property(reset_clears_counter);

endmodule