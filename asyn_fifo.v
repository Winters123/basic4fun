module async_fifo #(
    parameter DATA_WIDTH = 8, // Data width
    parameter FIFO_DEPTH = 16, // Number of slots in the FIFO
    parameter ADDR_WIDTH = 4  // Address width, log2(FIFO_DEPTH)
)(
    input wr_clk, // Write clock
    input rd_clk, // Read clock
    input rst_n,  // Asynchronous reset, active low
    input [DATA_WIDTH-1:0] wr_data, // Data input
    input wr_en,  // Write enable
    input rd_en,  // Read enable
    input [DATA_WIDTH-1:0] rd_data,     // Data output
    output reg [DATA_WIDTH-1:0] rd_data, // Data output
    output reg fifo_full,  // FIFO full flag
    output reg fifo_empty  // FIFO empty flag
);

// FIFO memory
reg [DATA_WIDTH-1:0] fifo_mem[FIFO_DEPTH-1:0];

// Write and read pointers
reg [ADDR_WIDTH:0] wr_ptr = 0;
reg [ADDR_WIDTH:0] rd_ptr = 0;

// Write operation
always @(posedge wr_clk or negedge rst_n) begin
    if (~rst_n) begin
        wr_ptr <= 0;
    end 
    else if (wr_en && !fifo_full) begin
        fifo_mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
        wr_ptr <= wr_ptr + 1;
    end
end

// Read operation
always @(posedge rd_clk or negedge rst_n) begin
    if (~rst_n) begin
        rd_ptr <= 0;
        rd_data <= 0; // Clear data on reset
    end 
    else if (rd_en && !fifo_empty) begin
        rd_data <= fifo_mem[rd_ptr[ADDR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
    end
end

// FIFO full and empty logic
always @(*) begin
    fifo_full = (wr_ptr[ADDR_WIDTH:0] == {~rd_ptr[ADDR_WIDTH], rd_ptr[ADDR_WIDTH-1:0]});
    fifo_empty = (wr_ptr == rd_ptr);
end


endmodule
