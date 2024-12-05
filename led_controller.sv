module led_controller (
    input logic clk,                  // 时钟信号
    input logic reset,                // 异步复位信号
    input logic [1:0] current_state,  // 当前状态 (替代 state_t 类型)
    input logic [1:0] CorrectMemory [4:0], // 固定序列
    input logic [2:0] display_index,  // 当前显示索引
    input logic [2:0] input_index,    // 玩家输入索引
    input logic [3:0] buttons,        // 按钮输入
    output logic [3:0] leds,          // LED 输出
    output logic display_done         // Display 状态完成信号
);

    // 内部寄存器
    logic [2:0] local_display_index;  // 本地显示索引

    // 初始化
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            leds <= 4'b0000;
            local_display_index <= 0;
            display_done <= 1'b0;
        end else begin
            case (current_state)
                2'b00: // IDLE
                    leds <= 4'b1111; // 所有 LED 长亮

                2'b01: // DISPLAY
                    if (local_display_index <= 4) begin
                        leds <= 1 << CorrectMemory[local_display_index];
                        local_display_index <= local_display_index + 1;
                        if (local_display_index == 4)
                            display_done <= 1'b1;
                    end else begin
                        display_done <= 1'b0;
                    end

                2'b10: // INPUT
                    leds <= buttons; // 玩家输入时点亮对应按钮的 LED

                default: 
                    leds <= 4'b0000; // 其他状态 LED 关闭
            endcase
        end
    end
endmodule
