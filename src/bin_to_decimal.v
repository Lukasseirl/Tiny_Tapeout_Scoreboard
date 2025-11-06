`default_nettype none
`ifndef __BIN_TO_DECIMAL__
`define __BIN_TO_DECIMAL__

module bin_to_decimal (
    input  wire [6:0]  bin_i,
    output wire  [3:0]  tens_o,
    output wire  [3:0]  ones_o
);
    
    wire [6:0] tens_full = (bin_i / 7'd10) % 7'd10;
    wire [6:0] ones_full = bin_i % 7'd10;
    
    assign tens_o = tens_full[3:0];
    assign ones_o = ones_full[3:0];

endmodule
`endif
`default_nettype wire


/* DOUBBLE-DABBLE

//------------------------------------------------------------------------------
//  Binary to BCD (Tens and Ones) Converter using Double-Dabble
//  Converts an 7-bit binary number into decimal tens and ones.
//------------------------------------------------------------------------------

`default_nettype none
`ifndef __BIN_TO_DECIMAL__
`define __BIN_TO_DECIMAL__

module bin_to_decimal (
    input  wire        clk_i,
    input  wire        rst_i,
    input  wire [6:0]  bin_i,
    output reg  [3:0]  tens_o,
    output reg  [3:0]  ones_o
);

    // State definitions
    localparam IDLE  = 2'b00;
    localparam SHIFT = 2'b01;
    localparam ADD   = 2'b10;
    localparam DONE  = 2'b11;

    // Internal registers
    reg [1:0] state;
    reg [3:0] count;
    reg [6:0] bin_reg;
    reg [11:0] bcd_reg;   // 3 BCD digits (hundreds, tens, ones)

    always @(posedge clk_i) begin
        if (rst_i) begin
            // Reset all registers
            state   <= IDLE;
            count   <= 4'b0;
            bin_reg <= 7'b0;
            bcd_reg <= 12'b0;
            tens_o  <= 4'b0;
            ones_o  <= 4'b0;
        end else begin
            case (state)
                IDLE: begin
                    bin_reg <= bin_i;
                    bcd_reg <= 12'b0;
                    count   <= 4'b0;
                    state   <= ADD;
                end
            
                ADD: begin
                    // Add 3 if >=5 before shifting
                    if (bcd_reg[3:0] >= 5)
                        bcd_reg[3:0] <= bcd_reg[3:0] + 3;
                    if (bcd_reg[7:4] >= 5)
                        bcd_reg[7:4] <= bcd_reg[7:4] + 3;
                    if (bcd_reg[11:8] >= 5)
                        bcd_reg[11:8] <= bcd_reg[11:8] + 3;
            
                    state <= SHIFT;
                end
            
                SHIFT: begin
                    // Shift left
                    bcd_reg <= {bcd_reg[10:0], bin_reg[6]};
                    bin_reg <= {bin_reg[5:0], 1'b0};
            
                    if (count == 4'd6)
                        state <= DONE;
                    else begin
                        count <= count + 1;
                        state <= ADD;
                    end
                end
            
                DONE: begin
                    tens_o <= bcd_reg[7:4];
                    ones_o <= bcd_reg[3:0];
                    state  <= IDLE;
                end
            endcase
        end
    end

endmodule
`endif
`default_nettype wire

*/
