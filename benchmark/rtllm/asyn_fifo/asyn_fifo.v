module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input               wclk,
    input               rclk,
    input               wrstn,
    input               rrstn,
    input               winc,
    input               rinc,
    input  [WIDTH-1:0]  wdata,

    output wire         wfull,
    output wire         rempty,
    output wire [WIDTH-1:0] rdata
);

    // Calculate address width
    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Write and read pointer signals
    reg [ADDR_WIDTH:0] wptr_bin, rptr_bin;
    reg [ADDR_WIDTH:0] wptr_gray, rptr_gray;
    
    // Synchronized pointers
    wire [ADDR_WIDTH:0] wptr_syn, rptr_syn;
    
    // Address signals
    wire [ADDR_WIDTH-1:0] waddr, raddr;

    // Gray code conversion functions
    function [ADDR_WIDTH:0] bin_to_gray(input [ADDR_WIDTH:0] bin);
        bin_to_gray = bin ^ (bin >> 1);
    endfunction

    function [ADDR_WIDTH:0] gray_to_bin(input [ADDR_WIDTH:0] gray);
        reg [ADDR_WIDTH:0] bin;
        begin
            bin = gray;
            for (int i = 1; i <= ADDR_WIDTH; i = i + 1)
                bin = bin ^ (bin >> i);
            gray_to_bin = bin;
        end
    endfunction

    // Dual-port RAM for data storage
    dual_port_ram #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) ram_inst (
        .wclk(wclk),
        .wenc(winc & ~wfull),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .renc(rinc & ~rempty),
        .raddr(raddr),
        .rdata(rdata)
    );

    // Write pointer logic
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            wptr_bin <= 0;
            wptr_gray <= 0;
        end else if (winc && ~wfull) begin
            wptr_bin <= wptr_bin + 1;
            wptr_gray <= bin_to_gray(wptr_bin + 1);
        end
    end

    // Read pointer logic
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            rptr_bin <= 0;
            rptr_gray <= 0;
        end else if (rinc && ~rempty) begin
            rptr_bin <= rptr_bin + 1;
            rptr_gray <= bin_to_gray(rptr_bin + 1);
        end
    end

    // Write pointer synchronizer (CDC)
    sync_ff #(
        .WIDTH(ADDR_WIDTH + 1)
    ) wptr_sync (
        .clk(wclk),
        .rst_n(wrstn),
        .din(rptr_gray),
        .dout(rptr_syn)
    );

    // Read pointer synchronizer (CDC)
    sync_ff #(
        .WIDTH(ADDR_WIDTH + 1)
    ) rptr_sync (
        .clk(rclk),
        .rst_n(rrstn),
        .din(wptr_gray),
        .dout(wptr_syn)
    );

    // Full condition logic
    assign wfull = (wptr_gray == {~rptr_syn[ADDR_WIDTH:ADDR_WIDTH-1], rptr_syn[ADDR_WIDTH-2:0]});

    // Empty condition logic
    assign rempty = (rptr_gray == wptr_syn);

    // Address generation
    assign waddr = wptr_bin[ADDR_WIDTH-1:0];
    assign raddr = rptr_bin[ADDR_WIDTH-1:0];

endmodule

// Dual-port RAM module
module dual_port_ram #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input                   wclk,
    input                   wenc,
    input  [$clog2(DEPTH)-1:0] waddr,
    input  [WIDTH-1:0]      wdata,
    input                   rclk,
    input                   renc,
    input  [$clog2(DEPTH)-1:0] raddr,
    output reg [WIDTH-1:0]  rdata
);
    reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

    // Write logic
    always @(posedge wclk) begin
        if (wenc) begin
            RAM_MEM[waddr] <= wdata;
        end
    end

    // Read logic
    always @(posedge rclk) begin
        if (renc) begin
            rdata <= RAM_MEM[raddr];
        end
    end
endmodule

// Synchronizer module for Clock Domain Crossing
module sync_ff #(
    parameter WIDTH = 8
)(
    input               clk,
    input               rst_n,
    input  [WIDTH-1:0]  din,
    output [WIDTH-1:0]  dout
);
    reg [WIDTH-1:0] sync_reg1, sync_reg2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg1 <= 0;
            sync_reg2 <= 0;
        end else begin
            sync_reg1 <= din;
            sync_reg2 <= sync_reg1;
        end
    end

    assign dout = sync_reg2;
endmodule