/*
    Simple counter with fixed bitwidth of 7.
    Depending on two input signals the counter can count up or down.
    The counter value is hold inbetween 0-99 because thats the displayable area.
*/

module counter_v2
#(
    parameter BW = 7 // 7 Bit = 0-127 | optional parameter
) (
    // define inputs and outputs of module
    input    clk_i,         // general clock signal
    input    clk_up_i,      // signal for counting up
    input    clk_down_i,    // signal for counting down
    input    rst_i, 
    output wire [BW-1:0] counter_val_o
);
    
    // register to store the counter value
    reg [BW-1:0] counter_val;
    
    // edge detection registers
    reg clk_up_i_prev;
    reg clk_down_i_prev;
    
    // edge detection signals
    wire clk_up_edge;
    wire clk_down_edge;

    // edge detection logic
    assign clk_up_edge = (clk_up_i && !clk_up_i_prev);
    assign clk_down_edge = (clk_down_i && !clk_down_i_prev);

    // always block for storing previous values and counting
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            counter_val <= {BW{1'b0}}; // reset the counter value
            clk_up_i_prev <= 1'b0;
            clk_down_i_prev <= 1'b0;
        end else begin
            // store previous values for edge detection
            clk_up_i_prev <= clk_up_i;
            clk_down_i_prev <= clk_down_i;
            
            // count up on rising edge of clk_up_i
            if (clk_up_edge) begin
                if (counter_val < 99) begin
                    counter_val <= counter_val + 1; // increment
                end
                // otherwise stay at 99
            end 
            // count down on rising edge of clk_down_i  
            else if (clk_down_edge) begin
                if (counter_val > 0) begin
                    counter_val <= counter_val - 1; // decrement
                end
                // otherwise stay at 0
            end
        end
    end
    
    // assign counter value
    assign counter_val_o = counter_val;
endmodule
