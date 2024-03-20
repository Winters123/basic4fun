module bram_dual_dw #(
    parameter DATA_WIDTH = 32, // 数据宽度
    parameter ADDR_WIDTH = 8   // 地址宽度，对应256个地址
)(
    input  wire                        clk,
    input  wire                        rst_n,

    // AXI Stream 写接口
    input  wire                        s_axis_write_tvalid,
    output wire                        s_axis_write_tready,
    input  wire [DATA_WIDTH-1:0]       s_axis_write_tdata,

    // AXI Stream 读接口
    output wire                        m_axis_read_tvalid,
    input  wire                        m_axis_read_tready,
    output wire [DATA_WIDTH-1:0]       m_axis_read_tdata
);

// BRAM存储器
reg [DATA_WIDTH-1:0] bram [0:(1<<ADDR_WIDTH)-1];

// 地址和控制信号
reg [ADDR_WIDTH-1:0] write_addr, read_addr;
reg write_enable, read_valid;

// 写逻辑
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        write_addr <= 0;
        write_enable <= 0;
    end 
    else if (s_axis_write_tvalid && s_axis_write_tready) begin
        bram[write_addr] <= s_axis_write_tdata;
        write_addr <= write_addr + 1;
        write_enable <= 1;
    end 
    else begin
        write_enable <= 0;
    end
end

// 读逻辑
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_addr <= 0;
        read_valid <= 0;
    end 
    else if (m_axis_read_tready && !read_valid) begin
        read_addr <= read_addr + 1;
        read_valid <= 1;
    end 
    else begin
        read_valid <= 0;
    end
end

// AXI Stream 接口信号
assign s_axis_write_tready = !write_enable;
assign m_axis_read_tvalid = read_valid;
assign m_axis_read_tdata = bram[read_addr];

endmodule