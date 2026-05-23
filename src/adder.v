module simple_adder (
    input  wire [1:0] a,    // 2-bit input A
    input  wire [1:0] b,    // 2-bit input B
    output wire [2:0] sum   // 3-bit output (to handle the carry)
);

    // The FPGA synthesizes this directly into Look-Up Tables (LUTs)
    assign sum = a + b;

endmodule