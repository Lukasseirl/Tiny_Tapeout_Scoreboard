`default_nettype none

module scoreboard_simple_controller (
    input  wire clk_i,
    input  wire rst_i,
    input  wire p1_button_i,
    input  wire p2_button_i,
    output wire [7:0] p1_score_o,
    output wire [7:0] p2_score_o
);

    // Debounced buttons
    wire p1_button_db;
    wire p2_button_db;
    
    // Button press detection
    wire p1_press_short;
    wire p1_press_long;
    wire p2_press_short;
    wire p2_press_long;
    
    // Internal scores
    reg [7:0] p1_score_reg;
    reg [7:0] p2_score_reg;
    
    // Instantiate debouncers
    button_debouncer debouncer_p1 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .button_i(p1_button_i),
        .button_db_o(p1_button_db)
    );
    
    button_debouncer debouncer_p2 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .button_i(p2_button_i),
        .button_db_o(p2_button_db)
    );
    
    // Instantiate long press detectors
    long_press_detector long_press_p1 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .button_i(p1_button_db),
        .press_short_o(p1_press_short),
        .press_long_o(p1_press_long)
    );
    
    long_press_detector long_press_p2 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .button_i(p2_button_db),
        .press_short_o(p2_press_short),
        .press_long_o(p2_press_long)
    );
    
    // Simple score update logic
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            p1_score_reg <= 8'd0;
            p2_score_reg <= 8'd0;
        end else begin
            // Player 1 score update
            if (p1_press_short) begin
                // Increment by 1, max 99
                p1_score_reg <= (p1_score_reg >= 99) ? 8'd99 : p1_score_reg + 8'd1;
            end else if (p1_press_long) begin
                // Decrement by 1, min 0
                p1_score_reg <= (p1_score_reg == 0) ? 8'd0 : p1_score_reg - 8'd1;
            end
            
            // Player 2 score update
            if (p2_press_short) begin
                // Increment by 1, max 99
                p2_score_reg <= (p2_score_reg >= 99) ? 8'd99 : p2_score_reg + 8'd1;
            end else if (p2_press_long) begin
                // Decrement by 1, min 0
                p2_score_reg <= (p2_score_reg == 0) ? 8'd0 : p2_score_reg - 8'd1;
            end
        end
    end
    
    // Limit scores to 0-99 range and assign outputs
    assign p1_score_o = (p1_score_reg > 99) ? 8'd99 : p1_score_reg;
    assign p2_score_o = (p2_score_reg > 99) ? 8'd99 : p2_score_reg;

endmodule
