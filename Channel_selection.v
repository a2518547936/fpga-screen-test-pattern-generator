`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/14 14:58:56
// Design Name: 
// Module Name: Channel_selection
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Channel_selection(
input                       clk,
input                       rstn,
input   [15:0]              HS_display,
input   [15:0]              current_V,
input   [3:0]               model,
input                       HS_i,
input                       VS_i,
input                       DE_i,
input   [29:0]              DATA_i,
output  reg                 HS_o,
output  reg                 VS_o,
output  reg                 DE_o,
output  reg  [119:0]        DATA_o
    );

reg [29:0]  DATA_d;
reg         HS_d,VS_d,DE_d;
reg [15:0]  HS_display_d;
reg [15:0]  current_V_d;
reg         DE_d1,DE_d2,DE_d3,DE_d4,DE_d5;
reg         HS_d1,HS_d2,HS_d3,HS_d4,HS_d5;
reg         VS_d1,VS_d2,VS_d3,VS_d4,VS_d5;

reg [1:0]   wren,rden;          // enable of write and read 
reg [15:0]   addr_wr_single,addr_wr_double,addr_rd;    // addr of write and read 
reg [15:0]   addr_rd_d,addr_rd_d1,addr_rd_d2;

reg [15:0]  addr_rd_double,addr_rd_single;
reg [59:0] ping_dout,pong_dout;
   
wire [29:0] ping_dout_double,ping_dout_single;          // output data
wire [29:0] pong_dout_double,pong_dout_single;          // output data

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        DATA_d  <=  30'd0;
        HS_d    <=  1'b0;
        VS_d    <=  1'b0;
        DE_d    <=  1'b0;
    end
    else begin
        DATA_d  <=  DATA_i;
        HS_d    <=  HS_i;
        VS_d    <=  VS_i;
        DE_d    <=  DE_i;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        HS_display_d    <=  16'd0;
        current_V_d     <=  16'd0;
    end
    else begin
        HS_display_d    <=  HS_display;
        current_V_d     <=  current_V;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        HS_d1   <=  1'b0;
        HS_d2   <=  1'b0;
        HS_d3   <=  1'b0;
        HS_d4   <=  1'b0;
        HS_d5   <=  1'b0;
        VS_d1   <=  1'b0;
        VS_d2   <=  1'b0;
        VS_d3   <=  1'b0;
        VS_d4   <=  1'b0;
        VS_d5   <=  1'b0;
    end
    else begin
        HS_d1   <=  HS_d;
        HS_d2   <=  HS_d1;
        HS_d3   <=  HS_d2;
        HS_d4   <=  HS_d3;
        HS_d5   <=  HS_d4;
        VS_d1   <=  VS_d;
        VS_d2   <=  VS_d1;
        VS_d3   <=  VS_d2;
        VS_d4   <=  VS_d3;
        VS_d5   <=  VS_d4;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        DE_d1   <=  1'b0;
        DE_d2   <=  1'b0;
        DE_d3   <=  1'b0;
        DE_d4   <=  1'b0;
        DE_d5   <=  1'b0;
    end
    else if(current_V_d >= 1)
    begin
        DE_d1   <=  DE_d;
        DE_d2   <=  DE_d1;
        DE_d3   <=  DE_d2;
        DE_d4   <=  DE_d3;
        DE_d5   <=  DE_d4;
    end
    else
    begin
        DE_d1   <=  1'b0;
        DE_d2   <=  1'b0;
        DE_d3   <=  1'b0;
        DE_d4   <=  1'b0;
        DE_d5   <=  1'b0;
    end
end

//  write enable
always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        wren    <=  2'b00;
    end
    else if(VS_i && DE_i)
    begin
        wren    <=  (current_V_d[0]) ? 2'b10:2'b01;
    end
    else
    begin
        wren    <=  2'b00;
    end
end

// read enable
always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        rden    <=  2'b00;
    end
    else if(current_V_d > 0 )
    begin
        rden    <=  (current_V_d[0]) ? 2'b01:2'b10;
    end
    else
    begin
        rden    <=  2'b00;
    end
end

//  write addr

reg signal_1_0;
reg signal_1_1;
reg signal_1_2;

reg signal_2_0;
reg signal_2_1;
reg signal_2_2;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        signal_1_0  <=  1'b0;
        signal_1_1  <=  1'b0;
        signal_1_2  <=  1'b0;
    end
    else begin
        signal_1_0  <=  ((~DE_i) && (addr_wr_single >= (HS_display_d << 1))) ? 1'b1:1'b0;
        signal_1_1  <=  (addr_wr_single == (HS_display_d - 16'd3)) ? 1'b1:1'b0;
        signal_1_2  <=  1'b0;
    end    
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        signal_2_0  <=  1'b0;
        signal_2_1  <=  1'b0;
        signal_2_2  <=  1'b0;
    end
    else begin
        signal_2_0  <=  ((~DE_i) && (addr_wr_double >= (HS_display_d << 1))) ? 1'b1:1'b0;
        signal_2_1  <=  (addr_wr_double == (HS_display_d - 4)) ? 1'b1:1'b0;
        signal_2_2  <=  1'b0;
    end    
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        addr_wr_single <=  16'd0;
    end
    else if(DE_i)
    begin
        if(signal_1_0)
        begin
            addr_wr_single <=  16'd1;
        end
        else if(signal_1_1) begin
            addr_wr_single <=  HS_display_d;
        end
        else
        begin
            addr_wr_single <=  addr_wr_single + 16'd2;
        end
    end
    else 
    begin
        addr_wr_single <=  {16{1'b1}};
    end
end

always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        addr_wr_double <=  16'd0;
    end
    else if(DE_i)
    begin
        if(signal_2_0)
        begin
            addr_wr_double <=  16'd0;
        end
        else if(signal_2_1) begin
            addr_wr_double <=  HS_display_d + 16'd1;
        end
        else
        begin
            addr_wr_double <=  addr_wr_double + 16'd2;
        end
    end
    else 
    begin
        addr_wr_double <=  {16{1'b1}};
    end
end

//  read addr
always @(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        addr_rd <=  16'd0;
    end
    else if(DE_i)
    begin
        if(addr_rd >= HS_display_d)
        begin
            addr_rd <=  16'd0;
        end
        else
        begin
            addr_rd <=  addr_rd + 16'd1;
        end
    end
    else 
    begin
        addr_rd <=  {16{1'b1}};
    end
end

always @(posedge clk or negedge rstn) begin
if(!rstn) begin
    addr_rd_d   <=  16'd0;
    addr_rd_d1  <=  16'd0;
    addr_rd_d2  <=  16'd0;
end
else begin
    addr_rd_d   <=  addr_rd;
    addr_rd_d1  <=  addr_rd_d;
    addr_rd_d2  <=  addr_rd_d1;
end 
end

always @(posedge clk or negedge rstn) begin
if(!rstn) begin
    addr_rd_double <= 16'd0;
    addr_rd_single <= 16'd1;
end
else begin
    addr_rd_double <= (addr_rd[0] == 1'b0) ? addr_rd:addr_rd + HS_display_d;
    addr_rd_single <= (addr_rd[0] == 1'b1) ? addr_rd:addr_rd + HS_display_d;
end
end

/*-------------------------------------↑↑?-------------------------------------------*/

/**********************************************************************************************/

/*-------------------------------------↓↓?-------------------------------------------*/
// ram

ping_0 u_ping_0 (
  .clka(clk),    // input wire clka
  .ena(wren[0]),      // input wire ena
  .wea(wren[0]),      // input wire [0 : 0] wea
  .addra(addr_wr_double),  // input wire [9 : 0] addra
  .dina(DATA_d),    // input wire [29 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(rden[0]),      // input wire enb
  .addrb(addr_rd_double),  // input wire [9 : 0] addrb
  .doutb(ping_dout_double)  // output wire [29 : 0] doutb
);

ping_1 u_ping_1 (
  .clka(clk),    // input wire clka
  .ena(wren[0]),      // input wire ena
  .wea(wren[0]),      // input wire [0 : 0] wea
  .addra(addr_wr_single),  // input wire [9 : 0] addra
  .dina(DATA_d),    // input wire [29 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(rden[0]),      // input wire enb
  .addrb(addr_rd_single),  // input wire [9 : 0] addrb
  .doutb(ping_dout_single)  // output wire [29 : 0] doutb
);

pong_0 u_pong_0 (
  .clka(clk),    // input wire clka
  .ena(wren[1]),      // input wire ena
  .wea(wren[1]),      // input wire [0 : 0] wea
  .addra(addr_wr_double),  // input wire [9 : 0] addra
  .dina(DATA_d),    // input wire [29 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(rden[1]),      // input wire enb
  .addrb(addr_rd_double),  // input wire [9 : 0] addrb
  .doutb(pong_dout_double)  // output wire [29 : 0] doutb
);

pong_1 u_pong_1 (
  .clka(clk),    // input wire clka
  .ena(wren[1]),      // input wire ena
  .wea(wren[1]),      // input wire [0 : 0] wea
  .addra(addr_wr_single),  // input wire [9 : 0] addra
  .dina(DATA_d),    // input wire [29 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(rden[1]),      // input wire enb
  .addrb(addr_rd_single),  // input wire [9 : 0] addrb
  .doutb(pong_dout_single)  // output wire [29 : 0] doutb
);

always @(posedge clk or negedge rstn) begin
if(!rstn) begin
    ping_dout <=  60'd0;
    pong_dout <=  60'd0;
end
else begin
    ping_dout <=  (addr_rd_d2[0] == 1'b0) ? {ping_dout_single,ping_dout_double}:{ping_dout_double,ping_dout_single};
    pong_dout <=  (addr_rd_d2[0] == 1'b0) ? {pong_dout_single,pong_dout_double}:{pong_dout_double,pong_dout_single};
end
end

/*-------------------------------------↑↑?-------------------------------------------*/

/**********************************************************************************************/

/*-------------------------------------↓↓?-------------------------------------------*/
// output selection

always @(posedge clk or negedge rstn) begin
if(!rstn) begin
        DATA_o[119:0]   <= 120'd0;
        HS_o            <= 1'b0;
        VS_o            <= 1'b0;
        DE_o            <= 1'b0;
end
else begin
    case(model[2:0])
    3'b000:
    begin
        DATA_o[29:0]    <= DATA_d;
        DATA_o[119:30]  <= 90'd0;
        HS_o            <= HS_d;
        VS_o            <= VS_d;
        DE_o            <= DE_d;
    end
    3'b001:
    begin
        DATA_o[29:0]    <= DATA_d;
        DATA_o[59:30]   <= DATA_d;
        DATA_o[119:60]  <= 60'd0;
        HS_o            <= HS_d;
        VS_o            <= VS_d;
        DE_o            <= DE_d;
    end
    3'b010:
    begin
        DATA_o[59:0]    <= (current_V_d[0] == 1'b1) ? ping_dout:pong_dout;
        DATA_o[119:60]  <= 60'd0;
        HS_o            <= HS_d4;
        VS_o            <= VS_d4;
        DE_o            <= DE_d4;
    end
    3'b011:
    begin
        DATA_o[29:0]    <= DATA_d;
        DATA_o[59:30]   <= DATA_d;
        DATA_o[89:60]   <= DATA_d;
        DATA_o[119:90]  <= DATA_d;
        HS_o <= HS_d;
        VS_o <= VS_d;
        DE_o <= DE_d;
    end
    3'b100:
    begin
        DATA_o[59:0]  <= (current_V_d[0] == 0) ? {ping_dout[29:0],ping_dout[29:0]}:{pong_dout[29:0],pong_dout[29:0]};
        DATA_o[119:60]  <= (current_V_d[0] == 0) ? {ping_dout[59:30],ping_dout[59:30]}:{pong_dout[59:30],pong_dout[59:30]};
        HS_o <= HS_d4;
        VS_o <= VS_d4;
        DE_o <= DE_d4;
    end
    default begin
        DATA_o[119:0]  <= 120'd0;
        HS_o <= 1'b0;
        VS_o <= 1'b0;
        DE_o <= 1'b0;
    end
    endcase
end
end

endmodule