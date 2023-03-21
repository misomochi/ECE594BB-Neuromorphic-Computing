`timescale 1ns/10ps

`define CYCLE 10
`define END_CYCLE 35

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

module LIF_neuron_test;
    /* input */
    reg  clk_i, rst_n;
    //reg [1:0] w1_i, w2_i, w3_i;
    reg  s1_i, s2_i, s3_i;
    
    /* output */
    wire spike_o;

    reg [`END_CYCLE - 1:0] firing_sequence [0:2];
    reg                    output_sequence [0:`END_CYCLE - 1];
    reg                    golden_pattern  [0:`END_CYCLE - 1];

    integer i, j, error = 0;

    /* DUT */
    LIF_neuron my_LIF(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .w1_i(2'd1),
        .w2_i(2'd2),
        .w3_i(2'd3),
        .s1_i(s1_i),
        .s2_i(s2_i),
        .s3_i(s3_i),
        .spike_o(spike_o)
    );

    initial begin
        /* waveform dump */
        $dumpfile("test.vcd");
        $dumpvars(0, LIF_neuron_test);
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
            @(negedge clk_i) begin
                s1_i               <= firing_sequence[0][`END_CYCLE - 1 - i];
                s2_i               <= firing_sequence[1][`END_CYCLE - 1 - i];
                s3_i               <= firing_sequence[2][`END_CYCLE - 1 - i];
                output_sequence[i] <= spike_o;
            end
        end

        @(negedge clk_i) output_sequence[`END_CYCLE - 1] = spike_o; // captures the last output

        $display("\n-------------------------------------------------------\n");
        $display("\n............... END!!! Simulation Ended ...............\n");
        $display("\n-------------------------------------------------------\n");

        /* compare with golden pattern */
        for (j = 0; j < `END_CYCLE; j = j + 1) begin
            $display("Sequence %d: The answer = %d, the output = %d\n", j, golden_pattern[j], output_sequence[j]);
            if (output_sequence[j] !== golden_pattern[j]) begin
                error = error + 1;
                $display("Sequence %d is incorrect. The answer is %d, but the output is %d.\n", j, golden_pattern[j], output_sequence[j]);
            end
        end

        if (error == 0) begin
            $display("\n============ !!!Congratulations!!! =============\n");
            $display("\n=== LIF neuron has been tested successfully! ===\n");
            $display("\n================================================\n");
        end else begin
            $display("\nLIF neuron did not pass the test, there are %d errors remaining.\n", error);
        end

        $finish;
    end

    initial begin
        /* forced simulation termination */
        #(`CYCLE * 50) $finish;
    end

endmodule