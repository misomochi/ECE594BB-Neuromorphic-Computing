`timescale 1ns/10ps

`define CYCLE 10
`define END_CYCLE 40
`define NEURONS 5

`ifdef S1
    `define INFILE  "./pattern/in1.txt"
    `define OUTFILE "./pattern/out1_golden.txt"
`elsif S2
    `define INFILE  "./pattern/in2.txt"
    `define OUTFILE "./pattern/out2_golden.txt"
`elsif S3
    `define INFILE  "./pattern/in3.txt"
    `define OUTFILE "./pattern/out3_golden.txt"
`elsif S4
    `define INFILE  "./pattern/in4.txt"
    `define OUTFILE "./pattern/out4_golden.txt"
`endif

module SNN_test;
    /* input */
    reg clk_i, rst_n;
    reg  s1_i, s2_i, s3_i;

    /* output */
    wire spike1_o, spike2_o;

    reg [`END_CYCLE - 1:0] firing_sequence [0:2];
    reg [`END_CYCLE - 1:0] output_sequence [0:`NEURONS - 1];
    reg [`END_CYCLE - 1:0] golden_pattern  [0:`NEURONS - 1];

    integer i, j, error1 = 0, error2 = 0;

    /* DUT */
    SNN my_SNN (
        .clk_i    (clk_i),
        .rst_n    (rst_n),
        .s1_i     (s1_i),
        .s2_i     (s2_i),
        .s3_i     (s3_i),
        .spike1_o (spike1_o),
        .spike2_o (spike2_o)
    );

    initial begin
        /* waveform dump */
        $dumpfile("test.vcd");
        $dumpvars(0, SNN_test);
    end

    /* clock generation */
    always #(`CYCLE * 0.5) clk_i = ~clk_i;

    initial begin
        $display("\n-------------------------------------------------------\n");
        $display("\n.............. START!!! Simulation Start ..............\n");
        $display("\n-------------------------------------------------------\n");

        $readmemb(`INFILE  , firing_sequence);
        $readmemb(`OUTFILE , golden_pattern);

        /* data initialization */
        {s3_i, s2_i, s1_i} = {1'b0, 1'b0, 1'b0};

        clk_i = 1'b1;
        rst_n = 1'b1;
        #(`CYCLE * 0.5) rst_n = 1'b0;
        #(`CYCLE * 2.0) rst_n = 1'b1;

        for (i = 0; i < `END_CYCLE; i = i + 1) begin
            @ (negedge clk_i) begin
                s1_i <= firing_sequence[0][`END_CYCLE - 1 - i];
                s2_i <= firing_sequence[1][`END_CYCLE - 1 - i];
                s3_i <= firing_sequence[2][`END_CYCLE - 1 - i];
                output_sequence[0][i] <= spike1_o;
                output_sequence[1][i] <= spike2_o;
            end
        end

        // captures the last output
        @ (negedge clk_i) begin
            output_sequence[0][`END_CYCLE - 1] <= spike1_o;
            output_sequence[1][`END_CYCLE - 1] <= spike2_o;
        end

        $display("\n-------------------------------------------------------\n");
        $display("\n............... END!!! Simulation Ended ...............\n");
        $display("\n-------------------------------------------------------\n");

        /* compare with golden pattern */
        $display("\n--------------- SPIKE TRAIN 1 ---------------\n");
        for (j = 0; j < `END_CYCLE; j = j + 1) begin
            $display("Sequence %d: The answer = %d, the output = %d\n", j, golden_pattern[3][`END_CYCLE - 1 - j], output_sequence[0][j]);
            if (output_sequence[0][j] !== golden_pattern[3][`END_CYCLE - 1 - j]) begin
                error1 = error1 + 1;
                $display("Sequence %d is incorrect. The answer is %d, but the output is %d.\n", j, golden_pattern[3][`END_CYCLE - 1 - j], output_sequence[0][j]);
            end
        end

        $display("\n--------------- SPIKE TRAIN 2 ---------------\n");
        for (j = 0; j < `END_CYCLE; j = j + 1) begin
            $display("Sequence %d: The answer = %d, the output = %d\n", j, golden_pattern[4][`END_CYCLE - 1 - j], output_sequence[1][j]);
            if (output_sequence[1][j] !== golden_pattern[4][`END_CYCLE - 1 - j]) begin
                error2 = error2 + 1;
                $display("Sequence %d is incorrect. The answer is %d, but the output is %d.\n", j, golden_pattern[4][`END_CYCLE - 1 - j], output_sequence[1][j]);
            end
        end

        if ((error1 == 0) && (error2 == 0)) begin
            $display("\n================ !!!Congratulations!!! ===============\n");
            $display("\n====== LIF neuron has been tested successfully! ======\n");
            $display("\n======================================================\n");
        end else begin
            $display("\nSNN did not pass the test, there are %d errors from Neuron 7 and %d errors from Neuron 8.\n", error1, error2);
        end

        $finish;
    end

    initial begin
        /* forced simulation termination */
        #(`CYCLE * 50) $finish;
    end

endmodule