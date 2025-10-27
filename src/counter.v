/*
    Simple counter with fixed bitwidth of 7.
    Depending on two input signals the counter can count up or down.
    The counter value is hold inbetween 0-99 because thats the displayable area.
*/

module counter
#(
    parameter BW = 7 // 7 Bit = 0-127 | optional parameter
) (
    // define inputs and outputs of module
    input    clk_i,      // clock signal for counting
    input    mod_i,        // mode: 1=up, 0=down
    input    rst_i, 
    output wire [BW-1:0] counter_val_o
);
    
    // register to store the counter value
    reg [BW-1:0] counter_val;
    
    // Single always block for both counting directions
    /*
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            counter_val <= {BW{1'b0}}; // reset the counter value
        end else begin
            // check counting mode
            if (mod_i == 1'b1) begin
                // counting UP - check upper limit
                if (counter_val < 7'd99) begin
                    counter_val <= counter_val + 1; // increment
                end
                    // otherwise stay at 99
            end else begin
                // counting DOWN - check lower limit
                if (counter_val > 7'd0) begin
                    counter_val <= counter_val - 1; // decrement
                end
                    // otherwise stay at 0
            end
        end
    end
    */
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            counter_val <= {BW{1'b0}}; // reset the counter value
        end else begin
            // check counting mode
            if (mod_i == 1'b1) begin
                counter_val <= counter_val + {{(BW-1){1'b0}}, 1'b1};
            end else begin
                counter_val <= counter_val - {{(BW-1){1'b0}}, 1'b1};
            end
        end
    end
        
    
    // assign counter value
    assign counter_val_o = counter_val;
endmodule
