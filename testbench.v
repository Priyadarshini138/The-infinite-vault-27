`timescale 1ns/1ps
`include "top_module1.sv"
`include "p1.sv"
`include "p2.sv"
`include "p3.sv"
`include "p4.sv"
`include "p5.sv"


module testbench;
    reg clk;
    reg reset;
    reg code_in;
    reg [3:0] switch_in;
    reg [2:0] dir_in;
    reg [7:0] plate_in;
    wire [1:0] time_lock_out;
    wire all_done;

    
    top_module uut (
        .clk(clk),
        .reset(reset),
        .code_in(code_in),
        .switch_in(switch_in),
        .dir_in(dir_in),
        .plate_in(plate_in),
        .time_lock_out(time_lock_out),
        .all_done(all_done),

        
        .phase1_done(),
        .phase1_fail(),
        .phase2_done(),
        .phase2_fail(),
        .phase3_done(),
        .phase3_fail(),
        .phase4_done(),
        .phase4_fail(),
        .phase5_done(),
        .phase5_fail()
    );

    
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
      $dumpfile("dump.vcd");  
    $dumpvars(0, testbench); 
        
        reset = 1;
        code_in = 0;
        switch_in = 4'b0000;
        dir_in = 3'b000;
        plate_in = 8'b00000000;

        #20;
        reset = 0;

        
        $display("Starting Phase 1: Code Lock");
        send_serial_code(4'b1011);
        wait_phase_done_or_fail(1);

        
        $display("Starting Phase 2: Switch Room");
        switch_in = 4'b1101;
        #(10*10); 
        wait_phase_done_or_fail(2);

        
        $display("Starting Phase 3: Maze Tracker");
        send_dir_sequence({3'b000, 3'b011, 3'b001, 3'b010, 3'b000});
        wait_phase_done_or_fail(3);

        
        $display("Starting Phase 4: Pressure Plates");
        send_plate_sequence({8'b10101010, 8'b11001100, 8'b11110000});
        wait_phase_done_or_fail(4);

        
        $display("Starting Phase 5: Time-Lock Output");
        wait_phase_done_or_fail(5);
      
       #(10*10);

        if (all_done)
            $display("Vault unlocked successfully! All phases completed.");
        else
            $display("Vault unlocking failed.");

        #50;
        $finish;
    end

    
    task send_serial_code(input [3:0] code);
        integer i;
        begin
            for (i = 3; i >= 0; i = i - 1) begin
                code_in = code[i];
                @(posedge clk);
            end
            code_in = 0;
        end
    endtask

    
    task send_dir_sequence(input [14:0] dirs);
        integer i;
        begin
            for (i = 4; i >= 0; i = i - 1) begin
                dir_in = dirs[i*3 +: 3];
                @(posedge clk);
            end
            dir_in = 0;
        end
    endtask

    
    task send_plate_sequence(input [23:0] plates);
        integer i;
        begin
            for (i = 2; i >= 0; i = i - 1) begin
                plate_in = plates[i*8 +: 8];
                @(posedge clk);
            end
            plate_in = 0;
        end
    endtask

    
    task wait_phase_done_or_fail(input integer phase_num);
        begin
            case (phase_num)
                1: wait (uut.phase1_done || uut.phase1_fail);
                2: wait (uut.phase2_done || uut.phase2_fail);
                3: wait (uut.phase3_done || uut.phase3_fail);
                4: wait (uut.phase4_done || uut.phase4_fail);
                5: wait (uut.phase5_done || uut.phase5_fail);
            endcase
            @(posedge clk);

            if (phase_num == 1) begin
                if (uut.phase1_done) $display("Phase 1 done");
                else $display("Phase 1 fail");
            end else if (phase_num == 2) begin
                if (uut.phase2_done) $display("Phase 2 done");
                else $display("Phase 2 fail");
            end else if (phase_num == 3) begin
                if (uut.phase3_done) $display("Phase 3 done");
                else begin
                    $display("Phase 3 fail - resetting to Phase 2");
                    switch_in = 4'b1101;
                end
            end else if (phase_num == 4) begin
                if (uut.phase4_done) $display("Phase 4 done");
                else begin
                    $display("Phase 4 fail - resetting to Phase 2");
                    switch_in = 4'b1101;
                end
            end else if (phase_num == 5) begin
                if (uut.phase5_done) $display("Phase 5 done");
                else begin
                    $display("Phase 5 fail - resetting to Phase 2");
                    switch_in = 4'b1101;
                end
            end
        end
    endtask
endmodule
