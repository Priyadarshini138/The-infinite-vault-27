module phase2 (
    input clk,
    input reset,
    input [3:0] switch_in,
    output reg phase2_done,
    output reg phase2_fail
);
    localparam [3:0] UNLOCK_CODE = 4'b1101;
    reg [3:0] hold_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase2_done <= 0;
            phase2_fail <= 0;
            hold_count <= 0;
        end else begin
            if (switch_in == UNLOCK_CODE) begin
                hold_count <= hold_count + 1;
                phase2_fail <= 0;
                if (hold_count >= 5) begin 
                    phase2_done <= 1;
                end else begin
                    phase2_done <= 0;
                end
            end else begin
                phase2_done <= 0;
                phase2_fail <= 1;
                hold_count <= 0;
            end
        end
    end
endmodule
