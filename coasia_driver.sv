   //---------------------------------------------------------------------------
   // Class: coasia_driver
   //--------------------------------------------------------------------------- 
class coasia_driver extends uvm_driver#( coasia_transaction );

   `uvm_component_utils( coasia_driver ) 
   virtual coasia_if coa_vi; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      void'( uvm_resource_db#( virtual coasia_if )::read_by_name
	     ( .scope( "ifs" ), .name( "coasia_if" ), .val( coa_vi ) ) );
   endfunction: build_phase 

   task run_phase( uvm_phase phase );
      coasia_transaction coa_tx; 
      forever begin
	 @coa_vi.master_cb;
	 coa_vi.master_cb.mems        <= coasia_transaction::NO_NAME;
	 seq_item_port.get_next_item( coa_tx );
	 @coa_vi.master_cb;
	 coa_vi.master_cb.mems        <= coa_tx.mems;
	 coa_vi.master_cb.lang_cer    <= coa_tx.lang_cer;
	 coa_vi.master_cb.kore_sub    <= coa_tx.kore_sub;
	 seq_item_port.item_done();
      end
   endtask: run_phase
endclass: coasia_driver 
