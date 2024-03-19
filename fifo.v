module fifo_dw #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 32
)(
    input wire clk,
    input wire rst_n,

    //AXI Stream Input Interface
    input wire [DATA_WIDTH-1:0] s_axis_tdata,
    input wire s_axis_tvalid,
    output wire s_axis_tready,
    input wire s_axis_tlast,

    //AXI Stream Output Interface
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input wire m_axis_tready,
    output wire m_axis_tlast,

    //FIFO Status Signals
    output wire full,
    output wire empty
);

//FIFO memory
reg [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH-1:0];
reg [4:0] write_ptr;
reg [4:0] read_ptr;
reg [4:0] fifo_count;

//FIFO write
assign s_axis_tready = ~full;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        write_ptr <= 0;
        fifo_count <= 0;
    end else if (s_axis_tvalid && s_axis_tready) begin
        write_ptr <= write_ptr + 1; //Write pointer increment as a ring
        fifo_mem[write_ptr] <= s_axis_tdata;
        fifo_count <= fifo_count + 1;
    end
end

//FIFO read
assign m_axis_tdata = fifo_mem[read_ptr];
assign m_axis_tvalid = ~empty;
assign m_axis_tlast = 0;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        read_ptr <= 0;
    end else if (m_axis_tready && m_axis_tvalid) begin
        read_ptr <= read_ptr + 1; //Read pointer increment as a ring
        fifo_count <= fifo_count - 1;
    end
end

//FIFO status
assign full = (fifo_count == FIFO_DEPTH);
assign empty = (fifo_count == 0);

endmodule