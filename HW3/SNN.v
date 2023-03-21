`include "LIF_neuron.v"

module SNN (
    input  clk_i, // Clock
    input  rst_n, // Asynchronous reset active low
    input  s1_i,
    input  s2_i,
    input  s3_i,
    output spike1_o,
    output spike2_o
);

    wire w4, w5, w6;

    LIF_neuron N4 (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .w1_i(3'd3),
        .w2_i(3'd3),
        .w3_i(3'd2),
        .s1_i(s1_i),
        .s2_i(s2_i),
        .s3_i(s3_i),
        .spike_o(w4)
    );

    LIF_neuron N5 (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .w1_i(3'd1),
        .w2_i(3'd2),
        .w3_i(3'd3),
        .s1_i(s1_i),
        .s2_i(s2_i),
        .s3_i(s3_i),
        .spike_o(w5)
    );

    LIF_neuron N6 (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .w1_i(3'd4),
        .w2_i(3'd3),
        .w3_i(3'd4),
        .s1_i(s1_i),
        .s2_i(s2_i),
        .s3_i(s3_i),
        .spike_o(w6)
    );

    LIF_neuron N7 (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .w1_i(3'd3),
        .w2_i(3'd2),
        .w3_i(3'd3),
        .s1_i(w4),
        .s2_i(w5),
        .s3_i(w6),
        .spike_o(spike1_o)
    );

    LIF_neuron N8 (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .w1_i(3'd2),
        .w2_i(3'd4),
        .w3_i(3'd2),
        .s1_i(w4),
        .s2_i(w5),
        .s3_i(w6),
        .spike_o(spike2_o)
    );

endmodule