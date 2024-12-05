module led_controller (
    input logic clk,
    input logic reset,
    input state_t current_state,
    input logic [1:0] CorrectMemory [4:0],
    input logic [2:0] display_index,
    input logic [2:0] input_index,
    input logic [3:0] buttons,
    output logic [3:0] leds,
    output logic display_done
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            leds <= 4'b0000;
            display_index <= 0;
        end else if (current_state == DISPLAY) begin
            leds <= 1 << CorrectMemory[display_index];
            if (display_index == 4)
                display_done <= 1'b1;
            else
                display_index <= display_index + 1;
        end else if (current_state == INPUT && buttons != 4'b0000) begin
            leds <= buttons;
        end else begin
            leds <= 4'b0000;
            display_done <= 1'b0;
        end
    end
endmodule
