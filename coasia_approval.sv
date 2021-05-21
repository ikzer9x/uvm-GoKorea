   //---------------------------------------------------------------------------
   // Module: coasia_approval
   //   This is the DUT.
   //---------------------------------------------------------------------------

module coasia_approval( coasia_if.coa_mp coa_slave_if );
   import coasia_pkg::*;

   always @ ( posedge coa_slave_if.clk ) begin
      if ( coa_slave_if.kore_sub == 0) begin
	 coa_slave_if.approval <= coasia_transaction::UNKNOWN;
      end else if ( coa_slave_if.lang_cer == coasia_transaction::NONE) begin
	 coa_slave_if.approval <= coasia_transaction::ACCEPT;
	 //coa_slave_if.approval <= coasia_transaction::REJECT;
      end else begin
	 //coa_slave_if.approval <= coasia_transaction::ACCEPT;
	 coa_slave_if.approval <= coasia_transaction::REJECT;
      end
   end
endmodule: coasia_approval
