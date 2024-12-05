module ClockDiv (
    input logic clk,                // 主时钟输入
    output logic slow_clk           // 慢时钟输出
);
    parameter HALF_OF_CLK_CYCLE_VALUE = 25000000; // 半周期计数值，控制时钟频率
    logic [31:0] count = 0;        // 计数器
    logic clkstate = 0;            // 慢时钟状态

    always_ff @(posedge clk) begin
        if (count == (HALF_OF_CLK_CYCLE_VALUE - 1)) begin
            count <= 0;            // 计数器重置
            clkstate <= ~clkstate; // 翻转慢时钟状态
        end else begin
            count <= count + 1;    // 计数器递增
        end
    end

    assign slow_clk = clkstate;    // 慢时钟输出
endmodule
