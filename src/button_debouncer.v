`default_nettype none

module button_debouncer (
    input  wire clk_i,
    input  wire rst_i,
    input  wire button_i,
    output reg  button_db_o
);

    reg [19:0] debounce_counter;
    reg button_prev;
    
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            button_db_o <= 1'b0;
            debounce_counter <= 20'd0;
            button_prev <= 1'b0;
        end else begin
            button_prev <= button_i;
            
            if (button_prev != button_i) begin
                debounce_counter <= 20'd0;
            end else if (debounce_counter < 20'd100000) begin // ~10ms debounce
                debounce_counter <= debounce_counter + 20'd1;
            end else begin
                button_db_o <= button_i;
            end
        end
    end

endmodule
