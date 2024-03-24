module pifo_queue_concurrent(
    input clk,
    input reset,
    input push,
    input [3:0] priority_in,
    input pop,
    output reg [3:0] priority_out,
    output reg empty,
    output reg full
);

parameter QUEUE_SIZE = 4;
reg [3:0] queue[QUEUE_SIZE-1:0];
reg [2:0] count;

integer i, j;
reg busy; // 简单的锁机制

always @(posedge clk) begin
    if (reset) begin
        count <= 0;
        empty <= 1;
        full <= 0;
        busy <= 0;
    end else if (!busy) begin
        if (push && !full) begin
            busy <= 1; // 锁定队列
            // 插入排序
            queue[count] <= priority_in;
            for (i = count; i > 0; i=i-1) begin
                if (queue[i] > queue[i-1]) begin
                    // 交换元素
                    j = queue[i];
                    queue[i] = queue[i-1];
                    queue[i-1] = j;
                end
            end
            count <= count + 1;
            empty <= 0;
            if (count == QUEUE_SIZE - 1) full <= 1;
            busy <= 0; // 解锁队列
        end else if (pop && !empty) begin
            busy <= 1; // 锁定队列
            // 出队操作
            priority_out <= queue[0];
            for (i = 0; i < count - 1; i=i+1) begin
                queue[i] = queue[i+1];
            end
            count <= count - 1;
            full <= 0;
            if (count == 1) empty <= 1;
            busy <= 0; // 解锁队列
        end
    end
end

endmodule