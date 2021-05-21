   //---------------------------------------------------------------------------
   // Class: coasia_monitor
   //--------------------------------------------------------------------------- 
class coasia_monitor extends uvm_monitor;

   `uvm_component_utils( coasia_monitor ) 
   uvm_analysis_port#( coasia_transaction ) coa_ap; 
   virtual coasia_if coa_vi; 
	 coasia_transaction coa_tx;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      void'( uvm_resource_db#( virtual coasia_if )::read_by_name
      ( .scope( "ifs" ), .name( "coasia_if" ), .val( coa_vi ) ) );
      coa_ap = new( .name( "coa_ap" ), .parent( this ) );
   endfunction: build_phase 

   task run_phase( uvm_phase phase );
      coa_tx = coasia_transaction::type_id::create(.name("coa_tx"), .contxt(get_full_name()));
      forever begin
	 @coa_vi.slave_cb;
	 if ( coa_vi.slave_cb.mems != coasia_transaction::NO_NAME ) begin
	    coa_tx.mems          = coasia_transaction::mems_e'( coa_vi.slave_cb.mems );
	    coa_tx.lang_cer      = coasia_transaction::lang_cer_e' ( coa_vi.slave_cb.lang_cer  );
	    coa_tx.kore_sub      = coa_vi.slave_cb.kore_sub;
	    @coa_vi.master_cb;
	    coa_tx.approval      = coasia_transaction::approval_e'( coa_vi.master_cb.approval );
      //Send coa_tx to ap
	    coa_ap.write( coa_tx );
	 end
      end
   endtask: run_phase

endclass: coasia_monitor 
