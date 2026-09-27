`timescale 1ns/1ps

// ============================================================
// UART COMMUNICATION TESTBENCH
// Project 4 - VLSI RTL Design Portfolio
// Designed by: SHAIK ZAIBA FARAAZ
// ============================================================

module testbench;

    parameter CLKS_PER_BIT = 44;

    logic clk;
    logic reset;

    logic [7:0] tx_data;
    logic tx_start;

    logic tx;
    logic tx_busy;

    logic serial_line;

    logic [7:0] rx_data;
    logic rx_done;
    logic parity_error;

    integer total_tests;
    integer passed_tests;
    integer failed_tests;


    // Clock
    always #5 clk = ~clk;


    // ========================================================
    // UART TRANSMITTER
    // ========================================================

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (

        .clk(clk),
        .reset(reset),
        .data_in(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)

    );


    // ========================================================
    // LOOPBACK
    // TX connected directly to RX
    // ========================================================

    assign serial_line = tx;


    // ========================================================
    // UART RECEIVER
    // ========================================================

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (

        .clk(clk),
        .reset(reset),
        .rx(serial_line),
        .data_out(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error)

    );


    // ========================================================
    // WAVEFORM
    // ========================================================

    initial begin

        $dumpfile("uart_waveform.vcd");
        $dumpvars(0, testbench);

    end


    // ========================================================
    // UART TEST TASK
    // ========================================================

    task send_uart_data(
        input [7:0] test_data
    );

        begin

            total_tests = total_tests + 1;

            tx_data  = test_data;
            tx_start = 1'b1;

            @(posedge clk);

            tx_start = 1'b0;

            wait(rx_done);

            #10;

            if ((rx_data == test_data) &&
                (parity_error == 1'b0)) begin

                passed_tests = passed_tests + 1;

                $display(
                    "TEST %0d : TX=%02h RX=%02h PARITY_ERROR=%b : PASS",
                    total_tests,
                    test_data,
                    rx_data,
                    parity_error
                );

            end

            else begin

                failed_tests = failed_tests + 1;

                $display(
                    "TEST %0d : TX=%02h RX=%02h PARITY_ERROR=%b : FAIL",
                    total_tests,
                    test_data,
                    rx_data,
                    parity_error
                );

            end

            #100;

        end

    endtask


    // ========================================================
    // MAIN TEST
    // ========================================================

    initial begin

        clk = 1'b0;

        reset = 1'b1;

        tx_data  = 8'h00;
        tx_start = 1'b0;

        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;


        // Reset
        #100;

        reset = 1'b0;

        #100;


        // ====================================================
        // TEST PATTERNS
        // ====================================================

        send_uart_data(8'h55);

        send_uart_data(8'hAA);

        send_uart_data(8'hA5);

        send_uart_data(8'h3C);

        send_uart_data(8'hF0);

        send_uart_data(8'h0F);

        send_uart_data(8'h96);


        #100;


        // ====================================================
        // VERIFICATION SUMMARY
        // ====================================================

        $display("");

        $display("========================================");

        $display("       UART VERIFICATION SUMMARY");

        $display("========================================");

        $display(
            "TOTAL TESTS   : %0d",
            total_tests
        );

        $display(
            "PASSED TESTS  : %0d",
            passed_tests
        );

        $display(
            "FAILED TESTS  : %0d",
            failed_tests
        );

        $display("========================================");


        if (failed_tests == 0)

            $display(
                "RESULT        : ALL TESTS PASSED"
            );

        else

            $display(
                "RESULT        : SOME TESTS FAILED"
            );


        $display("========================================");

        $finish;

    end

endmodule
