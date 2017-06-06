
diary('[MiLTester_CodeRootVal]\Temp\output.log');
try
  addpath(genpath('[MiLTester_CodeRootVal]\Functions'));
  wsstr=who; 
  if(length(wsstr)<=0)
	  run('SC_MiLTester_ModelSettingsScript');
  end
  cd \;
  open_system('[MiLTester_SimulinkModelPathVal]');
  SimTime=Fn_MiLTester_GetSimulationTime();
  SolverType=Fn_MiLTester_GetSolverType();
  if(strcmp(SolverType,'Fixed-step'))
    SimStep=Fn_MiLTester_GetSimulationTimeStep();
  else
    SimStep=0.001;
  end 
  Fn_ExecuteATestCaseFromXML2('[MiLTester_ModelComltName]','[MiLTester_FilesDirectory]','[MiLTester_TestSuiteFilepath]',[MiLTester_DsrdTCNo],[MiLTester_DsrdOutNo],SimTime,SimStep);
 catch exc
  display(getReport(exc));
  display('Error in model test run!');
end
diary off;