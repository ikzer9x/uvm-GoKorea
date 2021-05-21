//------------------------------------------------------------------------------
// Interface: coasia_if
//------------------------------------------------------------------------------ 
interface coasia_if( input bit clk );
   logic [2:0] mems;
   logic [1:0] lang_cer;
   logic       kore_sub;
   logic [1:0] approval; 
   clocking master_cb @ ( posedge clk );
      default input #1step output #1ns;
      output mems, lang_cer, kore_sub;
      input  approval;
   endclocking: master_cb 
   clocking slave_cb @ ( posedge clk );
      default input #1step output #1ns;
      input  mems, lang_cer, kore_sub;
      output approval;
   endclocking: slave_cb 
   modport coa_mp ( input clk, mems, lang_cer, kore_sub, output approval );
endinterface: coasia_if 
