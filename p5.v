module phase5 (
    input clk,
    input reset,
    output reg [1:0] time_lock_out,
    output reg phase5_done,
    output reg phase5_fail
);
    

    reg [1:0] step;
    reg [3:0] timer; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            step <= 0;
            timer <= 0;
            phase5_done <= 0;
            phase5_fail <= 0;
            time_lock_out <= 2'b00;
        end else begin
            if (phase5_done || phase5_fail) begin
                
                time_lock_out <= time_lock_out;
            end else begin
                timer <= timer + 1;
                case (step)
                    0: begin
                        time_lock_out <= 2'b01;
                        if (timer == 5) begin
                            step <= 1;
                            timer <= 0;
                        end
                    end
                    1: begin
                        time_lock_out <= 2'b10;
                        if (timer == 5) begin
                            step <= 2;
                            timer <= 0;
                        end
                    end
                    2: begin
                        time_lock_out <= 2'b11;
                        if (timer == 5) begin
                            phase5_done <= 1;
                        end
                    end
                    default: begin
                        phase5_fail <= 1; 
                    end
                endcase
            end
        end
    end
endmodule
