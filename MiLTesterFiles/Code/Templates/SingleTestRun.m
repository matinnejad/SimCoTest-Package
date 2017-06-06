
diary('[MiLTester_CodeRootVal]\Temp\output.log');
try
  addpath('[MiLTester_CodeRootVal]\Functions\ObjectiveFunctions');
  addpath('[MiLTester_CodeRootVal]\Functions\OtherFunctions');
  run('SC_MiLTester_ModelSettingsScript');
  load_system('[MiLTester_SimulinkModelPathVal]');
  Fn_MiLTester_SetSimulationTime([MiLTester_SimulationTimeVal]); 
  startTime = rem(now,1);
  %[MiLTester_DesiredValueVar]=Fn_MiLTester_CreateDesiredValueInputSignal([MiLTester_InitialDesiredVal],[MiLTester_FinalDesiredVal],[MiLTester_SimulationTimeVal],0.01);
  [MiLTester_DesiredValueVar]=Fn_MiLTester_CreateDesiredValueInputSignal([MiLTester_InitialDesiredVal],[MiLTester_FinalDesiredVal],[MiLTester_SimulationTimeVal],Fn_MiLTester_GetSimulationTimeStep());
  MiLTester_CalibrationVariablesNamesVar={[MiLTester_CalibrationVariablesNamesVar]};
  MiLTester_CalibrationVariablesValuesVal={[MiLTester_CalibrationVariablesValuesVal]};
  for i=1:length(MiLTester_CalibrationVariablesNamesVar),
    eval(sprintf('%s=%f;',MiLTester_CalibrationVariablesNamesVar{i},MiLTester_CalibrationVariablesValuesVal{i}));
  end
  sim('[MiLTester_SimulinkModelPathVal]');
  finishTime = rem(now,1);
  display([MiLTester_ActualValueVar]);
  display(strcat('modelRunningTime=',num2str(round((finishTime-startTime)*24*3600*1000))));
  display('Model test run finished successfully with no error!');
  display('But you should check and confirm correctness of the simulation results.');
  plot([MiLTester_DesiredValueVar].time,[MiLTester_DesiredValueVar].signals.values,[MiLTester_DesiredValueVar].time,[MiLTester_ActualValueVar].signals.values);
catch exc
  display(getReport(exc));
  display('Error in model test run!');
end
diary off;