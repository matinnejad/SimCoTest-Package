

diary('C:\Users\reza.matinnejad\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Code\Temp\output.log');

try

  addpath(genpath('C:\Users\reza.matinnejad\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Code\Functions'));

  wsstr=who; 

  if(length(wsstr)<=0)

	  run('SC_MiLTester_ModelSettingsScript');

  end

  cd \;

  open_system('C:\Users\reza.matinnejad\Desktop\EMB\EMB.slx');

  SimTime=Fn_MiLTester_GetSimulationTime();

  SolverType=Fn_MiLTester_GetSolverType();

  if(strcmp(SolverType,'Fixed-step'))

    SimStep=Fn_MiLTester_GetSimulationTimeStep();

  else

    SimStep=0.001;

  end 

  Fn_ExecuteATestCaseFromXML2('EMB','C:\Users\reza.matinnejad\Desktop\EMB\EMB-Files\','C:\Users\reza.matinnejad\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Data\WorkSpaceName\Results\infinity\x',1,1,SimTime,SimStep);

 catch exc

  display(getReport(exc));

  display('Error in model test run!');

end

diary off;

