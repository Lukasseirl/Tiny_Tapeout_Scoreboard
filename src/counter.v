/*
    Simple counter with fixed bitwidth of 7.
    The counter value is hold inbetween 0-99 because thats the displayable area
*/

module counter
#(
    parameter BW = 7 // 7 Bit = 0-127 | optional parameter
) (
    // define inputs and outputs of module
    input    clk_i,
    input    rst_i, 
    output wire [BW-1:0] counter_val_o
);

// register to store the counter value
reg [BW-1:0] counter_val;

// gets active when a positive edge of clock signal occours
always @(posedge clk_i) begin
    if (rst_i == 1'b1) begin
        // if reset is enabled => counter gets reset
        counter_val <= 7'b0;
    end else begin
        // Prüfen ob nächster Wert 100 wäre
        if (counter_val >= 7'd99) begin
            counter_val <= 7'b0;
        end else begin
            counter_val <= counter_val + 1'b1;
        end
    end
end

assign counter_val_o = counter_val;

endmodule
