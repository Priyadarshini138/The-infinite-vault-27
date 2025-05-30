module top_module (
    input clk,
    input reset,
    input code_in,
    input [3:0] switch_in,
    input [2:0] dir_in,
    input [7:0] plate_in,
    output [1:0] time_lock_out,
    output reg all_done,

    
    output phase1_done,
    output phase1_fail,
    output phase2_done,
    output phase2_fail,
    output phase3_done,
    output phase3_fail,
    output phase4_done,
    output phase4_fail,
    output phase5_done,
    output phase5_fail
);

    
    typedef enum reg [2:0] {
        PH1 = 3'd0,
        PH2 = 3'd1,
        PH3 = 3'd2,
        PH4 = 3'd3,
        PH5 = 3'd4,
        DONE = 3'd5
    } state_t;

    state_t current_state, next_state;

   
    wire ph1_done, ph1_fail;
    wire ph2_done, ph2_fail;
    wire ph3_done, ph3_fail;
    wire ph4_done, ph4_fail;
    wire ph5_done, ph5_fail;
    wire [1:0] tl_out;

    phase1 u_phase1 (.clk(clk), .reset(reset || current_state != PH1), .code_in(code_in), .phase1_done(ph1_done), .phase1_fail(ph1_fail));
    phase2 u_phase2 (.clk(clk), .reset(reset || current_state != PH2), .switch_in(switch_in), .phase2_done(ph2_done), .phase2_fail(ph2_fail));
    phase3 u_phase3 (.clk(clk), .reset(reset || current_state != PH3), .dir_in(dir_in), .phase3_done(ph3_done), .phase3_fail(ph3_fail));
    phase4 u_phase4 (.clk(clk), .reset(reset || current_state != PH4), .plate_in(plate_in), .phase4_done(ph4_done), .phase4_fail(ph4_fail));
    phase5 u_phase5 (.clk(clk), .reset(reset || current_state != PH5), .time_lock_out(tl_out), .phase5_done(ph5_done), .phase5_fail(ph5_fail));

    assign phase1_done = ph1_done;
    assign phase1_fail = ph1_fail;
    assign phase2_done = ph2_done;
    assign phase2_fail = ph2_fail;
    assign phase3_done = ph3_done;
    assign phase3_fail = ph3_fail;
    assign phase4_done = ph4_done;
    assign phase4_fail = ph4_fail;
    assign phase5_done = ph5_done;
    assign phase5_fail = ph5_fail;
    assign time_lock_out = (current_state == PH5) ? tl_out : 2'b00;

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= PH1;
            all_done <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == DONE)
                all_done <= 1;
            else
                all_done <= 0;
        end
    end

    always @(*) begin
        case (current_state)
            PH1: begin
                if (ph1_done) next_state = PH2;
                else if (ph1_fail) next_state = PH1;
                else next_state = PH1;
            end
            PH2: begin
                if (ph2_done) next_state = PH3;
                else if (ph2_fail) next_state = PH2;
                else next_state = PH2;
            end
            PH3: begin
                if (ph3_done) next_state = PH4;
                else if (ph3_fail) next_state = PH2; 
                else next_state = PH3;
            end
            PH4: begin
                if (ph4_done) next_state = PH5;
                else if (ph4_fail) next_state = PH2; 
                else next_state = PH4;
            end
            PH5: begin
                if (ph5_done) next_state = DONE;
                else if (ph5_fail) next_state = PH2; 
                else next_state = PH5;
            end
            DONE: begin
                next_state = DONE;
            end
            default: next_state = PH1;
        endcase
    end

endmodule
