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
    output reg  [3:0]  ones_o,
    output reg         ready_o  // Signal when conversion is done
);

    // State definitions
    localparam IDLE  = 2'b00;
    localparam SHIFT = 2'b01;
    localparam ADD   = 2'b10;
    localparam DONE  = 2'b11;

    // Internal registers
    reg [1:0] state;
    reg [3:0] count;      // Need 4 bits for 0-7
    reg [6:0] bin_reg;
    reg [11:0] bcd_reg;   // Need 12 bits for 3 BCD digits (8+4)

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            // Reset all registers
            state   <= IDLE;
            count   <= 4'b0;
            bin_reg <= 7'b0;
            bcd_reg <= 12'b0;
            tens_o  <= 4'b0;
            ones_o  <= 4'b0;
            ready_o <= 1'b0;
        end else begin
            ready_o <= 1'b0;  // Default not ready
            
            case (state)
                IDLE: begin
                    // Initialize registers
                    bin_reg <= bin_i;
                    bcd_reg <= 12'b0;
                    count   <= 4'b0;
                    state   <= SHIFT;
                    ready_o <= 1'b0;
                end

                SHIFT: begin
                    // Shift left: bcd <- bcd & bin_reg[MSB]
                    bcd_reg <= {bcd_reg[10:0], bin_reg[6]};
                    bin_reg <= {bin_reg[5:0], 1'b0};
                    state   <= ADD;
                end

                ADD: begin
                    // Add 3 to BCD digits if >= 5
                    // Check ones digit (bits 3:0)
                    if (bcd_reg[3:0] >= 5)
                        bcd_reg[3:0] <= bcd_reg[3:0] + 3;
                    
                    // Check tens digit (bits 7:4)  
                    if (bcd_reg[7:4] >= 5)
                        bcd_reg[7:4] <= bcd_reg[7:4] + 3;
                    
                    // Check hundreds digit (bits 11:8) - for values 100-127
                    if (bcd_reg[11:8] >= 5)
                        bcd_reg[11:8] <= bcd_reg[11:8] + 3;

                    // Check if done (7 iterations for 7 bits)
                    if (count == 4'd6) begin
                        state <= DONE;
                    end else begin
                        count <= count + 1;
                        state <= SHIFT;
                    end
                end

                DONE: begin
                    // Final shift
                    bcd_reg <= {bcd_reg[10:0], bin_reg[6]};
                    
                    // Extract tens and ones (ignore hundreds for 0-99)
                    tens_o  <= bcd_reg[7:4];
                    ones_o  <= bcd_reg[3:0];
                    ready_o <= 1'b1;
                    state   <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
`endif
`default_nettype wire


/* Old version of double-dabble Code for 7 and 8 Bit Input
//------------------------------------------------------------------------------
//  Binary to BCD (Tens and Ones) Converter
//  Converts an 7-bit binary number into decimal tens and ones.
//------------------------------------------------------------------------------

module bin_to_decimal (
    input  wire              clk_i,
    input  wire              rst_i,
    input  wire [6:0]        bin_i,   // Jetzt 7 Bit statt 8
    output reg  [3:0]        tens_o,
    output reg  [3:0]        ones_o
);

    integer i;
    reg [19:0] shift;

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            shift   <= {20{1'b0}};
            tens_o  <= 4'd0;
            ones_o  <= 4'd0;
        end else begin
            shift = 0;
            shift[6:0] = bin_i;  // Anpassung: 7 Bit statt 8

            // Double Dabble für 7 Bit (8 Iterationen sind immer noch korrekt)
            for (i = 0; i < 8; i = i + 1) begin
                if (shift[11:8] >= 5)
                    shift[11:8] = shift[11:8] + 3;
                if (shift[15:12] >= 5)
                    shift[15:12] = shift[15:12] + 3;
                shift = shift << 1;
            end

            tens_o <= shift[15:12];
            ones_o <= shift[11:8];
        end
    end

endmodule



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
*/
