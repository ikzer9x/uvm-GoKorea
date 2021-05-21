package coasia_pkg;
  parameter NUMMEMS = 7;
  parameter MEMWIDTH = 7;
 import uvm_pkg::*;
 `include "uvm_macros.svh" 
 `include "coasia_sequence.sv"
 `include "coasia_sequencer.sv"
 `include "coasia_driver.sv"
 `include "coasia_monitor.sv"
 `include "coasia_agent.sv"
 `include "coasia_sb_subscriber.sv"
 `include "coasia_scoreboard.sv"
 `include "coasia_env.sv"
 `include "coasia_test.sv"
endpackage
