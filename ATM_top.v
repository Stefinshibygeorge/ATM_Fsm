`timescale 1ns / 1ps

// ======================================================
//                      TOP MODULE
// ======================================================
module ATM_top(
    input        clk,        // 100 MHz onboard clock
    input        rst,        // active-high reset
    input  [1:0] mode,
    input  [11:0] keypad,
    input        load,
    output       auth,
    output [2:0] nstate,
    output [6:0] seg,
    output [3:0] an,
    output       dp
);

    wire [7:0] bal;
    wire slow_clk;   // 25 ms (40 Hz) clock

    // --------------------------------------------------
    // Clock Divider: generates ~25 ms clock (40 Hz)
    // --------------------------------------------------
    clk_divider clk_div_inst (
        .clk(clk),
        .rst(rst),
        .req_clk(slow_clk)
    );

    // --------------------------------------------------
    // ATM FSM
    // --------------------------------------------------
    ATM atm_fsm(
        .clk(slow_clk),    // using divided clock
        .rst(rst),
        .mode(mode),
        .keypad(keypad),
        .nstate(nstate),
        .load(load),
        .auth(auth),
        .bal(bal)
    );

    // --------------------------------------------------
    // Seven Segment Display
    // --------------------------------------------------
    seven_seg_display_bal display_unit(
        .clk(clk),    // using same slow clock
        .bal(bal),
        .seg(seg),
        .an(an),
        .dp(dp)
    );

endmodule


// ======================================================
//                  CLOCK DIVIDER MODULE
// ======================================================
module clk_divider(
    output reg req_clk,
    input clk,
    input rst
);

    reg [21:0] cnt;  // 22-bit counter sufficient for 25 ms at 100 MHz

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
            req_clk <= 0;
        end else begin
            if (cnt == 1_249_999) begin  // toggle every 12.5 ms
                cnt <= 0;
                req_clk <= ~req_clk;     // full period = 25 ms
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule
