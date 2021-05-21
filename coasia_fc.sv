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
   //NONEED//modport master_mp( input clk, approval, output mems, lang_cer, kore_sub );
   modport slave_mp ( input clk, mems, lang_cer, kore_sub, output approval );
   modport master_sync_mp( clocking master_cb );
   modport slave_sync_mp ( clocking slave_cb  );
endinterface: coasia_if 
//------------------------------------------------------------------------------
// Package: coasia_pkg
//------------------------------------------------------------------------------ 
package coasia_pkg;
   import uvm_pkg::*; 
   //---------------------------------------------------------------------------
   // Class: coasia_configuration
   //--------------------------------------------------------------------------- 
class coasia_configuration extends uvm_object;
   `uvm_object_utils( coasia_configuration ) 
   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: coasia_configuration 

   //---------------------------------------------------------------------------
   // Class: coasia_transaction
   //--------------------------------------------------------------------------- 
class coasia_transaction extends uvm_sequence_item;
   typedef enum bit[2:0] { NO_mems, APPLE, BLUEBERRY, BUBBLE_GUM, CHOCOLATE } mems_e;
   typedef enum bit[1:0] { RED, GREEN, BLUE } lang_cer_e;
   typedef enum bit[1:0] { UNKNOWN, YUMMY, YUCKY } approval_e; 
   rand mems_e mems;
   rand lang_cer_e  lang_cer;
   rand bit      kore_sub;
   approval_e       approval; 
   constraint mems_lang_cer_con {
      mems != NO_mems;
      mems == APPLE     -> lang_cer != BLUE;
      mems == BLUEBERRY -> lang_cer == BLUE;
   } 
   function new( string name = "" );
      super.new( name );
   endfunction: new 
   `uvm_object_utils_begin( coasia_transaction )
      `uvm_field_enum( mems_e, mems, UVM_ALL_ON )
      `uvm_field_enum( lang_cer_e,  lang_cer,  UVM_ALL_ON )
      `uvm_field_int ( kore_sub,       UVM_ALL_ON )
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
      coasia_transaction jb_tx;
      jb_tx = coasia_transaction::type_id::create( .name( "jb_tx" ) );
      start_item( jb_tx );

`ifndef CL_USE_MODELSIM
      assert( jb_tx.randomize() );
`endif
      finish_item( jb_tx );
   endtask: body
endclass: one_coasia_sequence 

   //---------------------------------------------------------------------------
   // Class: same_memsed_coasias_sequence
   //   Sequence of transactions.
   //--------------------------------------------------------------------------- 
class same_memsed_coasias_sequence extends uvm_sequence#( coasia_transaction );

   rand int unsigned num_coasias; // knob 
   constraint num_coasias_con { num_coasias inside { [2:4] }; } 
   function new( string name = "" );
      super.new( name );
   endfunction: new 

   task body();
      coasia_transaction           jb_tx;
      coasia_transaction::mems_e jb_mems; 
      jb_tx = coasia_transaction::type_id::create( .name( "jb_tx" ) );
`ifndef CL_USE_MODELSIM
      assert( jb_tx.randomize() );
`endif
      jb_mems = jb_tx.mems; 
      repeat ( num_coasias ) begin
	 jb_tx = coasia_transaction::type_id::create( .name( "jb_tx" ) );
	 start_item( jb_tx );
`ifndef CL_USE_MODELSIM
	 assert( jb_tx.randomize() with { jb_tx.mems == jb_mems; } );
`endif
	 finish_item( jb_tx );
      end
   endtask: body 
   `uvm_object_utils_begin( same_memsed_coasias_sequence )
      `uvm_field_int( num_coasias, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: same_memsed_coasias_sequence 

   //---------------------------------------------------------------------------
   // Class: gift_boxed_coasias_sequence
   //   Sequence of sequences.
   //--------------------------------------------------------------------------- 
class gift_boxed_coasias_sequence extends uvm_sequence#( coasia_transaction );    rand int unsigned num_coasia_memss; // knob 
   constraint num_coasia_memss_con { num_coasia_memss inside { [2:3] }; } 
   function new( string name = "" );
      super.new( name );
   endfunction: new 
   task body();
      same_memsed_coasias_sequence jb_seq;
      repeat ( num_coasia_memss ) begin
	 jb_seq = same_memsed_coasias_sequence::type_id::create( .name( "jb_seq" ) );

`ifndef CL_USE_MODELSIM
	 assert( jb_seq.randomize() );
`endif

	 jb_seq.start( m_sequencer );
      end
   endtask: body 
   `uvm_object_utils_begin( gift_boxed_coasias_sequence )
      `uvm_field_int( num_coasia_memss, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: gift_boxed_coasias_sequence 
   //---------------------------------------------------------------------------
   // Typedef: coasia_sequencer
   //--------------------------------------------------------------------------- 
   typedef uvm_sequencer#(coasia_transaction) coasia_sequencer; 
   //---------------------------------------------------------------------------
   // Class: coasia_driver
   //--------------------------------------------------------------------------- 
class coasia_driver extends uvm_driver#( coasia_transaction );

   `uvm_component_utils( coasia_driver ) 
   virtual coasia_if jb_vi; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      void'( uvm_resource_db#( virtual coasia_if )::read_by_name
	     ( .scope( "ifs" ), .name( "coasia_if" ), .val( jb_vi ) ) );
   endfunction: build_phase 

   task run_phase( uvm_phase phase );
      coasia_transaction jb_tx; 
      forever begin
	 @jb_vi.master_cb;
	 jb_vi.master_cb.mems <= coasia_transaction::NO_mems;
	 seq_item_port.get_next_item( jb_tx );
	 @jb_vi.master_cb;
	 jb_vi.master_cb.mems     <= jb_tx.mems;
	 jb_vi.master_cb.lang_cer      <= jb_tx.lang_cer;
	 jb_vi.master_cb.kore_sub <= jb_tx.kore_sub;
	 seq_item_port.item_done();
      end
   endtask: run_phase
endclass: coasia_driver 

   //---------------------------------------------------------------------------
   // Class: coasia_monitor
   //--------------------------------------------------------------------------- 
class coasia_monitor extends uvm_monitor;

   `uvm_component_utils( coasia_monitor ) 
   uvm_analysis_port#( coasia_transaction ) jb_ap; 
   virtual coasia_if jb_vi; 

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      void'( uvm_resource_db#( virtual coasia_if )::read_by_name
	     ( .scope( "ifs" ), .name( "coasia_if" ), .val( jb_vi ) ) );
      jb_ap = new( .name( "jb_ap" ), .parent( this ) );
   endfunction: build_phase 

   task run_phase( uvm_phase phase );
      forever begin
	 coasia_transaction jb_tx;
	 @jb_vi.slave_cb;
	 if ( jb_vi.slave_cb.mems != coasia_transaction::NO_mems ) begin
	    jb_tx = coasia_transaction::type_id::create( .name( "jb_tx" ) );
	    jb_tx.mems     = coasia_transaction::mems_e'( jb_vi.slave_cb.mems );
	    jb_tx.lang_cer      = coasia_transaction::lang_cer_e' ( jb_vi.slave_cb.lang_cer  );
	    jb_tx.kore_sub = jb_vi.slave_cb.kore_sub;
	    @jb_vi.master_cb;
	    jb_tx.approval = coasia_transaction::approval_e'( jb_vi.master_cb.approval );
	    jb_ap.write( jb_tx );
	 end
      end
   endtask: run_phase

endclass: coasia_monitor 

   //---------------------------------------------------------------------------
   // Class: coasia_agent
   //--------------------------------------------------------------------------- 
class coasia_agent extends uvm_agent;
   `uvm_component_utils( coasia_agent ) 
   uvm_analysis_port#( coasia_transaction ) jb_ap;
     
   coasia_sequencer jb_seqr;
   coasia_driver    jb_drvr;
   coasia_monitor   jb_mon; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase ); 
      jb_ap = new( .name( "jb_ap" ), .parent( this ) );
      jb_seqr = coasia_sequencer::type_id::create( .name( "jb_seqr" ), .parent( this ) );
      jb_drvr = coasia_driver   ::type_id::create( .name( "jb_drvr" ), .parent( this ) );
      jb_mon  = coasia_monitor  ::type_id::create( .name( "jb_mon"  ), .parent( this ) );
   endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_drvr.seq_item_port.connect( jb_seqr.seq_item_export );
      jb_mon.jb_ap.connect( jb_ap );
   endfunction: connect_phase
endclass: coasia_agent 

   //---------------------------------------------------------------------------
   // Class: coasia_fc_subscriber
   //--------------------------------------------------------------------------- 
class coasia_fc_subscriber extends uvm_subscriber#( coasia_transaction );

   `uvm_component_utils( coasia_fc_subscriber ) 
   coasia_transaction jb_tx; 

`ifndef CL_USE_MODELSIM
   covergroup coasia_cg;
      mems_cp:     coverpoint jb_tx.mems;
      lang_cer_cp:      coverpoint jb_tx.lang_cer;
      kore_sub_cp: coverpoint jb_tx.kore_sub;
      cross mems_cp, lang_cer_cp, kore_sub_cp;
   endgroup: coasia_cg
`endif 

   function new( string name, uvm_component parent );
      super.new( name, parent );
`ifndef CL_USE_MODELSIM
      coasia_cg = new;
`endif
   endfunction: new 

   function void write( coasia_transaction t );
      jb_tx = t;
`ifndef CL_USE_MODELSIM
      coasia_cg.sample();
`endif
   endfunction: write
endclass: coasia_fc_subscriber 

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
      coasia_scoreboard jb_sb;
      $cast( jb_sb, m_parent );
      jb_sb.check_coasia_approval( t );
   endfunction: write
endclass: coasia_sb_subscriber 

   //---------------------------------------------------------------------------
   // Class: coasia_scoreboard
   //--------------------------------------------------------------------------- 
class coasia_scoreboard extends uvm_scoreboard;
   `uvm_component_utils( coasia_scoreboard ) 
   uvm_analysis_export#( coasia_transaction ) jb_analysis_export;
   local coasia_sb_subscriber jb_sb_sub;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_analysis_export = new( .name( "jb_analysis_export" ), .parent( this ) );
      jb_sb_sub = coasia_sb_subscriber::type_id::create( .name( "jb_sb_sub" ), .parent( this ) );
   endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_analysis_export.connect( jb_sb_sub.analysis_export );
   endfunction: connect_phase 

   virtual function void check_coasia_approval( coasia_transaction jb_tx );
      uvm_table_printer p = new;
     //ori// if ( jb_tx.mems == coasia_transaction::CHOCOLATE && jb_tx.sour &&
	   //ori//jb_tx.approval  == coasia_transaction::YUMMY ) begin
      if (jb_tx.approval  == coasia_transaction::YUMMY ) begin
	 `uvm_error( "coasia_scoreboard", 
		     { "You lost sense of approval!\n", jb_tx.sprint( p ) } );
      end else begin
	 `uvm_info( "coasia_scoreboard",
		    { "You have a good sense of approval.\n", jb_tx.sprint( p ) },
		    UVM_LOW );
      end
   endfunction: check_coasia_approval
endclass: coasia_scoreboard 

   //---------------------------------------------------------------------------
   // Class: coasia_env
   //--------------------------------------------------------------------------- 
class coasia_env extends uvm_env;

   `uvm_component_utils( coasia_env ) 
   coasia_agent         jb_agent;
   coasia_fc_subscriber jb_fc_sub;
   coasia_scoreboard    jb_sb; 

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_agent  = coasia_agent        ::type_id::create( .name( "jb_agent"  ), .parent( this ) );
      jb_fc_sub = coasia_fc_subscriber::type_id::create( .name( "jb_fc_sub" ), .parent( this ) );
      jb_sb     = coasia_scoreboard   ::type_id::create( .name( "jb_sb"     ), .parent( this ) );
    endfunction: build_phase 

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_agent.jb_ap.connect( jb_fc_sub.analysis_export );
      jb_agent.jb_ap.connect( jb_sb.jb_analysis_export );
   endfunction: connect_phase

endclass: coasia_env 

   //---------------------------------------------------------------------------
   // Class: coasia_test
   //--------------------------------------------------------------------------- 
class coasia_test extends uvm_test;
   `uvm_component_utils( coasia_test ) 
   coasia_env jb_env; 
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new 

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      begin
//why//	 coasia_configuration jb_cfg; 
//why//	 jb_cfg = new;

//why//`ifndef CL_USE_MODELSIM
//why//	 assert( jb_cfg.randomize() );
//why//`endif

//why//	 uvm_config_db#( coasia_configuration )::set
//why//	   ( .cntxt( this ), .inst_name( "*" ), .field_name( "config" ), .value( jb_cfg ) );

	 coasia_transaction::type_id::set_type_override
	   ( kore_sub_coasia_transaction::get_type() ); 

	 jb_env = coasia_env::type_id::create( .name( "jb_env" ), .parent( this ) );
      end
   endfunction: build_phase 

   task run_phase( uvm_phase phase );
      gift_boxed_coasias_sequence jb_seq; 
      phase.raise_objection( .obj( this ) );
      jb_seq = gift_boxed_coasias_sequence::type_id::create( .name( "jb_seq" ) );

`ifndef CL_USE_MODELSIM
      assert( jb_seq.randomize() );
`endif

      `uvm_info( "coasia_test", { "\n", jb_seq.sprint() }, UVM_LOW )

      jb_seq.start( jb_env.jb_agent.jb_seqr );
      #10ns ;
      phase.drop_objection( .obj( this ) );
   endtask: run_phase

endclass: coasia_test
endpackage: coasia_pkg

   //---------------------------------------------------------------------------
   // Module: coasia_approvalr
   //   This is the DUT.
   //---------------------------------------------------------------------------

module coasia_approvalr( coasia_if.slave_mp jb_slave_if );
   import coasia_pkg::*;

   always @ ( posedge jb_slave_if.clk ) begin
      if ( jb_slave_if.mems == coasia_transaction::CHOCOLATE) begin
	 jb_slave_if.approval <= coasia_transaction::YUCKY;
      end else begin
	 jb_slave_if.approval <= coasia_transaction::YUMMY;
      end
   end
endmodule: coasia_approvalr

   //---------------------------------------------------------------------------
   // Module: top
   //--------------------------------------------------------------------------- 
   module top;
   import uvm_pkg::*;

   reg clk;
   coasia_if     jb_slave_if( clk );
   coasia_approvalr jb_approvalr( jb_slave_if ); // DUT

   initial begin
      clk = 0;
      #5ns ;
      forever #5ns clk = ! clk;
   end

   initial begin
      uvm_resource_db#( virtual coasia_if )::set
	( .scope( "ifs" ), .name( "coasia_if" ), .val( jb_slave_if ) );
      run_test();
   end
endmodule: top 
//==============================================================================
// Copyright (c) 2011-2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================
