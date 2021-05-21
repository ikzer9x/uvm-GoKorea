   //---------------------------------------------------------------------------
   // Class: coasia_sb_subscriber
   //--------------------------------------------------------------------------- 
typedef class coasia_scoreboard;
class coasia_sb_subscriber extends uvm_subscriber#( coasia_transaction );
   `uvm_component_utils( coasia_sb_subscriber ) 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void write( coasia_transaction t );
      coasia_scoreboard coa_sb;
      $cast( coa_sb, m_parent );
      coa_sb.check_coasia_approval( t );
   endfunction: write
endclass: coasia_sb_subscriber 
