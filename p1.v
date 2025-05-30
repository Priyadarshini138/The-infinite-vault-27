module phase1 (
    input clk,
    input reset,
    input code_in,
    output reg phase1_done,
    output reg phase1_fail
);
    
    localparam [3:0] UNLOCK_CODE = 4'b1011;

    reg [1:0] bit_count;
    reg [3:0] code_reg;
    reg waiting;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase1_done <= 0;
            phase1_fail <= 0;
            bit_count <= 0;
            code_reg <= 0;
            waiting <= 1;
        end else begin
            if (waiting) begin
                phase1_done <= 0;
                phase1_fail <= 0;
                code_reg <= {code_reg[2:0], code_in};
                bit_count <= bit_count + 1;
                if (bit_count == 3) begin
                    
                    if ({code_reg[2:0], code_in} == UNLOCK_CODE) begin
                        phase1_done <= 1;
                        phase1_fail <= 0;
                    end else begin
                        phase1_done <= 0;
                        phase1_fail <= 1;
                    end
                    waiting <= 0;
                end
            end else begin
                
                phase1_done <= phase1_done;
                phase1_fail <= phase1_fail;
            end
        end
    end
endmodule
