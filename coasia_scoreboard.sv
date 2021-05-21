   //---------------------------------------------------------------------------
   // Class: coasia_scoreboard
   //--------------------------------------------------------------------------- 
class coasia_scoreboard extends uvm_scoreboard;
   `uvm_component_utils( coasia_scoreboard ) 
   uvm_analysis_export#( coasia_transaction ) coa_analysis_export;
//SUB//   local coasia_sb_subscriber coa_sb_sub;
   coasia_transaction coa_tx;

   uvm_tlm_analysis_fifo#( coasia_transaction ) coasia_fifo;

   function new( string name, uvm_component parent );
      super.new( name, parent );
      coa_tx = new("coa_tx");
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      coa_analysis_export = new( .name( "coa_analysis_export" ), .parent( this ) );
//SUB//      coa_sb_sub = coasia_sb_subscriber::type_id::create( .name( "coa_sb_sub" ), .parent( this ) );
      coasia_fifo = new("coasia_fifo",this);
   endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
//SUB//      coa_analysis_export.connect( coa_sb_sub.analysis_export );
      coa_analysis_export.connect( coasia_fifo.analysis_export );
   endfunction: connect_phase 

   task run();
      forever begin
        coasia_fifo.get(coa_tx);
        check_coasia_approval(coa_tx);
      end
   endtask : run

   virtual function void check_coasia_approval( coasia_transaction coa_tx );
      if ( coa_tx.kore_sub == 0 &&
	        coa_tx.approval  != coasia_transaction::UNKNOWN ) begin
	 `uvm_error( "coasia_scoreboard", 
		     { "WRONG JUDGMENT, HE DONT SUBMIT YET\n", coa_tx.sprint( ) } );
	    end else if ((coa_tx.kore_sub == 0 && coa_tx.approval  == coasia_transaction::UNKNOWN ) ||
                   (coa_tx.approval == coasia_transaction::REJECT && coa_tx.lang_cer == coasia_transaction::NONE)) begin
	 `uvm_info( "coasia_scoreboard",
		    { "WORK AT COASIA VN \n", coa_tx.sprint( ) },UVM_LOW );
      end else if (coa_tx.approval == coasia_transaction::ACCEPT &&
                   coa_tx.lang_cer != coasia_transaction::NONE) begin
	 `uvm_info( "coasia_scoreboard",
		    { "YOU WILL GO KOREAN \n", coa_tx.sprint( ) },UVM_LOW );
      end else begin 
	 `uvm_error( "coasia_scoreboard", 
		     { "PLEASE CHECK AGAIN THIS CASE\n", coa_tx.sprint( ) } );
      end 
   endfunction: check_coasia_approval
endclass: coasia_scoreboard 
