`default_nettype none

module seven_segment_decoder (
    input  wire [3:0] digit_i,
    output reg  [6:0] segments_o
);

    always @(*) begin
        case (digit_i)
            4'd0: segments_o = 7'b0111111; // 0
            4'd1: segments_o = 7'b0000110; // 1
            4'd2: segments_o = 7'b1011011; // 2
            4'd3: segments_o = 7'b1001111; // 3
            4'd4: segments_o = 7'b1100110; // 4
            4'd5: segments_o = 7'b1101101; // 5
            4'd6: segments_o = 7'b1111101; // 6
            4'd7: segments_o = 7'b0000111; // 7
            4'd8: segments_o = 7'b1111111; // 8
            4'd9: segments_o = 7'b1101111; // 9
            4'd10: segments_o = 7'b1110111; // A
            4'd11: segments_o = 7'b1111100; // d
            4'd15: segments_o = 7'b0000000; // Blank
            default: segments_o = 7'b0000000; // Off
        endcase
    end

endmodule
