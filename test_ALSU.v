//-----------------------------------------------------------------------------
// Testbench   : alsu_tb
// Description : Directed testbench for the alsu module: checks async reset,
//               bypass, and walks through each opcode (0-5) with randomized
//               operands, printing the DUT state for visual inspection.
//-----------------------------------------------------------------------------
module alsu_tb;

    reg [2:0] a, b, opcode;
    reg       cin, serial_in, direction, red_op_a, red_op_b, bypass_a, bypass_b, clk, rst;
    wire [5:0]  out;
    wire [15:0] leds;

    integer i;

    alsu dut (
        a, b, opcode, cin, serial_in, direction,
        red_op_a, red_op_b, bypass_a, bypass_b,
        clk, rst, out, leds
    );

    initial begin
        clk = 0;
        forever begin
            #1;
            clk = ~clk;
        end
    end

    initial begin
        // 2.1 Verify asynchronous reset functionality
        rst         = 1;
        opcode      = 0;
        a           = 0;
        b           = 0;
        cin         = 0;
        serial_in   = 0;
        direction   = 0;
        red_op_a    = 0;
        red_op_b    = 0;
        bypass_a    = 0;
        bypass_b    = 0;
        @(negedge clk);
        $display(" 2.1 Verify asynchronous reset functionality\n");
        if (out == 0 && leds == 0) begin
            $display(" reset works\n\n");
        end
        else begin
            $display(" reset doesn't work\n");
        end

        // 2.2 Verify bypass functionality
        rst = 0;
        $display(" 2.2 Verify bypass functionality\n");
        for (i = 0; i < 3; i = i + 1) begin
            bypass_a = 1;
            bypass_b = 1;
            a        = $random();
            b        = $random();
            opcode   = $urandom_range(0, 5);
            @(negedge clk);
            @(negedge clk);
            if (out != a) begin
                $display("Error in bypass\n");
            end
        end

        // 2.3 Verify opcode 0 functionality
        $display("2.3 Verify opcode 0 functionality\n");
        for (i = 0; i < 3; i = i + 1) begin
            bypass_a = 0;
            bypass_b = 0;
            opcode   = 0;
            a        = $random();
            b        = $random();
            red_op_a = $random();
            red_op_b = $random();
            @(negedge clk);
            @(negedge clk);
            print_state();
        end

        // 2.4 Verify opcode 1 functionality
        $display("2.4 Verify opcode 1 functionality\n");
        for (i = 0; i < 3; i = i + 1) begin
            bypass_a = 0;
            bypass_b = 0;
            opcode   = 1;
            a        = $random();
            b        = $random();
            red_op_a = $random();
            red_op_b = $random();
            @(negedge clk);
            @(negedge clk);
            print_state();
        end

        // 2.5 Verify opcode 2 functionality
        $display("2.5 Verify opcode 2 functionality\n");
        for (i = 0; i < 3; i = i + 1) begin
            bypass_a = 0;
            bypass_b = 0;
            opcode   = 2;
            a        = $random();
            b        = $random();
            red_op_a = 0;
            red_op_b = 0;
            @(negedge clk);
            @(negedge clk);
            print_state();
        end

        // 2.6 Verify opcode 3 functionality
        $display("2.6 Verify opcode 3 functionality\n");
        for (i = 0; i < 3; i = i + 1) begin
            bypass_a = 0;
            bypass_b = 0;
            opcode   = 3;
            a        = $random();
            b        = $random();
            red_op_a = 0;
            red_op_b = 0;
            @(negedge clk);
            @(negedge clk);
            print_state();
        end

        // 2.7 Verify opcode 4 functionality
        $display("2.7 Verify opcode 4 functionality\n");
        for (i = 0; i < 3; i = i + 1) begin
            bypass_a  = 0;
            bypass_b  = 0;
            opcode    = 4;
            a         = $random();
            b         = $random();
            direction = $random();
            serial_in = $random();
            @(negedge clk);
            print_state();
        end

        // 2.8 Verify opcode 5 functionality
        $display("2.8 Verify opcode 5 functionality\n");
        for (i = 0; i < 3; i = i + 1) begin
            bypass_a  = 0;
            bypass_b  = 0;
            opcode    = 5;
            a         = $random();
            b         = $random();
            direction = $random();
            serial_in = $random();
            @(negedge clk);
            print_state();
        end

        $stop();
    end

    task print_state();
        $display(" a=%b\n b=%b\n opcode=%b\n cin=%b\n serial_in=%b\n direction=%b\n red_op_a=%b\n red_op_b=%b\n bypass_a=%b\n bypass_b=%b\n rst=%b\n out=%b\n leds=%b\n",
                  a, b, opcode, cin, serial_in, direction, red_op_a, red_op_b, bypass_a, bypass_b, rst, out, leds);
    endtask

endmodule
