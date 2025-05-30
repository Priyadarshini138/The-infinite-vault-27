module phase4 (
    input clk,
    input reset,
    input [7:0] plate_in,
    output reg phase4_done,
    output reg phase4_fail
);
    
    localparam [7:0] SEQ [0:2] = {8'b10101010, 8'b11001100, 8'b11110000};
    reg [1:0] step;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            step <= 0;
            phase4_done <= 0;
            phase4_fail <= 0;
        end else begin
            if (phase4_done || phase4_fail) begin
                
                phase4_done <= phase4_done;
                phase4_fail <= phase4_fail;
            end else begin
                if (plate_in == SEQ[step]) begin
                    step <= step + 1;
                    if (step == 2) begin
                        phase4_done <= 1;
                    end
                end else begin
                    phase4_fail <= 1;
                end
            end
        end
    end
endmodule
