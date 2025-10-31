//------------------------------------------------------------------------------
//  Binary to BCD (Tens and Ones) Converter
//  Converts an 8-bit binary number into decimal tens and ones.
//------------------------------------------------------------------------------

`default_nettype none
`ifndef __BIN_TO_DECIMAL__
`define __BIN_TO_DECIMAL__

module bin_to_decimal (
    // define I/O's of the module
    input  wire              clk_i,   // clock
    input  wire              rst_i,   // reset (active high)
    input  wire [7:0]     bin_i,   // binary input value
    output reg  [3:0]        tens_o,  // decimal tens output
    output reg  [3:0]        ones_o   // decimal ones output
);

    // internal register for computation
    integer i;
    reg [19:0] shift; // temporary register for shift-add-3 algorithm

    // main process block
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            // reset all outputs and internal registers
            shift   <= {20{1'b0}};
            tens_o  <= 4'd0;
            ones_o  <= 4'd0;
        end else begin
            // initialize shift register with input value
            shift = 0;
            shift[7:0] = bin_i;

            // double dabble algorithm
            for (i = 0; i < 8; i = i + 1) begin
                if (shift[11:8] >= 5)
                    shift[11:8] = shift[11:8] + 3;
                if (shift[15:12] >= 5)
                    shift[15:12] = shift[15:12] + 3;
                shift = shift << 1;
            end

            // assign result to outputs
            tens_o <= shift[15:12];
            ones_o <= shift[11:8];
        end
    end

endmodule // bin2bcd
`endif
`default_nettype wire
