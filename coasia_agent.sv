   //---------------------------------------------------------------------------
   // Class: coasia_agent
   //--------------------------------------------------------------------------- 
class coasia_agent extends uvm_agent;
   `uvm_component_utils( coasia_agent ) 
   uvm_analysis_port#( coasia_transaction ) coa_ap;
     
   coasia_sequencer coa_seqr;
   coasia_driver    coa_drvr;
   coasia_monitor   coa_mon; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase ); 
      coa_ap = new( .name( "coa_ap" ), .parent( this ) );
      coa_seqr = coasia_sequencer::type_id::create( "coa_seqr", this );
      coa_drvr = coasia_driver   ::type_id::create( "coa_drvr", this );
      coa_mon  = coasia_monitor  ::type_id::create( "coa_mon" , this );
   endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      coa_drvr.seq_item_port.connect( coa_seqr.seq_item_export );
      coa_mon.coa_ap.connect( coa_ap );
   endfunction: connect_phase
endclass: coasia_agent 
