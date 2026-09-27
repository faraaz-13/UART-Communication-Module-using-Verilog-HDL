`timescale 1ns/1ps

// ============================================================
// UART COMMUNICATION MODULE
// Project 4 - VLSI RTL Design Portfolio
// Designed by: SHAIK ZAIBA FARAAZ
// ============================================================

module uart_tx #(
    parameter CLKS_PER_BIT = 44
)(
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] data_in,
    input  logic       tx_start,
    output logic       tx,
    output logic       tx_busy
);

    typedef enum logic [2:0] {
        TX_IDLE,
        TX_START,
        TX_DATA,
        TX_PARITY,
        TX_STOP
    } tx_state_t;

    tx_state_t state;

    logic [15:0] clk_count;
    logic [3:0]  bit_index;
    logic [7:0]  data_reg;
    logic        parity_bit;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            state      <= TX_IDLE;
            clk_count  <= 16'd0;
            bit_index  <= 4'd0;
            data_reg   <= 8'd0;
            parity_bit <= 1'b0;
            tx         <= 1'b1;
            tx_busy    <= 1'b0;
        end

        else begin

            case (state)

                TX_IDLE: begin

                    tx        <= 1'b1;
                    tx_busy   <= 1'b0;
                    clk_count <= 16'd0;
                    bit_index <= 4'd0;

                    if (tx_start) begin

                        data_reg   <= data_in;
                        parity_bit <= ^data_in;

                        tx_busy <= 1'b1;
                        state   <= TX_START;

                    end
                end


                TX_START: begin

                    tx <= 1'b0;

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;
                        bit_index <= 4'd0;
                        state     <= TX_DATA;

                    end
                end


                TX_DATA: begin

                    tx <= data_reg[bit_index];

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;

                        if (bit_index < 7)

                            bit_index <= bit_index + 1'b1;

                        else begin

                            bit_index <= 4'd0;
                            state     <= TX_PARITY;

                        end
                    end
                end


                TX_PARITY: begin

                    tx <= parity_bit;

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;
                        state     <= TX_STOP;

                    end
                end


                TX_STOP: begin

                    tx <= 1'b1;

                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;
                        tx_busy   <= 1'b0;
                        state     <= TX_IDLE;

                    end
                end


                default:
                    state <= TX_IDLE;

            endcase
        end
    end

endmodule



// ============================================================
// UART RECEIVER
// ============================================================

module uart_rx #(
    parameter CLKS_PER_BIT = 44
)(
    input  logic       clk,
    input  logic       reset,
    input  logic       rx,
    output logic [7:0] data_out,
    output logic       rx_done,
    output logic       parity_error
);

    typedef enum logic [2:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_PARITY,
        RX_STOP
    } rx_state_t;

    rx_state_t state;

    logic [15:0] clk_count;
    logic [3:0]  bit_index;
    logic [7:0]  data_reg;

    logic parity_received;
    logic parity_calculated;

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin

            state             <= RX_IDLE;
            clk_count         <= 16'd0;
            bit_index         <= 4'd0;
            data_reg          <= 8'd0;
            data_out          <= 8'd0;
            rx_done           <= 1'b0;
            parity_error      <= 1'b0;
            parity_received   <= 1'b0;
            parity_calculated <= 1'b0;

        end

        else begin

            rx_done <= 1'b0;

            case (state)

                RX_IDLE: begin

                    clk_count    <= 16'd0;
                    bit_index    <= 4'd0;
                    parity_error <= 1'b0;

                    if (rx == 1'b0)
                        state <= RX_START;

                end


                RX_START: begin

                    if (clk_count < (CLKS_PER_BIT/2) - 1)

                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;

                        if (rx == 1'b0) begin

                            bit_index <= 4'd0;
                            state     <= RX_DATA;

                        end

                        else
                            state <= RX_IDLE;

                    end
                end


                RX_DATA: begin

                    if (clk_count < CLKS_PER_BIT - 1)

                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;

                        data_reg[bit_index] <= rx;

                        if (bit_index < 7)

                            bit_index <= bit_index + 1'b1;

                        else begin

                            bit_index <= 4'd0;
                            state     <= RX_PARITY;

                        end
                    end
                end


                RX_PARITY: begin

                    if (clk_count < CLKS_PER_BIT - 1)

                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;

                        parity_received   <= rx;
                        parity_calculated <= ^data_reg;

                        if (rx != (^data_reg))

                            parity_error <= 1'b1;

                        else

                            parity_error <= 1'b0;

                        state <= RX_STOP;

                    end
                end


                RX_STOP: begin

                    if (clk_count < CLKS_PER_BIT - 1)

                        clk_count <= clk_count + 1'b1;

                    else begin

                        clk_count <= 16'd0;

                        data_out <= data_reg;
                        rx_done  <= 1'b1;

                        state <= RX_IDLE;

                    end
                end


                default:
                    state <= RX_IDLE;

            endcase
        end
    end

endmodule
