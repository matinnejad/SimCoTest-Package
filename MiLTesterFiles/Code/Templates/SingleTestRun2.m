
diary('[MiLTester_CodeRootVal]\Temp\output.log');
try
  addpath('[MiLTester_CodeRootVal]\Functions\ObjectiveFunctions');
  addpath('[MiLTester_CodeRootVal]\Functions\OtherFunctions');
  run('SC_MiLTester_ModelSettingsScript');
  load_system('[MiLTester_SimulinkModelPathVal]');
  Fn_MiLTester_SetSimulationTime([MiLTester_SimulationTimeVal]); 
  startTime = rem(now,1);

  MiLTester_InputVariablesNamesVar={[MiLTester_InputVariablesNamesVar]};
  MiLTester_InputVariablesInitialValuesVal={[MiLTester_InputVariablesInitialValuesVal]};
  MiLTester_InputVariablesFinalValuesVal={[MiLTester_InputVariablesFinalValuesVal]};
  MiLTester_InputVariablesStepTimeVal={[MiLTester_InputVariablesStepTimesVal]};
  for i=1:length(MiLTester_InputVariablesNamesVar),
    eval(sprintf('%s=Fn_MiLTester_CreateCustomStepSignal([%f,%f],[%f,%f],%f,%f);',MiLTester_InputVariablesNamesVar{i},MiLTester_InputVariablesInitialValuesVal{i},MiLTester_InputVariablesFinalValuesVal{i},MiLTester_InputVariablesStepTimeVal{i},[MiLTester_SimulationTimeVal],[MiLTester_SimulationTimeVal],Fn_MiLTester_GetSimulationTimeStep()));
  end

  MiLTester_CalibrationVariablesNamesVar={[MiLTester_CalibrationVariablesNamesVar]};
  MiLTester_CalibrationVariablesValuesVal={[MiLTester_CalibrationVariablesValuesVal]};
  for i=1:length(MiLTester_CalibrationVariablesNamesVar),
    eval(sprintf('%s=%f;',MiLTester_CalibrationVariablesNamesVar{i},MiLTester_CalibrationVariablesValuesVal{i}));
  end
  sim('[MiLTester_SimulinkModelPathVal]');
  finishTime = rem(now,1);
  %display([MiLTester_ActualValueVar]);
  display(strcat('modelRunningTime=',num2str(round((finishTime-startTime)*24*3600*1000))));
  display('Model test run finished successfully with no error!');
  display('But you should check and confirm correctness of the simulation results.');
  plot([MiLTester_OutputVariableNameVar].time,[MiLTester_OutputVariableNameVar].signals.values);
catch exc
  display(getReport(exc));
  display('Error in model test run!');
end
diary off;