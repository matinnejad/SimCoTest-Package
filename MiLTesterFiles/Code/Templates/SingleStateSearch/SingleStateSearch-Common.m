diary('[MiLTester_CodeRootVal]\Temp\output.log');
try
  addpath('[MiLTester_CodeRootVal]\Functions\ObjectiveFunctions');
  addpath('[MiLTester_CodeRootVal]\Functions\OtherFunctions');
  run('SC_MiLTester_ModelSettingsScript');
  load_system('[MiLTester_SimulinkModelPathVal]');
  Fn_MiLTester_SetSimulationTime([MiLTester_SimulationTimeVal]);
  
  SearchVariablesCnt=[MiLTester_SearchVariablesCntVal];
  %Index 1 is for initial desired variable and 2 for final desired varibale 
  MinValues=zeros(SearchVariablesCnt,1);

  MaxValues=zeros(SearchVariablesCnt,1);


  MinValues(1) = [MiLTester_RegionWidthRangeStartVal];
  MaxValues(1) = [MiLTester_RegionWidthRangeStopVal];

  MinValues(2) = [MiLTester_RegionHeightRangeStartVal];
  MaxValues(2) = [MiLTester_RegionHeightRangeStopVal];
  
  NumberOfObjectives=5;
  ObjectiveFunctionValueCurrent=zeros(NumberOfObjectives,1);

  AlgorithmRounds = [MiLTester_AlgorithmRoundsVal];
  AlgorithmIterations = [MiLTester_AlgorithmIterationsVal];
  NameOfTheSelectedObjectiveFunction = '[MiLTester_SelectedObjectiveFunction]';
  switch NameOfTheSelectedObjectiveFunction
    case 'Stability'
      IndexOfTheSelectedObjectiveFunction = 1;
      %SATempratureInit=0.0220653;%DC Motor
      SATempratureInit=0.0034248;%SBPC With Error
    case 'Liveness'
      IndexOfTheSelectedObjectiveFunction = 2;
      %SATempratureInit=0.3660831;%DC Motor
      SATempratureInit=0.009626;%SBPC With Error
    case 'Smoothness'
      IndexOfTheSelectedObjectiveFunction = 3;
      %SATempratureInit=12.443589;%DC Motor
      SATempratureInit=0.0495502;%SBPC With Error
    case 'NormalizedSmoothness'
      IndexOfTheSelectedObjectiveFunction = 4;
      %SATempratureInit=0.08422266;%DC Motor
      SATempratureInit=0.1194454;%SBPC With Error
    case 'Responsiveness'
      IndexOfTheSelectedObjectiveFunction = 5;    
      %SATempratureInit=0.0520161;%DC Motor
      SATempratureInit=0.019252;%SBPC With Error
  end
 
  StartTime=rem(now,1);
  TestInputValues=zeros(AlgorithmRounds,AlgorithmIterations,SearchVariablesCnt);
  ObjectiveFunction=zeros(AlgorithmRounds,AlgorithmIterations,NumberOfObjectives);

  for algorithmRound=1:AlgorithmRounds,
    % Initialization of Search Variables    
    CurrentValues = zeros(SearchVariablesCnt,1);
    CurrentValues(1) = [MiLTester_WorstPointFromRandomExplorationInitialDesiredVal];
    CurrentValues(2) = [MiLTester_WorstPointFromRandomExplorationFinalDesiredVal];
    OldValues=CurrentValues;
    %Other Initializations
    ObjectiveFunctionValueOld=zeros(NumberOfObjectives,1);
    ObjectiveFunctionValueCurrent=zeros(NumberOfObjectives,1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SATemprature=SATempratureInit;
    SimulationTimeStep=Fn_MiLTester_GetSimulationTimeStep();
    NextLoopCntRestart=(AlgorithmIterations/2.5-AlgorithmIterations/5)*rand(1)+AlgorithmIterations/5;
    for LoopCnt=1:AlgorithmIterations,  

      TestInputValues(algorithmRound,LoopCnt,:)=CurrentValues(:);
     
      %[MiLTester_DesiredValueVar]=Fn_MiLTester_CreateDesiredValueInputSignal(CurrentValues(1),CurrentValues(2),[MiLTester_SimulationTimeVal],0.01);
      [MiLTester_DesiredValueVar]=Fn_MiLTester_CreateDesiredValueInputSignal(CurrentValues(1),CurrentValues(2),[MiLTester_SimulationTimeVal],SimulationTimeStep);
      %Do the Simulation
       diary off;
       sim('[MiLTester_SimulinkModelPathVal]');    
       diary on;
  

      %Objective Function Computation 
      %1st Parameter: Desired Value
      %2nd Parameter: Actual Values
      switch IndexOfTheSelectedObjectiveFunction
        case 1
          ObjectiveFunctionValueCurrent(1)=Fn_MiLTester_Stability_ObjectiveFunction([MiLTester_ActualValueVar].signals.values);
        case 2
          ObjectiveFunctionValueCurrent(2)=Fn_MiLTester_Liveness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values);
        case 3
          ObjectiveFunctionValueCurrent(3)=Fn_MiLTester_Smoothness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values,[MiLTester_RangeStartVal],[MiLTester_RangeStopVal]);
        case 4
          ObjectiveFunctionValueCurrent(4)=Fn_MiLTester_NormalizedSmoothness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values,[MiLTester_RangeStartVal],[MiLTester_RangeStopVal]);
        case 5
          ObjectiveFunctionValueCurrent(5)=Fn_MiLTester_Responsiveness_ObjectiveFunction([MiLTester_DesiredValueVar].signals.values,[MiLTester_ActualValueVar].signals.values,[MiLTester_RangeStartVal],[MiLTester_RangeStopVal],SimulationTimeStep);
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Store Objective Function Values
      for i=1:NumberOfObjectives,
        ObjectiveFunction(algorithmRound,LoopCnt,i)=ObjectiveFunctionValueCurrent(i);
      end

[MiLTester_ReplaceValuesCode]
      
      ObjectiveFunctionValueOld=ObjectiveFunctionValueCurrent;
      OldValues=CurrentValues;

      NewValues=CurrentValues;
[MiLTester_GenerateNewValuesCode]
      CurrentValues=NewValues;
    end
  end
  
  RegionResultsFolderPath=sprintf('%s\\%s\\%s_%d_%d','[MiLTester_CodeRootVal]\Temp\SingleStateSearch',NameOfTheSelectedObjectiveFunction,'Region',[MiLTester_RegionWidthIndexVal],[MiLTester_RegionHeightIndexVal]);
  mkdir(RegionResultsFolderPath);
  
  SingleStateSearchResults=Fn_MiLTester_GenerateSingleStateSearchResults(TestInputValues,ObjectiveFunction,AlgorithmRounds,AlgorithmIterations,IndexOfTheSelectedObjectiveFunction);
  
  SingleStateSearchResultsHeader={'AlgorihtmRound','AlgorihtmIteration','InitialDesired','FinalDesreid',NameOfTheSelectedObjectiveFunction};
  SingleStateSearchResultsHeaderStr=sprintf('%s,',SingleStateSearchResultsHeader{1:(length(SingleStateSearchResultsHeader)-1)});
  SingleStateSearchResultsHeaderStr=sprintf('%s%s\r\n',SingleStateSearchResultsHeaderStr,SingleStateSearchResultsHeader{length(SingleStateSearchResultsHeader)});
  SingleStateSearchResultsHeaderStr(end)='';
  SingleStateSearchResultsFilePath=sprintf('%s\\%s',RegionResultsFolderPath,'SingleStateSearchResults.csv');
  dlmwrite(SingleStateSearchResultsFilePath,SingleStateSearchResultsHeaderStr,'');
  dlmwrite(SingleStateSearchResultsFilePath,SingleStateSearchResults,'-append', 'delimiter', ',', 'newline', 'pc');
  
  SingleStateSearchRoundsComparison=Fn_MiLTester_GenerateSingleStateSearchRoundsComparison(ObjectiveFunction,AlgorithmRounds,AlgorithmIterations,IndexOfTheSelectedObjectiveFunction);

  SingleStateSearchRoundsComparisonHeaderStr='AlgorihtmIteration';
  for i=1:AlgorithmRounds,
    SingleStateSearchRoundsComparisonHeaderStr=sprintf('%s,%s%d',SingleStateSearchRoundsComparisonHeaderStr,'Round',i);
  end
  SingleStateSearchRoundsComparisonHeaderStr=sprintf('%s,Average\r\n',SingleStateSearchRoundsComparisonHeaderStr);
  SingleStateSearchRoundsComparisonHeaderStr(end)='';
  SingleStateSearchRoundsComparisonFilePath=sprintf('%s\\%s',RegionResultsFolderPath,'SingleStateSearchRoundsComparison.csv');
  dlmwrite(SingleStateSearchRoundsComparisonFilePath,SingleStateSearchRoundsComparisonHeaderStr,'');
  dlmwrite(SingleStateSearchRoundsComparisonFilePath,SingleStateSearchRoundsComparison,'-append', 'delimiter', ',', 'newline', 'pc');

  WorstCaseScenarioInTheRegion=Fn_MiLTester_GetWorstCaseScenarioInTheRegion(TestInputValues,ObjectiveFunction,AlgorithmRounds,AlgorithmIterations,IndexOfTheSelectedObjectiveFunction,[MiLTester_RegionWidthIndexVal],[MiLTester_RegionHeightIndexVal]);
  WorstCaseScenarioInTheRegionHeader={'IndexInitialDesired','IndexFinalDesired','InitialDesired','FinalDesreid'};
  WorstCaseScenarioInTheRegionHeaderStr=sprintf('%s,',WorstCaseScenarioInTheRegionHeader{1:(length(WorstCaseScenarioInTheRegionHeader)-1)});
  WorstCaseScenarioInTheRegionHeaderStr=sprintf('%s%s\r\n',WorstCaseScenarioInTheRegionHeaderStr,WorstCaseScenarioInTheRegionHeader{length(WorstCaseScenarioInTheRegionHeader)});
  WorstCaseScenarioInTheRegionHeaderStr(end)='';
  WorstCaseScenarioInTheRegionFilePath=sprintf('%s\\%s',RegionResultsFolderPath,'WorstCaseScenarioInTheRegion.csv');
  dlmwrite(WorstCaseScenarioInTheRegionFilePath,WorstCaseScenarioInTheRegionHeaderStr,'');
  dlmwrite(WorstCaseScenarioInTheRegionFilePath,WorstCaseScenarioInTheRegion,'-append', 'delimiter', ',', 'newline', 'pc');

  FinishTime=rem(now,1);
  display(strcat('modelRunningTime=',num2str(round((FinishTime-StartTime)*24*3600*1000))));
  display('Single-state search finished successfully with no error!');
catch exc
  display(getReport(exc));
  display('Error in random exploration!');
end
diary off;