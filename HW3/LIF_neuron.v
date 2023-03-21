module LIF_neuron #(
    parameter V_REST = 5'd6,
    parameter V_LEAK = 5'd1,
    parameter K_SYN  = 1'd1,
    parameter V_TH   = 5'd14
) (
    input       clk_i, // Clock
    input       rst_n, // Asynchronous reset active low
    input [2:0] w1_i,
    input [2:0] w2_i,
    input [2:0] w3_i,
    input       s1_i,
    input       s2_i,
    input       s3_i,
    output reg  spike_o
);

    //localparam V_REST = 5'd6, V_LEAK = 5'd1, K_SYN = 1'd1, V_TH = 5'd14;

    reg [4:0] v_r, v_n;

    always @(*) begin
        if (spike_o == 1'b1) begin
            v_n = V_REST;
        end else begin
            v_n = v_r + K_SYN * (w1_i * s1_i + w2_i * s2_i + w3_i * s3_i) - ((v_r > V_REST) ? V_LEAK : 0);
        end
    end

    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            v_r     <= V_REST;
            spike_o <= 1'b0;
        end else begin
            v_r     <= v_n;
            spike_o <= (v_n >= V_TH) ? 1'b1 : 1'b0;
        end
    end

endmodule