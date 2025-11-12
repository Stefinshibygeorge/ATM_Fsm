`timescale 1ns / 1ps

// ======================================================
//                 ATM FSM (FPGA-Safe Version)
// ======================================================
module ATM(
    input            clk,           // FSM clock (~1 kHz recommended)
    input            rst,           // Active-high reset
    input  [1:0]     mode,
    input  [11:0]    keypad,
    input            load,
    output reg [11:0] keypad_buffer,
    output reg [2:0]  pstate,
    output reg [2:0]  nstate,
    output reg        auth,
    output reg [7:0]  bal
);

    // -------- State Encoding --------
    parameter IDLE        = 3'b000;
    parameter AUTH        = 3'b001;
    parameter MENU        = 3'b010;
    parameter BALANCE     = 3'b011;
    parameter WITHDRAW    = 3'b100;
    parameter TRANSACTION = 3'b101;

    // -------- Internal Registers --------
    reg [7:0] withdraw_amt;
    reg [7:0] trans_amt;
    reg [3:0] trans_acc;
    reg [1:0] acc_idx;
    reg [1:0] tgt_idx;
    reg       v_trans_acc;

    // -------- Databases (4 Accounts) --------
    reg [3:0] acc_database [0:3];
    reg [7:0] pin_database [0:3];
    reg [7:0] bal_database [0:3];
    
    integer i;

    // -------- Initialize Databases --------
    initial begin
        acc_database[0] = 4'hA; pin_database[0] = 8'h11; bal_database[0] = 8'd50;
        acc_database[1] = 4'hB; pin_database[1] = 8'h22; bal_database[1] = 8'd175;
        acc_database[2] = 4'hC; pin_database[2] = 8'h33; bal_database[2] = 8'd200;
        acc_database[3] = 4'hD; pin_database[3] = 8'h44; bal_database[3] = 8'd40;
    end

    // -------- Sequential Logic --------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pstate        <= IDLE;
            nstate        <= IDLE;
            keypad_buffer <= 12'b0;
            auth          <= 1'b0;
            bal           <= 8'b0;
            withdraw_amt  <= 8'b0;
            trans_amt     <= 8'b0;
            trans_acc     <= 4'b0;
            acc_idx       <= 2'b0;
            tgt_idx       <= 2'b0;
            v_trans_acc   <= 1'b0;
        end
        else begin
            pstate <= nstate;

            // Buffer keypad input when load pressed
            if (load)
                keypad_buffer <= keypad;

            case (pstate)

                // ----------------------------------------------------
                IDLE: begin
                    auth <= 0;
                    nstate <= AUTH;
                end

                // ----------------------------------------------------
                AUTH: begin
                    auth <= 0;
                    if (keypad_buffer != 12'b0) begin
                        for (i=0; i<4; i=i+1) begin
                            if ({acc_database[i], pin_database[i]} == keypad_buffer) begin
                                acc_idx <= i[1:0];
                                auth <= 1;
                                nstate <= MENU;
                            end
                        end
                    end else begin
                        nstate <= AUTH;
                    end
                end

                // ----------------------------------------------------
                MENU: begin
                    case (mode)
                        2'b00: nstate <= MENU;         // stay in menu
                        2'b01: nstate <= BALANCE;      // check balance
                        2'b10: nstate <= WITHDRAW;     // withdraw
                        2'b11: nstate <= TRANSACTION;  // transfer
                        default: nstate <= IDLE;
                    endcase
                end

                // ----------------------------------------------------
                BALANCE: begin
                    bal <= bal_database[acc_idx];
                    nstate <= MENU;
                end

                // ----------------------------------------------------
                WITHDRAW: begin
                    if (load && auth) begin
                        withdraw_amt <= keypad_buffer[7:0];
                        if ((withdraw_amt > 0) && (withdraw_amt <= bal_database[acc_idx])) begin
                            bal_database[acc_idx] <= bal_database[acc_idx] - withdraw_amt;
                            bal <= bal_database[acc_idx] - withdraw_amt;
                            auth <= 0;
                        end
                        nstate <= IDLE;
                    end else begin
                        nstate <= WITHDRAW;
                    end
                end

                // ----------------------------------------------------
                TRANSACTION: begin
                    if (load && auth) begin
                        trans_acc <= keypad_buffer[11:8];
                        trans_amt <= keypad_buffer[7:0];
                        v_trans_acc <= 0;
                        for (i=0; i<4; i=i+1) begin
                            if (acc_database[i] == trans_acc) begin
                                tgt_idx <= i[1:0];
                                v_trans_acc <= 1;
                            end
                        end
                        if (v_trans_acc && trans_amt > 0 &&
                            trans_amt <= bal_database[acc_idx] &&
                            (bal_database[tgt_idx] + trans_amt) < 8'd255) begin
                            bal_database[acc_idx] <= bal_database[acc_idx] - trans_amt;
                            bal_database[tgt_idx] <= bal_database[tgt_idx] + trans_amt;
                            auth <= 0;
                        end
                        nstate <= IDLE;
                    end else begin
                        nstate <= TRANSACTION;
                    end
                end

                default: nstate <= IDLE;
            endcase
        end
    end
endmodule
