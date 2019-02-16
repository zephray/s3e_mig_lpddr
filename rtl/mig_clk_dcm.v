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
// Copyright 2005, 2006, 2007 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor             : Xilinx
// \   \   \/    Version            : 3.6.1
//  \   \        Application	    : MIG
//  /   /        Filename           : mig_clk_dcm.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:43 $
// \   \  /  \   Date Created       : Mon May 2 2005
//  \___\/\___\
// Device       : Spartan-3/3E/3A/3A-DSP
// Design Name  : DDR SDRAM
// Purpose      : This module has the DCM instantiation.
//*****************************************************************************

`timescale 1ns/100ps

module mig_clk_dcm
  (
   input  input_clk,
   input  rst,
   output clk,
   output clk90,
   output dcm_lock
   );

  localparam GND = 1'b0;

   wire clk0dcm;
   wire clk90dcm;
   wire clk0_buf;
   wire clk90_buf;
   wire dcm1_lock;

   assign clk   = clk0_buf;
   assign clk90 = clk90_buf;
   assign dcm_lock = dcm1_lock;

   DCM # 
     (
      .DLL_FREQUENCY_MODE    ("LOW"),
      .DUTY_CYCLE_CORRECTION ("TRUE")
      )
     DCM_INST1
     (
      .CLKIN    (input_clk),
      .CLKFB    (clk0_buf),
      .DSSEN    (GND),
      .PSINCDEC (GND),
      .PSEN     (GND),
      .PSCLK    (GND),
      .RST      (rst),
      .CLK0     (clk0dcm),
      .CLK90    (clk90dcm),
      .CLK180   (),
      .CLK270   (),
      .CLK2X    (),
      .CLK2X180 (),
      .CLKDV    (),
      .CLKFX    (),
      .CLKFX180 (),
      .LOCKED   (dcm1_lock),
      .PSDONE   (),
      .STATUS   ()
      );
   
   BUFG BUFG_CLK0
     (
      .O  (clk0_buf),
      .I  (clk0dcm)
      );   
   
   BUFG BUFG_CLK90
     (
      .O  (clk90_buf),
      .I  (clk90dcm)
      );


endmodule
