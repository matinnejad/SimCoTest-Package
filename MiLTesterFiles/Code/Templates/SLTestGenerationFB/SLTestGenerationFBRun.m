
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

  TestSuitSizeStab=[StabTestSuiteSize];
  TestSuitSizeDisc=[DiscTestSuiteSize];
  TestSuitSizeInf=[InfTestSuiteSize];
  TestSuiteComplexityStab=zeros(TestSuitSizeStab,NoInputVars);
  TestSuiteComplexityStab(:,:)=1;
  TestSuiteComplexityDisc=zeros(TestSuitSizeDisc,NoInputVars);
  TestSuiteComplexityDisc(:,:)=1;
  TestSuiteComplexityInf=zeros(TestSuitSizeInf,NoInputVars);
  TestSuiteComplexityInf(:,:)=1;

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
    TestSuiteComplexityAllFBStab(ocnt,:,:)=TestSuiteComplexityStab(:,:);
    TestSuiteComplexityAllFBDisc(ocnt,:,:)=TestSuiteComplexityDisc(:,:);
    TestSuiteComplexityAllFBInf(ocnt,:,:)=TestSuiteComplexityInf(:,:);
  end
  
  testsuiteStab=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFBStab(1,:,:),size(TestSuiteComplexityAllFBStab,2),size(TestSuiteComplexityAllFBStab,3)),TestSuitSizeStab,SimTime,SimStep);
  testsuiteStab=Fn_CompleteARandomTestSuiteWithCalibs(testsuiteStab,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      
  testsuiteDisc=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFBDisc(1,:,:),size(TestSuiteComplexityAllFBDisc,2),size(TestSuiteComplexityAllFBDisc,3)),TestSuitSizeDisc,SimTime,SimStep);
  testsuiteDisc=Fn_CompleteARandomTestSuiteWithCalibs(testsuiteDisc,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      
  testsuiteInf=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFBInf(1,:,:),size(TestSuiteComplexityAllFBInf,2),size(TestSuiteComplexityAllFBInf,3)),TestSuitSizeInf,SimTime,SimStep);
  testsuiteInf=Fn_CompleteARandomTestSuiteWithCalibs(testsuiteInf,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      
  MaxTestSuiteODFB=zeros(NoOutputs,1);
  inittscovvalFB=zeros(NoOutputs,1);
  MaxTestSuiteStab=zeros(NoOutputs,1);
  MaxTestSuiteStab2=zeros(NoOutputs,1);
  MinTestSuiteStab3=inf(NoOutputs,1);
  MaxTestSuiteDisc=zeros(NoOutputs,1);
  MaxTestSuiteInf=zeros(NoOutputs,1);
  MaxTestSuiteRand=zeros(NoOutputs,1);
  for ocnt=1:NoOutputs,
    TweakSigmaFB(ocnt)=TweakSigmaExploration;
    cursolutionFBStab{ocnt}=testsuiteStab;
    bestsolutionFBStab{ocnt}=testsuiteStab;
    cursolutionFBDisc{ocnt}=testsuiteDisc;
    bestsolutionFBDisc{ocnt}=testsuiteDisc;
    cursolutionFBInf{ocnt}=testsuiteInf;
    bestsolutionFBInf{ocnt}=testsuiteInf;
  end

  %Test Generation
  tic;
  LoopCnt=1;
  while(toc<TestGenerationTimeOut)
    for ocnt=1:NoOutputs,
      testsuiteStab=cursolutionFBStab{ocnt};
      testsuiteDisc=cursolutionFBDisc{ocnt};
      testsuiteInf=cursolutionFBInf{ocnt};
      if(strcmp(SolverType,'Fixed-step'))
	       [TestSuiteDistStab,TestSuiteOutputStab,tscovStab]=Fn_ExecuteATestSuite(false,orgmodelname,orgmodelname,testsuiteStab,true,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,MaxDist,ocnt);
	       [TestSuiteDistDisc,TestSuiteOutputDisc,tscovDisc]=Fn_ExecuteATestSuite(false,orgmodelname,orgmodelname,testsuiteDisc,true,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,MaxDist,ocnt);
	       [TestSuiteDistInf,TestSuiteOutputInf,tscovInf]=Fn_ExecuteATestSuite(false,orgmodelname,orgmodelname,testsuiteInf,true,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,MaxDist,ocnt);
      else
         [TestSuiteOutputStab,OutputTimeStab]=Fn_ExecuteATestSuite_EMB(orgmodelname,testsuiteStab,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,ocnt);
         [TestSuiteOutputDisc,OutputTimeDisc]=Fn_ExecuteATestSuite_EMB(orgmodelname,testsuiteDisc,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,ocnt);
         [TestSuiteOutputInf,OutputTimeInf]=Fn_ExecuteATestSuite_EMB(orgmodelname,testsuiteInf,InputTypesVar,NoSteps,NoOutputs,SimTime,SimStep,ocnt);
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
      %TestSuiteFeatures=Fn_ComputeTestSuiteFeatures(TestSuiteOutput);
      %TestSuiteOD=Fn_ComputeTestSuiteOD('features',TestSuiteFeatures);
      TestSuiteStab=Fn_MiLTester_Stability_ObjectiveFunction_FSE(TestSuiteOutputStab);
      %TestSuiteStab2=Fn_MiLTester_Stability_ObjectiveFunction_FSE_2(TestSuiteOutputStab);
      %TestSuiteStab3=Fn_MiLTester_Stability_ObjectiveFunction_FSE_3(TestSuiteOutput);
      TestSuiteDisc=Fn_MiLTester_Disc_ObjectiveFunction_FSE(TestSuiteOutputDisc);
      TestSuiteInf=Fn_MiLTester_Infinity_ObjectiveFunction_FSE(TestSuiteOutputInf,OutputTimeInf);
      TestSuiteRand=rand();
      %Replace Strategy
%       if(TestSuiteOD>=MaxTestSuiteODFB(ocnt))
%         MaxTestSuiteODFB(ocnt)=TestSuiteOD;
%         bestsolutionFB{ocnt}=cursolutionFB{ocnt};
%         TestSuiteFB{ocnt}=cursolutionFB{ocnt};
%         decisioninittscov=decisioninfo(tscov, strrep(orgmodelname,'.mdl',''));
%         TestSuiteFBCov(ocnt)=decisioninittscov(1)/decisioninittscov(2);
%       end
      if(TestSuiteStab>=MaxTestSuiteStab(ocnt))
        MaxTestSuiteStab(ocnt)=TestSuiteStab;
        bestsolutionStab{ocnt}=cursolutionFBStab{ocnt};
      end
%       if(TestSuiteStab2>=MaxTestSuiteStab2(ocnt))
%         MaxTestSuiteStab2(ocnt)=TestSuiteStab2;
%         bestsolutionStab2{ocnt}=cursolutionFBStab2{ocnt};
%       end
%       if(TestSuiteStab3<=MinTestSuiteStab3(ocnt))
%         MinTestSuiteStab3(ocnt)=TestSuiteStab3;
%         bestsolutionStab3{ocnt}=cursolutionFBStab3{ocnt};
%       end
      if(TestSuiteDisc>=MaxTestSuiteDisc(ocnt))
        MaxTestSuiteDisc(ocnt)=TestSuiteDisc;
        bestsolutionDisc{ocnt}=cursolutionFBDisc{ocnt};
      end
      if(TestSuiteInf>=MaxTestSuiteInf(ocnt))
        MaxTestSuiteInf(ocnt)=TestSuiteInf;
        bestsolutionInf{ocnt}=cursolutionFBInf{ocnt};
      end
%       if(TestSuiteRand>=MaxTestSuiteRand(ocnt))
%         MaxTestSuiteRand(ocnt)=TestSuiteRand;
%         bestsolutionRand{ocnt}=cursolutionFB{ocnt};
%       end
    end

    testsuiteStab=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFBStab(1,:,:),size(TestSuiteComplexityAllFBStab,2),size(TestSuiteComplexityAllFBStab,3)),TestSuitSizeStab,SimTime,SimStep);
    testsuiteStab=Fn_CompleteARandomTestSuiteWithCalibs(testsuiteStab,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      
    testsuiteDisc=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFBDisc(1,:,:),size(TestSuiteComplexityAllFBDisc,2),size(TestSuiteComplexityAllFBDisc,3)),TestSuitSizeDisc,SimTime,SimStep);
    testsuiteDisc=Fn_CompleteARandomTestSuiteWithCalibs(testsuiteDisc,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      
    testsuiteInf=Fn_GenerateARandomTestSuite(NoInputVars,InputNamesVar,InputTypesVar,InputMinVals,InputMaxVals,reshape(TestSuiteComplexityAllFBInf(1,:,:),size(TestSuiteComplexityAllFBInf,2),size(TestSuiteComplexityAllFBInf,3)),TestSuitSizeInf,SimTime,SimStep);
    testsuiteInf=Fn_CompleteARandomTestSuiteWithCalibs(testsuiteInf,NoCalibs,CalNamesVar,CalTypesVar,CalMinVals,CalMaxVals);      

    %TweakSigmaFB=Fn_AdaptTweakParameter(orgmodelname,NoOutputs,ones(NoOutputs,1),acctscovFB,inittscovvalFB,TweakSigmaFB,TweakSigmaExploration,TweakSigmaExploitation);
    %TestSuiteComplexityAllFB(:,:,:)=Fn_AdaptComplexity(orgmodelname,NoOutputs,ones(NoOutputs,1),acctscovLoopFB,LoopCnt,5,squeeze(TestSuiteComplexityAllFB(:,:,:)));
    %for ocnt=1:NoOutputs,  
    %  testsuite=Fn_TweakATestSuite(bestsolutionFB{ocnt},TweakSigmaFB(ocnt),NoInputVars,InputTypesVar,InputMinVals,InputMaxVals,squeeze(TestSuiteComplexityAllFB(ocnt,:,:)),TestSuitSize,SimTime,SimStep);
    %  testsuite=Fn_TweakATestSuiteCalibs(testsuite,TweakSigmaFB(ocnt),NoCalibs,CalTypesVar,CalMinVals,CalMaxVals);
    %  cursolutionFB{ocnt}=testsuite;
    cursolutionFBStab{ocnt}=testsuiteStab;
    cursolutionFBDisc{ocnt}=testsuiteDisc;
    cursolutionFBInf{ocnt}=testsuiteInf;
    %end
    LoopCnt=LoopCnt+1;
  end

  for ocnt=1:NoOutputs,
    testsuite=bestsolutionStab{ocnt};
    thisOutputName=OutputNamesVar{ocnt};
    Fn_ConvertTestSuites2(testsuiteStab,sprintf('%s//%s',SLTestGenerationResultsFolderPath,'stability'),thisOutputName);
    
%     testsuite=bestsolutionStab2{ocnt};
%     thisOutputName=OutputNamesVar{ocnt};
%     Fn_ConvertTestSuites2(testsuite,sprintf('%s//%s',SLTestGenerationResultsFolderPath,'stability2'),thisOutputName);
% 
%     testsuite=bestsolutionStab3{ocnt};
%     thisOutputName=OutputNamesVar{ocnt};
%     Fn_ConvertTestSuites2(testsuite,sprintf('%s//%s',SLTestGenerationResultsFolderPath,'stability3'),thisOutputName);

    testsuite=bestsolutionDisc{ocnt};
    thisOutputName=OutputNamesVar{ocnt};
    Fn_ConvertTestSuites2(testsuiteDisc,sprintf('%s//%s',SLTestGenerationResultsFolderPath,'discontinuity'),thisOutputName);
    
    testsuite=bestsolutionInf{ocnt};
    thisOutputName=OutputNamesVar{ocnt};
    Fn_ConvertTestSuites2(testsuiteInf,sprintf('%s//%s',SLTestGenerationResultsFolderPath,'infinity'),thisOutputName);
    
%     testsuite=bestsolutionRand{ocnt};
%     thisOutputName=OutputNamesVar{ocnt};
%     Fn_ConvertTestSuites2(testsuite,sprintf('%s//%s',SLTestGenerationResultsFolderPath,'rand'),thisOutputName);


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