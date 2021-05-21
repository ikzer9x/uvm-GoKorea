//---------------------------------------------------------------------------
// Author  : CoA/TrungPham
// Date    : 28/10/2020
// Version : 0.0
//--------------------------------------------------------------------------- 
`include "coasia_pkg.sv"
`include "coasia_approval.sv"
`include "coasia_if.sv"
   //---------------------------------------------------------------------------
   // Module: top
   //--------------------------------------------------------------------------- 
   module top;
   import uvm_pkg::*;

   reg clk;
   coasia_if     coa_slave_if( clk );
   coasia_approval coa_approvalr( coa_slave_if ); // DUT

   initial begin
      clk = 0;
      #5ns ;
      forever #5ns clk = ! clk;
   end

   initial begin
      uvm_resource_db#( virtual coasia_if )::set
	( .scope( "ifs" ), .name( "coasia_if" ), .val( coa_slave_if ) );
      run_test();
   end
endmodule: top 
