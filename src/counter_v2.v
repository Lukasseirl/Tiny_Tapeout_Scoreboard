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
    input    clk_up_i,      // signal for counting up
    input    clk_down_i,    // signal for counting down
    input    rst_i, 
    output wire [BW-1:0] counter_val_o
);
    
    // register to store the counter value
    reg [BW-1:0] counter_val;

    // always block for counting up
    always @(posedge clk_up_i) begin
        if (rst_i == 1'b1) begin
            counter_val <= {BW{1'b0}}; // reset the counter value
        end else begin
          // heck lower limit
          if (counter_val < 99) begin
            counter_val <= counter_val + 1; // increment
          end
            // otherwise stay at 99
        end
    end

     // always block for counting down
    always @(posedge clk_down_i) begin
        if (rst_i == 1'b1) begin
            counter_val <= {BW{1'b0}}; // reset the counter value
        end else begin
          // check lower limit
          if (counter_val > 0) begin
            counter_val <= counter_val - 1; // decrement
          end
            // otherwise stay at 0
        end
    end
    
    // assign counter value
    assign counter_val_o = counter_val;
endmodule
