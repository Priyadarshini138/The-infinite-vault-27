module phase3 (
    input clk,
    input reset,
    input [2:0] dir_in,
    output reg phase3_done,
    output reg phase3_fail
);
    
    localparam [2:0] SEQ [0:4] = {3'b000, 3'b011, 3'b001, 3'b010, 3'b000};
    reg [2:0] step;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            step <= 0;
            phase3_done <= 0;
            phase3_fail <= 0;
        end else begin
            if (phase3_done || phase3_fail) begin
                
                phase3_done <= phase3_done;
                phase3_fail <= phase3_fail;
            end else begin
                if (dir_in == SEQ[step]) begin
                    step <= step + 1;
                    if (step == 4) begin
                        phase3_done <= 1;
                    end
                end else begin
                    phase3_fail <= 1;
                end
            end
        end
    end
endmodule
