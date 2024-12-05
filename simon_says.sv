module simon_says (
    input logic clk,              // 主时钟信号
    input logic reset,            // 异步复位信号
    input logic [3:0] async_buttons, // 异步按钮输入
    output logic [3:0] leds,      // 游戏状态LED输出
    output logic correctLED,      // 正确输入LED
    output logic wrongLED         // 错误输入LED
);

    // 内部信号
    logic [3:0] synced_buttons;   // 同步后的按钮输入
    logic slow_clk;               // 慢时钟信号
    logic [1:0] CorrectMemory [4:0]; // 固定的正确序列
    logic [1:0] PlayerMemory [4:0];  // 玩家输入序列
    logic [2:0] input_index;      // 玩家输入索引
    logic [2:0] display_index;    // 显示索引
    logic display_done;           // Display状态完成标志
    logic player_input_valid;     // 玩家输入有效标志
    logic input_correct;          // 玩家输入正确标志
    logic input_error;            // 玩家输入错误标志
    logic timer_done;             // 定时完成标志

    // 状态定义
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        DISPLAY = 2'b01,
        INPUT = 2'b10
    } state_t;

    state_t current_state, next_state;

    // 同步模块实例化
    Sync sync_0 (.async_signal(async_buttons[0]), .clk(clk), .synchronized_signal(synced_buttons[0]));
    Sync sync_1 (.async_signal(async_buttons[1]), .clk(clk), .synchronized_signal(synced_buttons[1]));
    Sync sync_2 (.async_signal(async_buttons[2]), .clk(clk), .synchronized_signal(synced_buttons[2]));
    Sync sync_3 (.async_signal(async_buttons[3]), .clk(clk), .synchronized_signal(synced_buttons[3]));

    // 时钟分频模块实例化
    ClockDiv #(.HALF_OF_CLK_CYCLE_VALUE(25000000)) clk_div_inst (
        .clk(clk),
        .slow_clk(slow_clk)
    );

    // 初始化CorrectMemory
    initial begin
        CorrectMemory[0] = 2'b00; // A
        CorrectMemory[1] = 2'b01; // B
        CorrectMemory[2] = 2'b00; // A
        CorrectMemory[3] = 2'b10; // C
        CorrectMemory[4] = 2'b11; // D
    end

    // 状态机逻辑
    always_ff @(posedge slow_clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: 
                if (synced_buttons != 4'b0000) // 任意按键按下
                    next_state = DISPLAY;

            DISPLAY: 
                if (display_done)
                    next_state = INPUT;

            INPUT: 
                if (input_error || timer_done)
                    next_state = IDLE;
                else if (input_correct && input_index == 4)
                    next_state = IDLE;

            default: 
                next_state = IDLE;
        endcase
    end

    // LED控制
    always_ff @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            leds <= 4'b0000;
            display_index <= 0;
        end else begin
            case (current_state)
                IDLE: 
                    leds <= 4'b1111; // 所有LED长亮

                DISPLAY: begin
                    leds <= 1 << CorrectMemory[display_index];
                    if (display_index == 4)
                        display_done <= 1'b1;
                    else
                        display_index <= display_index + 1;
                end

                INPUT: 
                    leds <= synced_buttons; // 玩家输入时点亮对应LED

                default: 
                    leds <= 4'b0000;
            endcase
        end
    end

    // 玩家输入和比较逻辑
    always_ff @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            input_index <= 0;
            PlayerMemory <= '{default: 2'b00};
            player_input_valid <= 1'b0;
            input_error <= 1'b0;
        end else if (current_state == INPUT) begin
            player_input_valid <= (synced_buttons != 4'b0000);
            if (player_input_valid) begin
                PlayerMemory[input_index] <= buttons_to_memory(synced_buttons);
                if (buttons_to_memory(synced_buttons) != CorrectMemory[input_index])
                    input_error <= 1'b1; // 错误立即触发
                else begin
                    input_index <= input_index + 1;
                    if (input_index == 4)
                        input_correct <= 1'b1; // 全部正确
                end
            end
        end
    end

    // 正确和错误LED控制
    always_ff @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            correctLED <= 1'b0;
            wrongLED <= 1'b0;
        end else begin
            correctLED <= (input_correct && input_index == 4);
            wrongLED <= input_error;
        end
    end

    // 按钮到Memory映射函数
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
