
try
  
  close_system(find_system);
  run('SC_MiLTester_ModelSettingsScript');
  orgmodelname='[MiLTester_ModelComltName]';
  orgmodelpath='[MiLTester_SimulinkModelPathVal]';
  
  %addpath(genpath('C:/Users/reza.matinnejad/Desktop/MiLTester/bin/Debug/MiLTesterFiles/Code'));
  addpath(genpath('[MiLTester_CodeRootVal]'));
  addpath(orgmodelpath);

  filesdirectory=sprintf('%s/%s-Files/',orgmodelpath,orgmodelname);
  SLTestGenerationResultsFolderPath = '[MiLTester_CodeRootVal]\Temp\SLTestGeneration\Results';
  
  [NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals]=Fn_ReadExtractInfo2(filesdirectory,'ExtractInfo.xml','Input');
  [NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals]=Fn_ReadExtractInfo2(filesdirectory,'ExtractInfo.xml','Calib');
  [NoOutputs,OutputNamesVar,OutputTypesVar,OutputMinVals,OutputMaxVals]=Fn_ReadExtractInfo2(filesdirectory,'ExtractInfo.xml','Output');

  TestSuitSize=[ODTestSuiteSize];
  TestSuiteComplexity=zeros(TestSuitSize,NoInputVars);
  TestSuiteComplexity(:,:)=1;

  load_system(orgmodelname);
  
  SimTime=Fn_MiLTester_GetSimulationTime();
  SolverType=Fn_MiLTester_GetSolverType();
  if(strcmp(SolverType,'Fixed-step'))
    SimStep=Fn_MiLTester_GetSimulationTimeStep();
  else
    SimStep=0.001;
  end
    
  NoSteps=(SimTime/SimStep);
  outputdirectory=sprintf('%s/Outputs/',filesdirectory);
  if(~exist(outputdirectory,'dir'))
    mkdir(outputdirectory)
  end
  
  %resultsdirectory=sprintf('%s/Results/',filesdirectory);
  
 
  NoSteps=(SimTime/SimStep);
  
  MaxDist=zeros(NoOutputs,1);
  for ocnt=1:NoOutputs,
    MaxDist(ocnt,1)=(sqrt(1+NoSteps)*(OutputMaxVals(ocnt)-OutputMinVals(ocnt)));
  end

  TestSuiteFBCov=zeros(NoOutputs);
  
  TestGenerationTimeOut=[TestGenerationTime];
  MaxDist=zeros(NoOutputs,1);
  for ocnt=1:NoOutputs,
    MaxDist(ocnt,1)=(sqrt(1+NoSteps)*(OutputMaxVals(ocnt)-OutputMinVals(ocnt)));
  end
  TweakSigmaExploration=0.5;
  TweakSigmaExploitation=0.05;
  %main loop on the model mutants 

  TweakSigmaFB=zeros(NoOutputs,1);

  for ocnt=1:NoOutputs,
    TestSuiteComplexityAllFB(ocnt,:,:)=TestSuiteComplexity(:,:);
  end
  
  testsuite=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFB(1,:,:),size(TestSuiteComplexityAllFB,2),size(TestSuiteComplexityAllFB,3)),TestSuitSize,SimTime,SimStep);
  testsuite=Fn_CompleteARandomTestSuiteWithCalibs(testsuite,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      
  MaxTestSuiteODFB=zeros(NoOutputs,1);
  inittscovvalFB=zeros(NoOutputs,1);

  for ocnt=1:NoOutputs,
    TweakSigmaFB(ocnt)=TweakSigmaExploration;
    cursolutionFB{ocnt}=testsuite;
    bestsolutionFB{ocnt}=testsuite;
    cursolutionStab{ocnt}=testsuite;
    cursolutionDisc{ocnt}=testsuite;
  end

  %Test Generation
  tic;
  LoopCnt=1;
  while(toc<TestGenerationTimeOut)
    for ocnt=1:NoOutputs,
      testsuite=cursolutionFB{ocnt};
      if(strcmp(SolverType,'Fixed-step'))
        [TestSuiteDist,TestSuiteOutput,tscov]=Fn_ExecuteATestSuite(false,orgmodelname,orgmodelname,testsuite,true,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,MaxDist,ocnt);
      else
        [TestSuiteOutput,OutputTime]=Fn_ExecuteATestSuite_EMB(orgmodelname,testsuite,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,ocnt);
      end
      if(LoopCnt==1)
        %decisioninittscov=decisioninfo(tscov, strrep(orgmodelname,'.mdl',''));
        %inittscovvalFB(ocnt)=decisioninittscov(1)/decisioninittscov(2);
        %acctscovFB{ocnt}=tscov;
        %acctscovLoopFB{ocnt}{LoopCnt}=tscov;
      else
        %acctscovFB{ocnt}=acctscovFB{ocnt}+tscov;
        %acctscovLoopFB{ocnt}{LoopCnt}= acctscovFB{ocnt};
      end
      TestSuiteFeatures=Fn_ComputeTestSuiteFeatures(TestSuiteOutput);
      TestSuiteOD=Fn_ComputeTestSuiteOD('features',TestSuiteFeatures);
      %TestSuiteStab=Fn_MiLTester_Stability_ObjectiveFunction_FSE(TestSuiteOutput);
      %TestSuiteDisc=Fn_MiLTester_Disc_ObjectiveFunction_FSE(TestSuiteOutput);
      %Replace Strategy
       if(TestSuiteOD>=MaxTestSuiteODFB(ocnt))
         MaxTestSuiteODFB(ocnt)=TestSuiteOD;
         bestsolutionFB{ocnt}=cursolutionFB{ocnt};
         TestSuiteFB{ocnt}=cursolutionFB{ocnt};
         %decisioninittscov=decisioninfo(tscov, strrep(orgmodelname,'.mdl',''));
         %TestSuiteFBCov(ocnt)=decisioninittscov(1)/decisioninittscov(2);
       end
    end
       

    testsuite=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFB(1,:,:),size(TestSuiteComplexityAllFB,2),size(TestSuiteComplexityAllFB,3)),TestSuitSize,SimTime,SimStep);
    testsuite=Fn_CompleteARandomTestSuiteWithCalibs(testsuite,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      
    %TweakSigmaFB=Fn_AdaptTweakParameter(orgmodelname,NoOutputs,ones(NoOutputs,1),acctscovFB,inittscovvalFB,TweakSigmaFB,TweakSigmaExploration,TweakSigmaExploitation);
    %TestSuiteComplexityAllFB(:,:,:)=Fn_AdaptComplexity(orgmodelname,NoOutputs,ones(NoOutputs,1),acctscovLoopFB,LoopCnt,5,squeeze(TestSuiteComplexityAllFB(:,:,:)));
    %for ocnt=1:NoOutputs,  
    %  testsuite=Fn_TweakATestSuite(bestsolutionFB{ocnt},TweakSigmaFB(ocnt),NoInputVars,InputTypesVar,InputMinVals,InputMaxVals,squeeze(TestSuiteComplexityAllFB(ocnt,:,:)),TestSuitSize,SimTime,SimStep);
    %  testsuite=Fn_TweakATestSuiteCalibs(testsuite,TweakSigmaFB(ocnt),NoCalibs,CalTypesVar,CalMinVals,CalMaxVals);
      cursolutionFB{ocnt}=testsuite;
    %end
    LoopCnt=LoopCnt+1;
  end

  for ocnt=1:NoOutputs,
    testsuite=bestsolutionFB{ocnt};
    thisOutputName=OutputNamesVar{ocnt};
    Fn_ConvertTestSuites2(testsuite,sprintf('%s//%s',SLTestGenerationResultsFolderPath,'diversity'),thisOutputName);
    %save(sprintf('%s/%s/testsuite.mat',outputdirectory,OutputNamesVar(ocnt)),'testsuite');
  end
  close_system(orgmodelname);
  
  diary('[MiLTester_CodeRootVal]/Temp/output.log');
  display('SLGeenration finished successfully with no error!');
  diary off;
  exit;
  
catch exc
  display(getReport(exc));
  display('Error in random exploration!');
end