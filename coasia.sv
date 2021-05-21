//==============================================================================
//============================================================================== 
`include "uvm_macros.svh" 
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
//------------------------------------------------------------------------------
// Package: coasia_pkg
//------------------------------------------------------------------------------ 
package coasia_pkg;
   import uvm_pkg::*; 

   //------------------------------------------------------------------------------
   //PARAMETER
   //------------------------------------------------------------------------------
   parameter NUMMEMS = 7;
   parameter MEMWIDTH = 7;
   //---------------------------------------------------------------------------
   // Class: coasia_transaction
   //--------------------------------------------------------------------------- 
class coasia_transaction extends uvm_sequence_item;
   typedef enum bit[MEMWIDTH:0] { NO_NAME, TRUNG, TON, THINH, THAOMAI, TUAN, HA, TOAN } mems_e;
   typedef enum bit[1:0] { NONE, TOEIC, IELTS } lang_cer_e;
   typedef enum bit[1:0] { UNKNOWN, ACCEPT, REJECT } approval_e; 
   rand mems_e mems;
   rand lang_cer_e  lang_cer;
   rand bit         kore_sub;
   approval_e       approval; 
   constraint mems_lang_cer_con {
      mems != NO_NAME;
      mems == TRUNG      -> lang_cer != IELTS;
      mems == TON -> lang_cer == IELTS;
   } 
   function new( string name = "" );
      super.new( name );
   endfunction: new 
   `uvm_object_utils_begin( coasia_transaction )
      `uvm_field_enum( mems_e,       mems,     UVM_ALL_ON )
      `uvm_field_enum( lang_cer_e,  lang_cer,  UVM_ALL_ON )
      `uvm_field_int ( kore_sub,               UVM_ALL_ON )
      `uvm_field_enum( approval_e,  approval,  UVM_ALL_ON )
   `uvm_object_utils_end
endclass: coasia_transaction 

   //---------------------------------------------------------------------------
   // Class: kore_sub_coasia_transaction
   //---------------------------------------------------------------------------
class kore_sub_coasia_transaction extends coasia_transaction;
   `uvm_object_utils( kore_sub_coasia_transaction ) 
   constraint kore_sub_con {
      kore_sub == 1;
   } 
   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: kore_sub_coasia_transaction 

   //---------------------------------------------------------------------------
   // Class: one_coasia_sequence
   //---------------------------------------------------------------------------
class one_coasia_sequence extends uvm_sequence#( coasia_transaction );

   `uvm_object_utils( one_coasia_sequence ) 
   function new( string name = "" );
      super.new( name );
   endfunction: new 

   task body();
      coasia_transaction coa_tx;
      coa_tx = coasia_transaction::type_id::create( .name( "coa_tx" ) );
      start_item( coa_tx );

`ifndef CL_USE_MODELSIM
      assert( coa_tx.randomize() );
`endif
      finish_item( coa_tx );
   endtask: body
endclass: one_coasia_sequence 

   //---------------------------------------------------------------------------
   // Class: all_mem_coasia_sequence
   //   Sequence of transactions.
   //--------------------------------------------------------------------------- 
class all_mem_coasia_sequence extends uvm_sequence#( coasia_transaction );

   rand int unsigned num_coasias; // knob 
   constraint num_coasias_con { num_coasias inside { [2:4] }; } 
   function new( string name = "" );
      super.new( name );
   endfunction: new 

   task body();
      coasia_transaction           coa_tx;
      coasia_transaction::mems_e coa_mems; 
      coa_tx = coasia_transaction::type_id::create( .name( "coa_tx" ) );
`ifndef CL_USE_MODELSIM
      assert( coa_tx.randomize() );
`endif

      coa_mems = coa_tx.mems;
   
  for ( int i = 0; i < NUMMEMS; i++) begin
	    coa_tx = coasia_transaction::type_id::create( .name( "coa_tx" ) );
	    start_item( coa_tx );
	    assert( coa_tx.randomize() with { coa_tx.mems == i+1; } );
	    finish_item( coa_tx );
  end

   endtask: body 
   `uvm_object_utils_begin( all_mem_coasia_sequence )
      `uvm_field_int( num_coasias, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: all_mem_coasia_sequence 

   //---------------------------------------------------------------------------
   // Class: random_mems_coasia_sequence
   //   Sequence of sequences.
   //--------------------------------------------------------------------------- 
class random_mems_coasia_sequence extends uvm_sequence#( coasia_transaction );   
   rand int unsigned num_coasia_mems; // knob 
   //constraint num_coasia_memss_con { num_coasia_mems inside { [4:5] }; } 
   constraint num_coasia_memss_con { num_coasia_mems == 4 ; } 
   function new( string name = "" );
      super.new( name );
   endfunction: new 
   task body();
      one_coasia_sequence coa_seq;
      repeat ( num_coasia_mems ) begin
	 coa_seq = one_coasia_sequence::type_id::create( .name( "coa_seq" ) );

`ifndef CL_USE_MODELSIM
	 assert( coa_seq.randomize() );
`endif

	 coa_seq.start( m_sequencer );
      end
   endtask: body 
   `uvm_object_utils_begin( random_mems_coasia_sequence )
      `uvm_field_int( num_coasia_mems, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: random_mems_coasia_sequence 
   //---------------------------------------------------------------------------
   // Typedef: coasia_sequencer
   //--------------------------------------------------------------------------- 
   typedef uvm_sequencer#(coasia_transaction) coasia_sequencer; 
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

   //---------------------------------------------------------------------------
   // Class: coasia_monitor
   //--------------------------------------------------------------------------- 
class coasia_monitor extends uvm_monitor;

   `uvm_component_utils( coasia_monitor ) 
   uvm_analysis_port#( coasia_transaction ) coa_ap; 
   virtual coasia_if coa_vi; 

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
      forever begin
	 coasia_transaction coa_tx;
	 @coa_vi.slave_cb;
	 if ( coa_vi.slave_cb.mems != coasia_transaction::NO_NAME ) begin
	    coa_tx = coasia_transaction::type_id::create( .name( "coa_tx" ) );
	    coa_tx.mems     = coasia_transaction::mems_e'( coa_vi.slave_cb.mems );
	    coa_tx.lang_cer      = coasia_transaction::lang_cer_e' ( coa_vi.slave_cb.lang_cer  );
	    coa_tx.kore_sub = coa_vi.slave_cb.kore_sub;
	    @coa_vi.master_cb;
	    coa_tx.approval = coasia_transaction::approval_e'( coa_vi.master_cb.approval );
	    coa_ap.write( coa_tx );
	 end
      end
   endtask: run_phase

endclass: coasia_monitor 

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
      coa_seqr = coasia_sequencer::type_id::create( .name( "coa_seqr" ), .parent( this ) );
      coa_drvr = coasia_driver   ::type_id::create( .name( "coa_drvr" ), .parent( this ) );
      coa_mon  = coasia_monitor  ::type_id::create( .name( "coa_mon"  ), .parent( this ) );
   endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      coa_drvr.seq_item_port.connect( coa_seqr.seq_item_export );
      coa_mon.coa_ap.connect( coa_ap );
   endfunction: connect_phase
endclass: coasia_agent 

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

   //---------------------------------------------------------------------------
   // Class: coasia_scoreboard
   //--------------------------------------------------------------------------- 
class coasia_scoreboard extends uvm_scoreboard;
   `uvm_component_utils( coasia_scoreboard ) 
   uvm_analysis_export#( coasia_transaction ) coa_analysis_export;
   local coasia_sb_subscriber coa_sb_sub;
//   coasia_transaction coa_tx;

//   uvm_tlm_analysis_fifo#( coasia_transaction ) coasia_fifo;

   function new( string name, uvm_component parent );
      super.new( name, parent );
//      coa_tx = new("coa_tx");
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      coa_analysis_export = new( .name( "coa_analysis_export" ), .parent( this ) );
      coa_sb_sub = coasia_sb_subscriber::type_id::create( .name( "coa_sb_sub" ), .parent( this ) );
//      coasia_fifo = new("coasia_fifo",this);
   endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      coa_analysis_export.connect( coa_sb_sub.analysis_export );
//      coa_analysis_export.connect( coasia_fifo.analysis_export );
   endfunction: connect_phase 

//   task run();
//      forever begin
//        coasia_fifo.get(coa_tx);
//        check_coasia_approval(coa_tx);
//      end
//   endtask : run

   virtual function void check_coasia_approval( coasia_transaction coa_tx );
      if ( coa_tx.kore_sub == 0 &&
	        coa_tx.approval  != coasia_transaction::UNKNOWN ) begin
	 `uvm_error( "coasia_scoreboard", 
		     { "WRONG JUDGMENT, HE DONT SUBMIT YET\n", coa_tx.sprint( ) } );
      end else if (coa_tx.approval == coasia_transaction::ACCEPT &&
                   coa_tx.lang_cer != coasia_transaction::NONE) begin
	 `uvm_info( "coasia_scoreboard",
		    { "YOU WILL GO KOREAN \n", coa_tx.sprint( ) },UVM_LOW );
      end else if (coa_tx.approval == coasia_transaction::REJECT &&
                   coa_tx.lang_cer == coasia_transaction::NONE) begin
	 `uvm_info( "coasia_scoreboard",
		    { "WORK AT COASIA VN \n", coa_tx.sprint( ) },UVM_LOW );
      end else begin 
	 `uvm_error( "coasia_scoreboard", 
		     { "PLEASE CHECK AGAIN THIS CASE\n", coa_tx.sprint( ) } );
      end 
   endfunction: check_coasia_approval
endclass: coasia_scoreboard 

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

   //---------------------------------------------------------------------------
   // Class: coasia_test
   //--------------------------------------------------------------------------- 
class coasia_test extends uvm_test;
   `uvm_component_utils( coasia_test ) 
   coasia_env coa_env; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      begin

//SUB==1//	 coasia_transaction::type_id::set_type_override
//SUB==1//	   ( kore_sub_coasia_transaction::get_type() ); 

	 coa_env = coasia_env::type_id::create( .name( "coa_env" ), .parent( this ) );
      end
   endfunction: build_phase 

   task run_phase( uvm_phase phase );
      random_mems_coasia_sequence coa_seq; 
      phase.raise_objection( .obj( this ) );
      coa_seq = random_mems_coasia_sequence::type_id::create( .name( "coa_seq" ) );

`ifndef CL_USE_MODELSIM
      assert( coa_seq.randomize() );
`endif

      `uvm_info( "coasia_test", { "\n", coa_seq.sprint() }, UVM_LOW )

      coa_seq.start( coa_env.coa_agent.coa_seqr );
      #10ns ;
      phase.drop_objection( .obj( this ) );
   endtask: run_phase

endclass: coasia_test
endpackage: coasia_pkg

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
	 //coa_slave_if.approval <= coasia_transaction::ACCEPT;
	 coa_slave_if.approval <= coasia_transaction::REJECT;
      end else begin
	 coa_slave_if.approval <= coasia_transaction::ACCEPT;
	 //coa_slave_if.approval <= coasia_transaction::REJECT;
      end
   end
endmodule: coasia_approval

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
//==============================================================================
//END
//==============================================================================
