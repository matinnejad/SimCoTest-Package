diary('[MiLTester_CodeRootVal]\Temp\output.log');
try
  addpath('[MiLTester_CodeRootVal]\Functions\ObjectiveFunctions');
  addpath('[MiLTester_CodeRootVal]\Functions\OtherFunctions');
  run('SC_MiLTester_ModelSettingsScript');
  load_system('[MiLTester_SimulinkModelPathVal]');
  Fn_MiLTester_SetSimulationTime([MiLTester_SimulationTimeVal]);
  
  MiLTester_CalibrationVariablesNamesVar={[MiLTester_CalibrationVariablesNamesVar]};
  SearchVariablesCnt = 2 + length(MiLTester_CalibrationVariablesNamesVar);

  %Index 1 is for initial desired variable and 2 for final desired varibale 
  MinValues=zeros(SearchVariablesCnt,1);
  MaxValues=zeros(SearchVariablesCnt,1);
  
  MinValues(1)=[MiLTester_RangeStartVal];
  MaxValues(1)=[MiLTester_RangeStopVal];
  
  MinValues(2)=[MiLTester_RangeStartVal];
  MaxValues(2)=[MiLTester_RangeStopVal];
  
  if(SearchVariablesCnt>2)
    MinValues(3:length(MinValues))=[[MiLTester_CalibrationVariablesMinimumsVal]];
    MaxValues(3:length(MaxValues))=[[MiLTester_CalibrationVariablesMaximumsVal]];
  end

  CurrentValues=zeros(SearchVariablesCnt,1);

  for i=1:SearchVariablesCnt,
    CurrentValues(i)=MinValues(i)+(MaxValues(i)-MinValues(i))*rand(1);
  end

  NumberOfObjectives=5;
  ObjectiveFunctionValueCurrent=zeros(NumberOfObjectives);
  
  MaxAlgorithmIterations=[MiLTester_MaxAlgorithmIterationsVal];
  TestInputValues=zeros(MaxAlgorithmIterations,SearchVariablesCnt);
  ObjectiveFunction=zeros(MaxAlgorithmIterations,NumberOfObjectives);


  StartTime=rem(now,1);
  SimulationTimeStep=Fn_MiLTester_GetSimulationTimeStep();
  for LoopCnt=1:MaxAlgorithmIterations,
    if(SearchVariablesCnt==2)
      if(LoopCnt>[MiLTester_MinAlgorithmIterationsVal])
        if(Fn_At_Least_X_Points_In_Each_Region(TestInputValues,LoopCnt-1,[MiLTester_NumberOfPointsInEachRegionVal],[MiLTester_HeatMapDiagramDivisionFactorVal],[MiLTester_RangeStartVal],[MiLTester_RangeStopVal]))
          break;
        end
      end
    end
    TestInputValues(LoopCnt,:)=CurrentValues(:);
    
    %[MiLTester_DesiredValueVar]=Fn_MiLTester_CreateDesiredValueInputSignal(CurrentValues(1),CurrentValues(2),[MiLTester_SimulationTimeVal],0.01);
    [MiLTester_DesiredValueVar]=Fn_MiLTester_CreateDesiredValueInputSignal(CurrentValues(1),CurrentValues(2),[MiLTester_SimulationTimeVal],SimulationTimeStep);
    
    for i=1:length(MiLTester_CalibrationVariablesNamesVar),
      eval(sprintf('%s=%f;',MiLTester_CalibrationVariablesNamesVar{i},CurrentValues(i+2)));
    end

    
    diary off;

    sim('[MiLTester_SimulinkModelPathVal]');
    
    diary on;

    %Objective Function Computation 
    %1st Parameter: Desired Value
    %2nd Parameter: Actual Values
    ObjectiveFunctionValueCurrent(1)=Fn_MiLTester_Stability_ObjectiveFunction([MiLTester_ActualValueVar].signals.values);
    ObjectiveFunctionValueCurrent(2)=Fn_MiLTester_Liveness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values);
    ObjectiveFunctionValueCurrent(3)=Fn_MiLTester_Smoothness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values,[MiLTester_RangeStartVal],[MiLTester_RangeStopVal]);
    ObjectiveFunctionValueCurrent(4)=Fn_MiLTester_NormalizedSmoothness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values,[MiLTester_RangeStartVal],[MiLTester_RangeStopVal]);
    ObjectiveFunctionValueCurrent(5)=Fn_MiLTester_Responsiveness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values,[MiLTester_RangeStartVal],[MiLTester_RangeStopVal],SimulationTimeStep);

    %Store Objective Function Values
    for i=1:NumberOfObjectives,
      ObjectiveFunction(LoopCnt,i)=ObjectiveFunctionValueCurrent(i);
    end
    [MiLTester_GenerateNewValuesCode]
  end
  if(LoopCnt==MaxAlgorithmIterations)
    LoopCnt=MaxAlgorithmIterations+1;
  end  
  
  TestInputValues=TestInputValues(1:LoopCnt-1,:);
  ObjectiveFunction=ObjectiveFunction(1:LoopCnt-1,:);

  RandomExplorationResults=cat(2,TestInputValues,ObjectiveFunction);

  RandomExplorationResultsFolderPath = '[MiLTester_CodeRootVal]\Temp\RandomExploration';
  mkdir(RandomExplorationResultsFolderPath);
  
  RandomExplorationResultsHeader={'InitialDesired','FinalDesired'};
  RandomExplorationResultsHeader=cat(2,RandomExplorationResultsHeader,MiLTester_CalibrationVariablesNamesVar);
  RandomExplorationResultsHeader=cat(2,RandomExplorationResultsHeader,{'Stability','Liveness','Smoothness','NormalizedSmoothness','Responsiveness'});
  RandomExplorationResultsHeaderStr=sprintf('%s,',RandomExplorationResultsHeader{1:(length(RandomExplorationResultsHeader)-1)});
  RandomExplorationResultsHeaderStr=sprintf('%s%s\r\n',RandomExplorationResultsHeaderStr,RandomExplorationResultsHeader{length(RandomExplorationResultsHeader)});
  RandomExplorationResultsHeaderStr(end)='';
  RandomExplorationResultsFilePath=sprintf('%s\\%s',RandomExplorationResultsFolderPath,'RandomExplorationResults.csv');
  dlmwrite(RandomExplorationResultsFilePath,RandomExplorationResultsHeaderStr,'');
  dlmwrite(RandomExplorationResultsFilePath, RandomExplorationResults,'-append', 'delimiter', ',', 'newline', 'pc');
  
  if(SearchVariablesCnt==2)
    HeatMapDiagrams=Fn_MiLTester_GenerateHeatMapDiagrams(TestInputValues,ObjectiveFunction,NumberOfObjectives,LoopCnt-1,[MiLTester_HeatMapDiagramDivisionFactorVal],[MiLTester_RangeStartVal],[MiLTester_RangeStopVal]);
  
    HeatMapDiagramsHeader={'IndexInitialDesired','IndexFinalDesired','InitialDesired','FinalDesired', 'Stability','Liveness','Smoothness','NormalizedSmoothness','Responsiveness'};
    HeatMapDiagramsHeaderStr=sprintf('%s,',HeatMapDiagramsHeader{1:(length(HeatMapDiagramsHeader)-1)});
    HeatMapDiagramsHeaderStr=sprintf('%s%s\r\n',HeatMapDiagramsHeaderStr,HeatMapDiagramsHeader{length(HeatMapDiagramsHeader)});
    HeatMapDiagramsHeaderStr(end)='';
    HeatMapDiagramsFilePath=sprintf('%s\\%s',RandomExplorationResultsFolderPath,'HeatMapDiagrams.csv');
    dlmwrite(HeatMapDiagramsFilePath,HeatMapDiagramsHeaderStr,'');
    dlmwrite(HeatMapDiagramsFilePath,HeatMapDiagrams,'-append', 'delimiter', ',', 'newline', 'pc');

    HeatMapRegions=Fn_MiLTester_GenerateHeatMapRegions(TestInputValues,ObjectiveFunction,NumberOfObjectives,LoopCnt-1,[MiLTester_HeatMapDiagramDivisionFactorVal],[MiLTester_RangeStartVal],[MiLTester_RangeStopVal]);
    HeatMapRegionsHeader={'IndexInitialDesired','IndexFinalDesired','InitialDesiredRangeStart','InitialDesiredRangeEnd','FinalDesiredRangeStart','FinalDesiredRangeEnd', 'Stability','StabilityWorstPointX','StabilityWorstPointY','Liveness','LivenessWorstPointX','LivenessWorstPointY','Smoothness','SmoothnessWorstPointX','SmoothnessWorstPointY','NormalizedSmoothness','NormalizedSmoothnessWorstPointX','NormalizedSmoothnessWorstPointY','Responsiveness','ResponsivenessWorstPointX','ResponsivenessWorstPointY'};
    HeatMapRegionsHeaderStr=sprintf('%s,',HeatMapRegionsHeader{1:(length(HeatMapRegionsHeader)-1)});
    HeatMapRegionsHeaderStr=sprintf('%s%s\r\n',HeatMapRegionsHeaderStr,HeatMapRegionsHeader{length(HeatMapRegionsHeader)});
    HeatMapRegionsHeaderStr(end)='';
    HeatMapRegionsFilePath=sprintf('%s\\%s',RandomExplorationResultsFolderPath,'HeatMapRegions.csv');
    dlmwrite(HeatMapRegionsFilePath,HeatMapRegionsHeaderStr,'');
    dlmwrite(HeatMapRegionsFilePath,HeatMapRegions,'-append', 'delimiter', ',', 'newline', 'pc');
  end  
  FinishTime=rem(now,1);
  display(strcat('modelRunningTime=',num2str(round((FinishTime-StartTime)*24*3600*1000))));
  display('Random exploration finished successfully with no error!');

catch exc
  display(getReport(exc));
  display('Error in random exploration!');
end
diary off;