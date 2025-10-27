`default_nettype none

module display_controller (
    input  wire clk_i,
    input  wire rst_i,
    input  wire [7:0] p1_score_i,
    input  wire [7:0] p2_score_i,
    input  wire p1_win_i,
    input  wire p2_win_i,
    input  wire mode_tennis_i,
    output reg  [3:0] digit_o,
    output reg  [3:0] segment_select_o,
    output wire [2:0] state_o
);

    // State definitions
    localparam STATE_P1_BLINK     = 3'd0;
    localparam STATE_P1_TENS      = 3'd1;
    localparam STATE_P1_ONES      = 3'd2;
    localparam STATE_P2_BLINK     = 3'd3;
    localparam STATE_P2_TENS      = 3'd4;
    localparam STATE_P2_ONES      = 3'd5;
    localparam STATE_P1_WIN_BLINK = 3'd6;
    localparam STATE_P2_WIN_BLINK = 3'd7;
    
    // Timing counters
    reg [23:0] timer;
    reg [2:0]  blink_counter;
    reg [2:0]  current_state;
    reg [2:0]  next_state;
    
    // Score digits
    wire [3:0] p1_tens = p1_score_i / 10;
    wire [3:0] p1_ones = p1_score_i % 10;
    wire [3:0] p2_tens = p2_score_i / 10;
    wire [3:0] p2_ones = p2_score_i % 10;
    
    // Tennis score conversion
    wire [3:0] p1_tennis_display;
    wire [3:0] p2_tennis_display;
    
    tennis_score_display tennis_conv_p1 (
        .score_i(p1_score_i),
        .digit_o(p1_tennis_display)
    );
    
    tennis_score_display tennis_conv_p2 (
        .score_i(p2_score_i),
        .digit_o(p2_tennis_display)
    );
    
    // State transition
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            current_state <= STATE_P1_BLINK;
            timer <= 24'd0;
            blink_counter <= 3'd0;
        end else begin
            timer <= timer + 24'd1;
            
            // Handle win states
            if (p1_win_i) begin
                current_state <= STATE_P1_WIN_BLINK;
            end else if (p2_win_i) begin
                current_state <= STATE_P2_WIN_BLINK;
            end else begin
                current_state <= next_state;
            end
            
            // Blink counter for player indication
            if (timer[21]) begin  // ~2.1 million cycles for blinking
                blink_counter <= blink_counter + 3'd1;
            end
        end
    end
    
    // Next state logic
    always @(*) begin
        case (current_state)
            STATE_P1_BLINK: begin
                if (blink_counter >= 3'd5) begin
                    next_state = STATE_P1_TENS;
                end else begin
                    next_state = STATE_P1_BLINK;
                end
            end
            STATE_P1_TENS: begin
                if (timer[20]) begin  // ~1 second display
                    next_state = STATE_P1_ONES;
                end else begin
                    next_state = STATE_P1_TENS;
                end
            end
            STATE_P1_ONES: begin
                if (timer[20]) begin
                    next_state = STATE_P2_BLINK;
                end else begin
                    next_state = STATE_P1_ONES;
                end
            end
            STATE_P2_BLINK: begin
                if (blink_counter >= 3'd5) begin
                    next_state = STATE_P2_TENS;
                end else begin
                    next_state = STATE_P2_BLINK;
                end
            end
            STATE_P2_TENS: begin
                if (timer[20]) begin
                    next_state = STATE_P2_ONES;
                end else begin
                    next_state = STATE_P2_TENS;
                end
            end
            STATE_P2_ONES: begin
                if (timer[20]) begin
                    next_state = STATE_P1_BLINK;
                end else begin
                    next_state = STATE_P2_ONES;
                end
            end
            default: next_state = STATE_P1_BLINK;
        endcase
    end
    
    // Output logic
    always @(*) begin
        case (current_state)
            STATE_P1_BLINK: begin
                digit_o = (timer[21]) ? 4'd1 : 4'b1111; // Blink '1'
                segment_select_o = 4'b0001; // First digit
            end
            STATE_P1_TENS: begin
                digit_o = mode_tennis_i ? p1_tennis_display : p1_tens;
                segment_select_o = 4'b0010; // Second digit
            end
            STATE_P1_ONES: begin
                digit_o = mode_tennis_i ? 4'b1111 : p1_ones; // No ones in tennis mode
                segment_select_o = 4'b0001; // First digit
            end
            STATE_P2_BLINK: begin
                digit_o = (timer[21]) ? 4'd2 : 4'b1111; // Blink '2'
                segment_select_o = 4'b0001; // First digit
            end
            STATE_P2_TENS: begin
                digit_o = mode_tennis_i ? p2_tennis_display : p2_tens;
                segment_select_o = 4'b0010; // Second digit
            end
            STATE_P2_ONES: begin
                digit_o = mode_tennis_i ? 4'b1111 : p2_ones; // No ones in tennis mode
                segment_select_o = 4'b0001; // First digit
            end
            STATE_P1_WIN_BLINK: begin
                digit_o = (timer[20]) ? 4'd1 : 4'b1111; // Fast blink for win
                segment_select_o = 4'b0001;
            end
            STATE_P2_WIN_BLINK: begin
                digit_o = (timer[20]) ? 4'd2 : 4'b1111; // Fast blink for win
                segment_select_o = 4'b0001;
            end
            default: begin
                digit_o = 4'b1111;
                segment_select_o = 4'b0001;
            end
        endcase
    end
    
    assign state_o = current_state;

endmodule
