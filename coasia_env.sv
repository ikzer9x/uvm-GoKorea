   //---------------------------------------------------------------------------
   // Class: coasia_env
   //--------------------------------------------------------------------------- 
class coasia_env extends uvm_env;

   `uvm_component_utils( coasia_env ) 
   coasia_agent         coa_agent;
   coasia_scoreboard    coa_sb; 

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      coa_agent  = coasia_agent        ::type_id::create( .name( "coa_agent"  ), .parent( this ) );
      coa_sb     = coasia_scoreboard   ::type_id::create( .name( "coa_sb"     ), .parent( this ) );
    endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      coa_agent.coa_ap.connect( coa_sb.coa_analysis_export );
   endfunction: connect_phase

endclass: coasia_env 
