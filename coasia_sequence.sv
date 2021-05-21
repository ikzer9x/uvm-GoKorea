class coasia_transaction extends uvm_sequence_item;
   typedef enum bit[MEMWIDTH:0] { NO_NAME, TRUNG, TON, THINH, THAOMAI, TUAN, TOAN, HA } mems_e;
   typedef enum bit[1:0] { NONE, TOEIC, IELTS } lang_cer_e;
   typedef enum bit[1:0] { UNKNOWN, ACCEPT, REJECT } approval_e; 
   rand mems_e mems;
   rand lang_cer_e  lang_cer;
   rand bit         kore_sub;
   approval_e       approval; 
   //constraint mems_lang_cer_con {
   //   mems != NO_NAME;
   //   mems == TRUNG      -> lang_cer != IELTS;
   //   mems == TON        -> lang_cer == IELTS;
   //} 
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
      assert( coa_tx.randomize() );
      //`uvm_info("coa_sequence", coa_tx.sprint(), UVM_LOW);
      finish_item( coa_tx );
   endtask: body
endclass: one_coasia_sequence 

   //---------------------------------------------------------------------------
   // Class: all_mem_coasia_sequence
   //   Sequence of transactions.
   //--------------------------------------------------------------------------- 
class all_mem_coasia_sequence extends uvm_sequence#( coasia_transaction );

   `uvm_object_utils( all_mem_coasia_sequence )
   function new( string name = "" );
      super.new( name );
   endfunction: new 

   task body();
      coasia_transaction           coa_tx;
      coasia_transaction::mems_e coa_mems; 

      coa_mems = coa_tx.mems;
   
  for ( int i = 0; i < NUMMEMS; i++) begin
	    coa_tx = coasia_transaction::type_id::create( .name( "coa_tx" ) );
	    start_item( coa_tx );
	    assert( coa_tx.randomize() with { coa_tx.mems == i+1; } );
      //`uvm_info("coa_sequence", coa_tx.sprint(), UVM_LOW);
	    finish_item( coa_tx );
  end

   endtask: body 
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
	 assert( coa_seq.randomize() );
	 coa_seq.start( m_sequencer );
      end
   endtask: body 
   `uvm_object_utils_begin( random_mems_coasia_sequence )
      `uvm_field_int( num_coasia_mems, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: random_mems_coasia_sequence 
