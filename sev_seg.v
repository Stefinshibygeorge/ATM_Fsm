module seven_seg_display_bal(
    input            clk,        // 100 MHz clock
    input      [7:0] bal,        // Balance to display
    output reg [6:0] seg,     // segments a-g
    output reg [3:0] an,      // anode control (active low)
    output           dp
);
    assign dp = 1'b1; // decimal point off

    reg [16:0] refresh_counter = 17'd0;
    always @(posedge clk)
        refresh_counter <= refresh_counter + 1'b1;

    wire [1:0] digit_sel = refresh_counter[16:15];

    reg [3:0] ones, tens, hundreds;
    reg [15:0] temp;
    reg [3:0] digit;

    always @(*) begin
        temp     = bal;
        hundreds = temp / 100;
        temp     = temp % 100;
        tens     = temp / 10;
        ones     = temp % 10;
    end

    always @(*) begin
        case (digit_sel)
            2'b00: begin an = 4'b1110; digit = ones;     end
            2'b01: begin an = 4'b1101; digit = tens;     end
            2'b10: begin an = 4'b1011; digit = hundreds; end
            2'b11: begin an = 4'b0111; digit = 4'd0;     end
            default: begin an = 4'b1111; digit = 4'd0;   end
        endcase
    end

    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
