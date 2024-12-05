module Sync (
    input logic async_signal, // 异步输入信号
    input logic clk,          // 时钟信号
    output logic synchronized_signal // 同步后的输出信号
);
    // 内部寄存器用于同步阶段
    logic intermediate_sync_0, intermediate_sync_1, intermediate_sync_2;

    always_ff @(posedge clk) begin
        intermediate_sync_0 <= async_signal; // 第一级同步
        intermediate_sync_1 <= intermediate_sync_0; // 第二级同步
        intermediate_sync_2 <= intermediate_sync_1; // 第三级同步
    end

    // 同步后的输出
    assign synchronized_signal = (!intermediate_sync_1 && intermediate_sync_2); // 上升沿检测
endmodule
