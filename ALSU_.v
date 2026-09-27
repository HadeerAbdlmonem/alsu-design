//-----------------------------------------------------------------------------
// Module      : alsu
// Description : Early/simplified ALSU design. Inputs are registered on
//               entry (a_i -> a, etc.); out/leds are computed from the
//               registered values. opcode: 0=AND/reduce-AND, 1=XOR/
//               reduce-XOR, 2=ADD(+cin), 3=MULT, 4=shift, 5=rotate.
//               bypass_a_i/bypass_b_i pass an operand straight to out.
//               leds blinks (toggles) while the current opcode/reduction
//               combination is invalid.
//-----------------------------------------------------------------------------
module alsu (
    input  [2:0]  a_i,
    input  [2:0]  b_i,
    input  [2:0]  opcode_i,
    input         cin_i,
    input         serial_in_i,
    input         direction_i,
    input         red_op_a_i,
    input         red_op_b_i,
    input         bypass_a_i,
    input         bypass_b_i,
    input         clk,
    input         rst,
    output [5:0]  out_o,
    output [15:0] leds_o
);

    parameter INPUT_PRIORITY = "A";
    parameter FULL_ADDER     = 1;

    reg [2:0] a, b, opcode;
    reg       cin, serial_in, direction, red_op_a, red_op_b, bypass_a, bypass_b;
    reg [5:0] out;
    reg [15:0] leds;

    // Invalid when a reduction op (red_op_a_i/red_op_b_i) is requested with
    // an opcode other than AND (000) or XOR (001), or when opcode is one of
    // the two unused/reserved encodings (110, 111).
    wire invalid;
    assign invalid = ((red_op_a || red_op_b) && (opcode != 3'b000) && (opcode != 3'b001))
                    || (opcode == 3'b110) || (opcode == 3'b111);

    // Register inputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a         <= 0;
            b         <= 0;
            opcode    <= 0;
            cin       <= 0;
            serial_in <= 0;
            direction <= 0;
            red_op_a  <= 0;
            red_op_b  <= 0;
            bypass_a  <= 0;
            bypass_b  <= 0;
        end
        else begin
            a         <= a_i;
            b         <= b_i;
            opcode    <= opcode_i;
            cin       <= cin_i;
            serial_in <= serial_in_i;
            direction <= direction_i;
            red_op_a  <= red_op_a_i;
            red_op_b  <= red_op_b_i;
            bypass_a  <= bypass_a_i;
            bypass_b  <= bypass_b_i;
        end
    end

    // Output / LED processing
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out  <= 0;
            leds <= 0;
        end
        else begin
            if ((bypass_a && !bypass_b) || (bypass_b && !bypass_a)) begin
                // Exactly one of bypass_a / bypass_b is high
                out <= (bypass_a) ? a : b;
                if (invalid) leds <= ~leds;
            end
            else if (bypass_a && bypass_b) begin
                out <= (INPUT_PRIORITY == "A") ? a : b;
                if (invalid) leds <= ~leds;
            end
            else if (invalid) begin
                leds <= ~leds; // alert: blink the LEDs
                out  <= 0;
            end
            else begin
                case (opcode)
                    3'b000: begin
                        if (red_op_a == 0 && red_op_b == 0) begin
                            out <= a & b;
                        end
                        else if (red_op_a == 1 && red_op_b == 1) begin
                            out <= (INPUT_PRIORITY == "A") ? &a : &b;
                        end
                        else begin
                            out <= (red_op_a == 1) ? (&a) : (&b);
                        end
                    end
                    3'b001: begin
                        if (red_op_a == 0 && red_op_b == 0) begin
                            out <= a ^ b;
                        end
                        else if (red_op_a == 1 && red_op_b == 1) begin
                            out <= (INPUT_PRIORITY == "A") ? ^a : ^b;
                        end
                        else begin
                            out <= (red_op_a == 1) ? (^a) : (^b);
                        end
                    end
                    3'b010: out <= (FULL_ADDER) ? a + b + cin : a + b;
                    3'b011: out <= a * b;
                    3'b100: begin // shift by 1
                        out <= (direction) ? {out[4:0], serial_in} : {serial_in, out[5:1]};
                    end
                    3'b101: begin // rotate by 1
                        out <= (direction) ? {out[4:0], out[5]} : {out[0], out[5:1]};
                    end
                endcase
                leds <= 0;
            end
        end
    end

    assign out_o  = out;
    assign leds_o = leds;

endmodule
