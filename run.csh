#!/bin/csh
xrun -uvmhome CDNS-1.2 top.sv +UVM_TESTNAME=coasia_test -64bit +UVM_VERBOSITY=UVM_MEDIUM | tee coasia.log
#xrun -uvmhome CDNS-1.2 coasia.sv +UVM_TESTNAME=coasia_test -64bit +UVM_VERBOSITY=UVM_MEDIUM | tee coasia.log
#xrun -uvmhome CDNS-1.2 bk_coa.sv +UVM_TESTNAME=coasia_test -64bit +UVM_VERBOSITY=UVM_MEDIUM | tee coasia.log
