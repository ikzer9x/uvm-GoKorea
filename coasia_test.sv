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

//SUB//	 coasia_transaction::type_id::set_type_override
//SUB//	   ( kore_sub_coasia_transaction::get_type() ); 

	 coa_env = coasia_env::type_id::create( .name( "coa_env" ), .parent( this ) );
      end
   endfunction: build_phase 

   task run_phase( uvm_phase phase );
      //ONE//
      //one_coasia_sequence         coa_seq; 
      //phase.raise_objection( .obj( this ) );
      //coa_seq = one_coasia_sequence::type_id::create( .name( "coa_seq" ) );
      //ALL//
      //all_mem_coasia_sequence         coa_seq; 
      //phase.raise_objection( .obj( this ) );
      //coa_seq = all_mem_coasia_sequence::type_id::create( .name( "coa_seq" ) );
      //RANDOME//
      random_mems_coasia_sequence coa_seq; 
      phase.raise_objection( .obj( this ) );
      coa_seq = random_mems_coasia_sequence::type_id::create( .name( "coa_seq" ) );

      assert( coa_seq.randomize() );
      `uvm_info( "coasia_test", { "\n", coa_seq.sprint() }, UVM_LOW )
      coa_seq.start( coa_env.coa_agent.coa_seqr );

      #100ns ;
      phase.drop_objection( .obj( this ) );
   endtask: run_phase

endclass: coasia_test
