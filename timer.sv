module timer (
    input logic clk,
    input logic reset,
    input logic start_timer,
    output logic timer_done
);

    logic [23:0] counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else if (start_timer)
            counter <= 50_000_000; // 1秒
        else if (counter > 0)
            counter <= counter - 1;
    end

    assign timer_done = (counter == 0);
endmodule
