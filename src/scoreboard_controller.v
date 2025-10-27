`default_nettype none

module scoreboard_controller (
    input  wire clk_i,
    input  wire rst_i,
    input  wire p1_button_i,
    input  wire p2_button_i,
    input  wire mode_tennis_i,
    input  wire mode_big_steps_i,
    output wire [7:0] p1_score_o,
    output wire [7:0] p2_score_o,
    output wire p1_win_o,
    output wire p2_win_o
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
    
    // Tennis scoring values
    parameter [7:0] SCORE_0  = 8'd0;
    parameter [7:0] SCORE_15 = 8'd1;
    parameter [7:0] SCORE_30 = 8'd2;
    parameter [7:0] SCORE_40 = 8'd3;
    parameter [7:0] SCORE_AD = 8'd4;
    
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
    
    // Score update logic
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            p1_score_reg <= 8'd0;
            p2_score_reg <= 8'd0;
        end else begin
            // Player 1 score update
            if (p1_press_short) begin
                if (mode_big_steps_i) begin
                    p1_score_reg <= (p1_score_reg >= 90) ? 8'd99 : p1_score_reg + 8'd10;
                end else if (mode_tennis_i) begin
                    // Tennis scoring logic for P1
                    case (p1_score_reg)
                        SCORE_0:  p1_score_reg <= SCORE_15;
                        SCORE_15: p1_score_reg <= SCORE_30;
                        SCORE_30: p1_score_reg <= SCORE_40;
                        SCORE_40: begin
                            if (p2_score_reg == SCORE_AD) begin
                                p1_score_reg <= SCORE_40;
                                p2_score_reg <= SCORE_40;
                            end else if (p1_score_reg == SCORE_40 && p2_score_reg == SCORE_40) begin
                                p1_score_reg <= SCORE_AD;
                            end else begin
                                p1_score_reg <= SCORE_40; // Win condition handled separately
                            end
                        end
                        SCORE_AD: p1_score_reg <= SCORE_AD; // Win
                        default:  p1_score_reg <= SCORE_0;
                    endcase
                end else begin
                    // Normal mode - increment by 1
                    p1_score_reg <= (p1_score_reg >= 99) ? 8'd99 : p1_score_reg + 8'd1;
                end
            end else if (p1_press_long) begin
                if (mode_big_steps_i) begin
                    p1_score_reg <= (p1_score_reg <= 10) ? 8'd0 : p1_score_reg - 8'd10;
                end else begin
                    // Decrement by 1, but not below 0
                    p1_score_reg <= (p1_score_reg == 0) ? 8'd0 : p1_score_reg - 8'd1;
                end
            end
            
            // Player 2 score update
            if (p2_press_short) begin
                if (mode_big_steps_i) begin
                    p2_score_reg <= (p2_score_reg >= 90) ? 8'd99 : p2_score_reg + 8'd10;
                end else if (mode_tennis_i) begin
                    // Tennis scoring logic for P2
                    case (p2_score_reg)
                        SCORE_0:  p2_score_reg <= SCORE_15;
                        SCORE_15: p2_score_reg <= SCORE_30;
                        SCORE_30: p2_score_reg <= SCORE_40;
                        SCORE_40: begin
                            if (p1_score_reg == SCORE_AD) begin
                                p1_score_reg <= SCORE_40;
                                p2_score_reg <= SCORE_40;
                            end else if (p1_score_reg == SCORE_40 && p2_score_reg == SCORE_40) begin
                                p2_score_reg <= SCORE_AD;
                            end else begin
                                p2_score_reg <= SCORE_40; // Win condition handled separately
                            end
                        end
                        SCORE_AD: p2_score_reg <= SCORE_AD; // Win
                        default:  p2_score_reg <= SCORE_0;
                    endcase
                end else begin
                    // Normal mode - increment by 1
                    p2_score_reg <= (p2_score_reg >= 99) ? 8'd99 : p2_score_reg + 8'd1;
                end
            end else if (p2_press_long) begin
                if (mode_big_steps_i) begin
                    p2_score_reg <= (p2_score_reg <= 10) ? 8'd0 : p2_score_reg - 8'd10;
                end else begin
                    // Decrement by 1, but not below 0
                    p2_score_reg <= (p2_score_reg == 0) ? 8'd0 : p2_score_reg - 8'd1;
                end
            end
        end
    end
    
    // Win condition detection
    reg p1_win_reg;
    reg p2_win_reg;
    
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            p1_win_reg <= 1'b0;
            p2_win_reg <= 1'b0;
        end else begin
            if (mode_tennis_i) begin
                // Tennis win conditions
                p1_win_reg <= ((p1_score_reg == SCORE_AD) || 
                              (p1_score_reg == SCORE_40 && p2_score_reg != SCORE_40 && p2_score_reg != SCORE_AD));
                p2_win_reg <= ((p2_score_reg == SCORE_AD) || 
                              (p2_score_reg == SCORE_40 && p1_score_reg != SCORE_40 && p1_score_reg != SCORE_AD));
            end else begin
                // Table tennis win conditions
                p1_win_reg <= (p1_score_reg >= 11 && (p1_score_reg - p2_score_reg) >= 2);
                p2_win_reg <= (p2_score_reg >= 11 && (p2_score_reg - p1_score_reg) >= 2);
            end
        end
    end
    
    // Limit scores to 0-99 range
    wire [7:0] p1_score_limited = (p1_score_reg > 99) ? 8'd99 : p1_score_reg;
    wire [7:0] p2_score_limited = (p2_score_reg > 99) ? 8'd99 : p2_score_reg;
    
    assign p1_score_o = p1_score_limited;
    assign p2_score_o = p2_score_limited;
    assign p1_win_o = p1_win_reg;
    assign p2_win_o = p2_win_reg;

endmodule
