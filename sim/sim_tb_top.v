//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor             : Xilinx
// \   \   \/    Version	    : 3.6.1
//  \   \        Application	    : MIG
//  /   /        Filename           : sim_tb_top.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
// \   \  /  \   Date Created       : Mon May 14 2007
//  \___\/\___\
//
// Device      : Spartan-3/3E/3A/3A-DSP
// Design Name : DDR SDRAM
// Purpose     : This is the simulation testbench which is used to verify the
//               design. The basic clocks and resets to the interface are
//               generated here. This also connects the memory interface to the
//               memory model.
//*****************************************************************************

`timescale 1ns / 100ps

`include "../rtl/mig_parameters_0.v"

  module sim_tb_top;

   localparam DEVICE_WIDTH = 32; // Memory device data width
   localparam REG_ENABLE   = `REGISTERED; // registered addr/ctrl

   localparam real CLK_PERIOD_NS      = 10;
   localparam real TCYC_200           = 5.0;
   localparam real TPROP_DQS          = 0.00;      // Delay for DQS signal during Write Operation
   localparam real TPROP_DQS_RD       = 0.05;      // Delay for DQS signal during Read Operation
   localparam real TPROP_PCB_CTRL     = 0.00;      // Delay for Address and Ctrl signals
   localparam real TPROP_PCB_DATA     = 0.00;      // Delay for data signal during Write operation
   localparam real TPROP_PCB_DATA_RD  = 0.00;      // Delay for data signal during Read operation

   reg                       sys_clk;
   reg                       sys_rst_n;
   wire                      sys_rst_out;
   reg [(`ROW_ADDRESS-1):0]  ddr_address_reg;
   reg [(`BANK_ADDRESS-1):0] ddr_ba_reg;
   reg [(`CKE_WIDTH-1):0]    ddr_cke_reg;
   reg                       ddr_ras_l_reg;
   reg                       ddr_cas_l_reg;
   reg                       ddr_we_l_reg;
   reg [(`NO_OF_CS-1):0]     ddr_cs_l_reg;

   wire                              sys_clk_n;
   wire                              sys_clk_p;
   wire [(`DATA_WIDTH-1):0]          ddr_dq_sdram;
   wire [(`DATA_STROBE_WIDTH-1):0]   ddr_dqs_sdram;
   wire [(`DATA_MASK_WIDTH-1):0]     ddr_dm_sdram;
   reg  [(`DATA_MASK_WIDTH-1):0]     ddr_dm_sdram_tmp;
   reg                               ddr_clk_sdram;
   reg                               ddr_clk_n_sdram;
   reg  [(`ROW_ADDRESS-1):0]         ddr_address_sdram;
   reg  [(`BANK_ADDRESS-1):0]        ddr_ba_sdram;
   reg                               ddr_ras_l_sdram;
   reg                               ddr_cas_l_sdram;
   reg                               ddr_we_l_sdram;
   reg  [(`NO_OF_CS-1):0]            ddr_cs_l_sdram;
   reg  [(`CKE_WIDTH-1):0]           ddr_cke_sdram;

   wire [(`DATA_WIDTH-1):0]          ddr_dq_fpga;
   wire [(`DATA_STROBE_WIDTH-1):0]   ddr_dqs_fpga;
   wire [(`DATA_MASK_WIDTH-1):0]     ddr_dm_fpga;
   wire                              ddr_clk_fpga;
   wire                              ddr_clk_n_fpga;
   wire [(`ROW_ADDRESS-1):0]         ddr_address_fpga;
   wire [(`BANK_ADDRESS-1):0]        ddr_ba_fpga;
   wire                              ddr_ras_l_fpga;
   wire                              ddr_cas_l_fpga;
   wire                              ddr_we_l_fpga;
   wire [(`NO_OF_CS-1):0]            ddr_cs_l_fpga;
   wire [(`CKE_WIDTH-1):0]           ddr_cke_fpga;

   // Only RDIMM memory parts support the reset signal,
   // hence the ddr_reset_n signal can be ignored for other memory parts
   wire 			     #(TPROP_PCB_CTRL) ddr_reset_n;

//ddr2_dm_8_16 signal will be driven only for x16 components are selected
   wire [1:0]                                          ddr_dm_8_16_sdram;
   wire 			                       init_done;
   wire 			                       rst_dqs_div_loop;


   

   initial
     sys_clk = 1'b0;
   always
     sys_clk = #(CLK_PERIOD_NS/2) ~sys_clk;

   assign sys_clk_p = sys_clk;
   assign sys_clk_n = ~sys_clk;


 // Generate Reset
   initial begin
      sys_rst_n = 1'b0;
      #200;
      sys_rst_n = 1'b1;
   end

   assign sys_rst_out = `RESET_ACTIVE_LOW ? sys_rst_n : ~sys_rst_n;


   

// =============================================================================
//                             BOARD Parameters
// =============================================================================
// These parameter values can be changed to model varying board delays
// between the Spartan device and the memory model

  always @(*) begin
    ddr_clk_sdram       <=  #(TPROP_PCB_CTRL) ddr_clk_fpga;
    ddr_clk_n_sdram     <=  #(TPROP_PCB_CTRL) ddr_clk_n_fpga;
    ddr_address_sdram   <=  #(TPROP_PCB_CTRL) ddr_address_fpga;
    ddr_ba_sdram        <=  #(TPROP_PCB_CTRL) ddr_ba_fpga;
    ddr_ras_l_sdram     <=  #(TPROP_PCB_CTRL) ddr_ras_l_fpga;
    ddr_cas_l_sdram     <=  #(TPROP_PCB_CTRL) ddr_cas_l_fpga;
    ddr_we_l_sdram      <=  #(TPROP_PCB_CTRL) ddr_we_l_fpga;
    ddr_cs_l_sdram      <=  #(TPROP_PCB_CTRL) ddr_cs_l_fpga;
    ddr_cke_sdram       <=  #(TPROP_PCB_CTRL) ddr_cke_fpga;
    ddr_dm_sdram_tmp    <=  #(TPROP_PCB_CTRL) ddr_dm_fpga;
  end

  assign ddr_dm_sdram = ddr_dm_sdram_tmp;

// Controlling the bi-directional BUS
  genvar dqwd;
  generate
    for (dqwd = 0;dqwd < `DATA_WIDTH;dqwd = dqwd+1) begin : dq_delay
      WireDelay #
       (
        .Delay_g     (TPROP_PCB_DATA),
        .Delay_rd    (TPROP_PCB_DATA_RD)
       )
      u_delay_dq
       (
        .A           (ddr_dq_fpga[dqwd]),
        .B           (ddr_dq_sdram[dqwd]),
	.reset       (sys_rst_n)
       );
    end
  endgenerate

  genvar dqswd;
  generate
    for (dqswd = 0;dqswd < `DATA_STROBE_WIDTH;dqswd = dqswd+1) begin : dqs_delay
      WireDelay #
       (
        .Delay_g     (TPROP_DQS),
        .Delay_rd    (TPROP_DQS_RD)
       )
      u_delay_dqs
       (
        .A           (ddr_dqs_fpga[dqswd]),
        .B           (ddr_dqs_sdram[dqswd]),
	.reset       (sys_rst_n)
       );
    end
  endgenerate

   //***************************************************************************
   // FPGA memory controller
   //***************************************************************************
   mig mem_interface_top0
      (
       .sys_clk_in                   (sys_clk_p),

       .reset_in_n                   (sys_rst_out),
       .cntrl0_ddr_dq                (ddr_dq_fpga),
       .cntrl0_ddr_dqs               (ddr_dqs_fpga),
       .cntrl0_ddr_dm                (ddr_dm_fpga),
       .cntrl0_ddr_ck                (ddr_clk_fpga),
       .cntrl0_ddr_ck_n              (ddr_clk_n_fpga),
       .cntrl0_ddr_a                 (ddr_address_fpga),
       .cntrl0_ddr_ba                (ddr_ba_fpga),
       .cntrl0_ddr_ras_n             (ddr_ras_l_fpga),
       .cntrl0_ddr_cas_n             (ddr_cas_l_fpga),
       .cntrl0_ddr_we_n              (ddr_we_l_fpga),
       .cntrl0_ddr_cs_n              (ddr_cs_l_fpga),
       .cntrl0_ddr_cke               (ddr_cke_fpga),
       .cntrl0_led_error_output1     (error),
       .cntrl0_data_valid_out        (cntrl0_data_valid_out),
       .cntrl0_init_done             (init_done),
       .cntrl0_rst_dqs_div_in        (rst_dqs_div_loop),
       .cntrl0_rst_dqs_div_out       (rst_dqs_div_loop)
       );

   //***************************************************************************
   // Extra one clock pipelining for RDIMM address and
   // control signals is implemented here (Implemented external to memory model)
   //***************************************************************************
   always @( posedge ddr_clk_sdram ) begin
      if ( ddr_reset_n == 1'b0 ) begin
         ddr_ras_l_reg <= 1'b1;
         ddr_cas_l_reg <= 1'b1;
         ddr_we_l_reg  <= 1'b1;
         ddr_cs_l_reg  <= 1'b1;
         ddr_cke_reg   <= 1'b0;
      end
      else begin
         ddr_address_reg <= #(CLK_PERIOD_NS/2) ddr_address_sdram;
         ddr_ba_reg      <= #(CLK_PERIOD_NS/2) ddr_ba_sdram;
         ddr_ras_l_reg   <= #(CLK_PERIOD_NS/2) ddr_ras_l_sdram;
         ddr_cas_l_reg   <= #(CLK_PERIOD_NS/2) ddr_cas_l_sdram;
         ddr_we_l_reg    <= #(CLK_PERIOD_NS/2) ddr_we_l_sdram;
         ddr_cs_l_reg    <= #(CLK_PERIOD_NS/2) ddr_cs_l_sdram;
         ddr_cke_reg     <= #(CLK_PERIOD_NS/2) ddr_cke_sdram;
      end
   end

   /////////////////////////////////////////////////////////////////////////////
   // Memory model instances
   /////////////////////////////////////////////////////////////////////////////

// memory part is x32
    mobile_ddr u_mem0
    (
        .Dq    (ddr_dq_sdram),
        .Dqs   (ddr_dqs_sdram),
        .Addr  (ddr_address_sdram),
        .Ba    (ddr_ba_sdram),
        .Clk   (ddr_clk_sdram),
        .Clk_n (ddr_clk_n_sdram),
        .Cke   (ddr_cke_sdram),
        .Cs_n  (ddr_cs_l_sdram[0]),
        .Ras_n (ddr_ras_l_sdram),
        .Cas_n (ddr_cas_l_sdram),
        .We_n  (ddr_we_l_sdram),
        .Dm    (ddr_dm_sdram)
    );

   

 endmodule
