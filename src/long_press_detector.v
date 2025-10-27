`default_nettype none

module long_press_detector (
    input  wire clk_i,
    input  wire rst_i,
    input  wire button_i,
    output reg  press_short_o,
    output reg  press_long_o
);

    reg [27:0] press_counter;
    reg button_prev;
    reg detecting_press;
    
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            press_short_o <= 1'b0;
            press_long_o <= 1'b0;
            press_counter <= 28'd0;
            button_prev <= 1'b0;
            detecting_press <= 1'b0;
        end else begin
            press_short_o <= 1'b0;
            press_long_o <= 1'b0;
            button_prev <= button_i;
            
            if (button_i && !button_prev) begin
                // Button pressed
                detecting_press <= 1'b1;
                press_counter <= 28'd0;
            end else if (!button_i && button_prev && detecting_press) begin
                // Button released
                detecting_press <= 1'b0;
                if (press_counter < 28'd200000000) begin // 2 seconds threshold
                    press_short_o <= 1'b1;
                end
            end else if (detecting_press && button_i) begin
                // Button still pressed
                if (press_counter < 28'd250000000) begin // Korrektur: 250M statt 300M
                    press_counter <= press_counter + 28'd1;
                end
                
                if (press_counter >= 28'd200000000) begin // 2 seconds reached
                    press_long_o <= 1'b1;
                    detecting_press <= 1'b0;
                end
            end
        end
    end

endmodule
