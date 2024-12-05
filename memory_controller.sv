module memory_controller (
    input logic clk,
    input logic reset,
    input logic [3:0] buttons,
    output logic [1:0] CorrectMemory [4:0],
    output logic [1:0] PlayerMemory [4:0],
    output logic [2:0] input_index,
    output logic player_input_valid,
    output logic input_correct,
    output logic input_error
);

    // 初始化 CorrectMemory
    initial begin
        CorrectMemory[0] = 2'b00; // A
        CorrectMemory[1] = 2'b01; // B
        CorrectMemory[2] = 2'b00; // A
        CorrectMemory[3] = 2'b10; // C
        CorrectMemory[4] = 2'b11; // D
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            input_index <= 0;
            PlayerMemory <= '{default: 2'b00};
            player_input_valid <= 1'b0;
            input_error <= 1'b0;
        end else begin
            player_input_valid <= (buttons != 4'b0000);
            if (player_input_valid) begin
                PlayerMemory[input_index] <= buttons_to_memory(buttons);
                input_index <= input_index + 1;

                // 输入比较
                if (buttons_to_memory(buttons) != CorrectMemory[input_index])
                    input_error <= 1'b1;
            end
        end
    end

    function [1:0] buttons_to_memory(input logic [3:0] btns);
        case (btns)
            4'b0001: buttons_to_memory = 2'b00; // A
            4'b0010: buttons_to_memory = 2'b01; // B
            4'b0100: buttons_to_memory = 2'b10; // C
            4'b1000: buttons_to_memory = 2'b11; // D
            default: buttons_to_memory = 2'b00;
        endcase
    endfunction
endmodule
