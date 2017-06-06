diary('D:\Desktop\MiLTesterFiles\Code\Temp-SCPC-SLSF\output.log');
try
  addpath(genpath('D:\Desktop\MiLTesterFiles\Code\Functions'));
  %addpath('D:\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Code\Functions\ObjectiveFunctions');
  %addpath('D:\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Code\Functions\OtherFunctions');
  %addpath('D:\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Code\Functions\OtherFunctions2');
  %run('SC_MiLTester_ModelSettingsScript');
  %end
  %close_system(find_system); 

  %orgmodelname='etc_oil_pres_diag_autocode';
  %orgmodelname='etc_oil_pres_duty_cycle_autocode';
  orgmodelname='etc_oil_pres_pmp_cntl_autocode';
  %orgmodelname='etc_oil_pres_pmp_diag_autocode';

  orgmodelpath='D:\projfiles\simulink\models';

  addpath(orgmodelpath);

  load_system(sprintf('%s%s',orgmodelname,'.mdl'));

  filesdirectory=sprintf('%s\\%s-Files\\',orgmodelpath,orgmodelname);
  if(~exist(filesdirectory,'dir'))
    mkdir(filesdirectory)
  end



  %writeconstnames=0;
  %constnamespath=sprintf('%s\\%s-Files\\constnames.txt',orgmodelpath,orgmodelname);
  %if(~exist(constnamespath,'file'))
  %  fconstnames = fopen(constnamespath,'wt');
  %  writeconstnames=1;
  %end

  infoNode = com.mathworks.xml.XMLUtils.createDocument('root_inputs');
  infoRoot = infoNode.getDocumentElement;
  infospath=sprintf('%s\\%s-Files\\ExtractInfo.xml',orgmodelpath,orgmodelname);

  SimTime=Fn_MiLTester_GetSimulationTime();
  
  
  simInfo=infoNode.createElement('SimInfo');

  nextInfo=infoNode.createElement('SimTime');
  nextInfoText=infoNode.createTextNode(num2str(SimTime));
  nextInfo.appendChild(nextInfoText);
  simInfo.appendChild(nextInfo);
  
  infoRoot.appendChild(simInfo); 
  

  %Simulink blocks and lines manipulation

  objhandles=find_system(orgmodelname,'FindAll','on');
  objcnt=0;
  clear configNames;
  cnfgcnt=0;
  while(objcnt<length(objhandles))   

    objcnt=objcnt+1;

    objhndl=objhandles(objcnt);

    objecttype=get_param(objhndl,'Type');  

    switch(objecttype)

      case 'block'     

        blckname=get_param(objhndl,'Name');

        blckpar=get_param(objhndl,'Parent');

        blcktype=get_param(objhndl,'BlockType');

        switch(blcktype)

          case 'Constant'

            if(find(ismember(fieldnames(get_param(objhndl,'ObjectParameters')),'Value')))

              value=str2num(get_param(objhndl,'Value'));

              if(isempty(value))                    

                constName=get_param(objhndl,'Value');
                
                if(exist('configNames','var')&&any(ismember(configNames,constName)))
                  continue;
                end
                cnfgcnt=cnfgcnt+1;
                configNames{cnfgcnt}=constName;
                
                %if(constName(1)=='K')

                  DataTypeStr=eval(sprintf('%s.DataType',constName));
                  if(~strcmp(DataTypeStr,'boolean'))
                    DataTypeDes=eval(sprintf('%s.Description',DataTypeStr));
                  end              
                  Path=sprintf('%s/%s',blckpar,blckname);

                  %calibration

                  if(strcmp(DataTypeStr,'T_BOOLEAN') || strcmp(DataTypeStr,'boolean'))

                    if(constName(2)~='t')

                      defVal=eval(sprintf('%s.Value',constName));

                    else

                      defVal=0;

                    end                 

                    nextCalib=infoNode.createElement('Calib');
                    
                    
                    nextName=infoNode.createElement('Name');
                    nextNameText=infoNode.createTextNode(constName);
                    nextName.appendChild(nextNameText);
                    nextCalib.appendChild(nextName);

                    nextDTName=infoNode.createElement('DataTypeName');
                    nextDTNameText=infoNode.createTextNode('TbBOOLEAN');
                    nextDTName.appendChild(nextDTNameText);
                    nextCalib.appendChild(nextDTName);

                    nextPath=infoNode.createElement('Path');
                    nextPathText=infoNode.createTextNode(Path);
                    nextPath.appendChild(nextPathText);
                    nextCalib.appendChild(nextPath);

                    %nextDefValue=infoNode.createElement('DefValue');
                    %nextDefValueText=infoNode.createTextNode(num2str(defVal));
                    %nextDefValue.appendChild(nextDefValueText);
                    %nextCalib.appendChild(nextDefValue); 

                    infoRoot.appendChild(nextCalib); 
                    
                  elseif(strfind(DataTypeDes,'enum'))
                     
                                        
                    MinVal=eval(sprintf('%s.Min',constName));
                    
                    MaxVal=eval(sprintf('%s.Max',constName));
                    
                    nextCalib=infoNode.createElement('Calib');
                    
                    nextName=infoNode.createElement('Name');
                    nextNameText=infoNode.createTextNode(constName);
                    nextName.appendChild(nextNameText);
                    nextCalib.appendChild(nextName);

                    nextDTName=infoNode.createElement('DataTypeName');
                    nextDTNameText=infoNode.createTextNode('enum');
                    nextDTName.appendChild(nextDTNameText);
                    nextCalib.appendChild(nextDTName);
                    

  
                    nextMinVal=infoNode.createElement('MinVal');
                    nextMinValText=infoNode.createTextNode(num2str(MinVal));
                    nextMinVal.appendChild(nextMinValText);
                    nextCalib.appendChild(nextMinVal);

                    nextMaxVal=infoNode.createElement('MaxVal');
                    nextMaxValText=infoNode.createTextNode(num2str(MaxVal));
                    nextMaxVal.appendChild(nextMaxValText);
                    nextCalib.appendChild(nextMaxVal);
                    

                    nextPath=infoNode.createElement('Path');
                    nextPathText=infoNode.createTextNode(Path);
                    nextPath.appendChild(nextPathText);
                    nextCalib.appendChild(nextPath);

                    infoRoot.appendChild(nextCalib); 
                    

                  else
                    


                    if(constName(2)~='t')

                      defVal=eval(sprintf('%s.Value',constName));

                    else

                      defVal=0;

                    end 
                    eval(sprintf('%s',constName));
                    eval(sprintf('%s.Dimensions',constName));
                    
                    
                    MinVal=eval(sprintf('%s.Min',constName));
                    
                    MaxVal=eval(sprintf('%s.Max',constName));

                    isSigned=eval(sprintf('%s.Signedness',DataTypeStr));

                    if(strcmp(isSigned,'Unsigned'))
                      isSigned=0;
                    else
                      isSigned=1;
                    end
                    wordLength=eval(sprintf('%s.WordLength',DataTypeStr));
                    
                    DataTypeMode=eval(sprintf('%s.DataTypeMode',DataTypeStr));
                    if(strfind(DataTypeMode,'slope'))
                      dtslope=eval(sprintf('%s.Slope',DataTypeStr));
                      dtbias=eval(sprintf('%s.Bias',DataTypeStr));
                      [TypeMin,TypeMax]=Fn_GetMinMaxFix_SlopeMode(isSigned,wordLength,dtslope,dtbias);
                    else
                      fractionLength=eval(sprintf('%s.FractionLength',DataTypeStr));
                      [TypeMin,TypeMax]=Fn_getminmaxfix(isSigned,wordLength,fractionLength);
                    end

                    fractionLength=eval(sprintf('%s.FractionLength',DataTypeStr));

                    [TypeMin,TypeMax]=Fn_getminmaxfix(isSigned,wordLength,fractionLength);

                    %TypeMax=ceil(TypeMax);

                    nextCalib=infoNode.createElement('Calib');

                    nextName=infoNode.createElement('Name');
                    nextNameText=infoNode.createTextNode(constName);
                    nextName.appendChild(nextNameText);
                    nextCalib.appendChild(nextName);

                    nextDTName=infoNode.createElement('DataTypeName');
                    nextDTNameText=infoNode.createTextNode(DataTypeStr);
                    nextDTName.appendChild(nextDTNameText);
                    nextCalib.appendChild(nextDTName);
                    
                    nextDTMode=infoNode.createElement('DataTypeMode');
                    if(strfind(DataTypeMode,'slope'))
                      nextDTModeText=infoNode.createTextNode('Slope');
                    else
                      nextDTModeText=infoNode.createTextNode('Binary');
                    end
                    nextDTMode.appendChild(nextDTModeText);
                    nextCalib.appendChild(nextDTMode);

                    nextIsSigned=infoNode.createElement('IsSigned');
                    nextIsSignedText=infoNode.createTextNode(num2str(isSigned));
                    nextIsSigned.appendChild(nextIsSignedText);
                    nextCalib.appendChild(nextIsSigned);

                    nextWordLength=infoNode.createElement('WordLength');
                    nextWordLengthText=infoNode.createTextNode(num2str(wordLength));
                    nextWordLength.appendChild(nextWordLengthText);
                    nextCalib.appendChild(nextWordLength);
                    
                    
                    if(strfind(DataTypeMode,'slope'))
                      nextSlope=infoNode.createElement('Slope');
                      nextSlopeText=infoNode.createTextNode(num2str(dtslope));
                      nextSlope.appendChild(nextSlopeText);
                      nextCalib.appendChild(nextSlope);

                      nextBias=infoNode.createElement('Bias');
                      nextBiasText=infoNode.createTextNode(num2str(dtbias));
                      nextBias.appendChild(nextBiasText);
                      nextCalib.appendChild(nextBias);
                    else
                      nextFractionLength=infoNode.createElement('FractionLength');
                      nextFractionLengthText=infoNode.createTextNode(num2str(fractionLength));
                      nextFractionLength.appendChild(nextFractionLengthText);
                      nextCalib.appendChild(nextFractionLength);
                    end
                    
                    if(strcmp(num2str(MinVal),''))
                      MinVal=TypeMin;
                    end
                    
                    if(strcmp(num2str(MaxVal),''))
                      MaxVal=TypeMax;
                    end
                    nextMinVal=infoNode.createElement('MinVal');
                    nextMinValText=infoNode.createTextNode(num2str(MinVal));
                    nextMinVal.appendChild(nextMinValText);
                    nextCalib.appendChild(nextMinVal);

                    nextMaxVal=infoNode.createElement('MaxVal');
                    nextMaxValText=infoNode.createTextNode(num2str(MaxVal));
                    nextMaxVal.appendChild(nextMaxValText);
                    nextCalib.appendChild(nextMaxVal);

                    nextMinVal=infoNode.createElement('MinType');
                    nextMinValText=infoNode.createTextNode(num2str(TypeMin));
                    nextMinVal.appendChild(nextMinValText);
                    nextCalib.appendChild(nextMinVal);

                    nextMaxVal=infoNode.createElement('MaxType');
                    nextMaxValText=infoNode.createTextNode(num2str(TypeMax));
                    nextMaxVal.appendChild(nextMaxValText);
                    nextCalib.appendChild(nextMaxVal);

                    nextPath=infoNode.createElement('Path');
                    nextPathText=infoNode.createTextNode(Path);
                    nextPath.appendChild(nextPathText);
                    nextCalib.appendChild(nextPath);

                    infoRoot.appendChild(nextCalib);                   

                  end

                %elseif(constName(1)=='C')

                %   if(writeconstnames)

                %    fprintf(fconstnames,'%s\n',constName);  

                %   end

                %end

                continue

              end

            else

              continue;

            end

          %case 'SubSystem'

          %  MaskType=get_param(objhndl,'MaskType');

          %  continue;

          case 'Outport'
            %if(length(strfind(blckpar,'/'))~=1)
            %  continue;
            %end

            if(~strcmp(blckpar,orgmodelname))
              continue;
            end

            

            DataTypeStr=eval(sprintf('%s.DataType',blckname));
            
            DataTypeDes=eval(sprintf('%s.Description',DataTypeStr));
            
            Path=sprintf('%s/%s',blckpar,blckname);
            
            PortNum=get_param(objhndl,'Port');

            if(strcmp(DataTypeStr,'T_BOOLEAN'))

              nextOutput=infoNode.createElement('Output');
              
              nextName=infoNode.createElement('Name');
              nextNameText=infoNode.createTextNode(blckname);
              nextName.appendChild(nextNameText);
              nextOutput.appendChild(nextName);

              nextDTName=infoNode.createElement('DataTypeName');
              nextDTNameText=infoNode.createTextNode('TbBOOLEAN');
              nextDTName.appendChild(nextDTNameText);
              nextOutput.appendChild(nextDTName);
              
              nextPath=infoNode.createElement('Path');
              nextPathText=infoNode.createTextNode(blckname);
              nextPath.appendChild(nextPathText);
              nextOutput.appendChild(nextPath);
              
              nextPortNum=infoNode.createElement('PortNum');
              nextPortNumText=infoNode.createTextNode(PortNum);
              nextPortNum.appendChild(nextPortNumText);
              nextOutput.appendChild(nextPortNum); 

              infoRoot.appendChild(nextOutput); 

            elseif(strfind(DataTypeDes,'enum'))
              
              MinVal=eval(sprintf('%s.Min',blckname));
                          
              MaxVal=eval(sprintf('%s.Max',blckname));
              
              
              nextOutput=infoNode.createElement('Output');
              
              nextName=infoNode.createElement('Name');
              nextNameText=infoNode.createTextNode(blckname);
              nextName.appendChild(nextNameText);
              nextOutput.appendChild(nextName);

              nextDTName=infoNode.createElement('DataTypeName');
              nextDTNameText=infoNode.createTextNode('enum');
              nextDTName.appendChild(nextDTNameText);
              nextOutput.appendChild(nextDTName);
              
              
              nextMinVal=infoNode.createElement('MinVal');
              nextMinValText=infoNode.createTextNode(num2str(MinVal));
              nextMinVal.appendChild(nextMinValText);
              nextOutput.appendChild(nextMinVal);

              nextMaxVal=infoNode.createElement('MaxVal');
              nextMaxValText=infoNode.createTextNode(num2str(MaxVal));
              nextMaxVal.appendChild(nextMaxValText);
              nextOutput.appendChild(nextMaxVal);      
              
              
              
              nextPath=infoNode.createElement('Path');
              nextPathText=infoNode.createTextNode(Path);
              nextPath.appendChild(nextPathText);
              nextOutput.appendChild(nextPath);
              
              nextPortNum=infoNode.createElement('PortNum');
              nextPortNumText=infoNode.createTextNode(PortNum);
              nextPortNum.appendChild(nextPortNumText);
              nextOutput.appendChild(nextPortNum);             

              infoRoot.appendChild(nextOutput);                
            else
              
              MinVal=eval(sprintf('%s.Min',blckname));
                          
              MaxVal=eval(sprintf('%s.Max',blckname));    
              
              isSigned=eval(sprintf('%s.Signedness',DataTypeStr));
 
              if(strcmp(isSigned,'Unsigned'))
                isSigned=0;
              else
                isSigned=1;
              end

              wordLength=eval(sprintf('%s.WordLength',DataTypeStr));
              
              
              DataTypeMode=eval(sprintf('%s.DataTypeMode',DataTypeStr));
              if(strfind(DataTypeMode,'slope'))
                display('slope-outport');
                %dtslope=eval(sprintf('%s.Slope',DataTypeStr));
                %dtbias=eval(sprintf('%s.Bias',DataTypeStr));
                %[TypeMin,TypeMax]=Fn_GetMinMaxFix_SlopeMode(isSigned,wordLength,dtslope,dtbias);
              else
                %display('binary');
                %fractionLength=eval(sprintf('%s.FractionLength',DataTypeStr));
                %[TypeMin,TypeMax]=Fn_getminmaxfix(isSigned,wordLength,fractionLength);
              end
              

              fractionLength=eval(sprintf('%s.FractionLength',DataTypeStr));
              
              [TypeMin,TypeMax]=Fn_getminmaxfix(isSigned,wordLength,fractionLength);
 

                    
              nextOutput=infoNode.createElement('Output');

              nextName=infoNode.createElement('Name');
              nextNameText=infoNode.createTextNode(blckname);
              nextName.appendChild(nextNameText);
              nextOutput.appendChild(nextName);

              nextDTName=infoNode.createElement('DataTypeName');
              nextDTNameText=infoNode.createTextNode(DataTypeStr);
              nextDTName.appendChild(nextDTNameText);
              nextOutput.appendChild(nextDTName);

              nextIsSigned=infoNode.createElement('IsSigned');
              nextIsSignedText=infoNode.createTextNode(num2str(isSigned));
              nextIsSigned.appendChild(nextIsSignedText);
              nextOutput.appendChild(nextIsSigned);

              nextWordLength=infoNode.createElement('WordLength');
              nextWordLengthText=infoNode.createTextNode(num2str(wordLength));
              nextWordLength.appendChild(nextWordLengthText);
              nextOutput.appendChild(nextWordLength);

              nextFractionLength=infoNode.createElement('FractionLength');
              nextFractionLengthText=infoNode.createTextNode(num2str(fractionLength));
              nextFractionLength.appendChild(nextFractionLengthText);
              nextOutput.appendChild(nextFractionLength);
              
              nextMinVal=infoNode.createElement('MinVal');
              nextMinValText=infoNode.createTextNode(num2str(MinVal));
              nextMinVal.appendChild(nextMinValText);
              nextOutput.appendChild(nextMinVal);

              nextMaxVal=infoNode.createElement('MaxVal');
              nextMaxValText=infoNode.createTextNode(num2str(MaxVal));
              nextMaxVal.appendChild(nextMaxValText);
              nextOutput.appendChild(nextMaxVal);

              
              nextMinVal=infoNode.createElement('MinType');
              nextMinValText=infoNode.createTextNode(num2str(TypeMin));
              nextMinVal.appendChild(nextMinValText);
              nextOutput.appendChild(nextMinVal);
              
              nextMaxVal=infoNode.createElement('MaxType');
              nextMaxValText=infoNode.createTextNode(num2str(TypeMax));
              nextMaxVal.appendChild(nextMaxValText);
              nextOutput.appendChild(nextMaxVal);
              
              nextPath=infoNode.createElement('Path');
              nextPathText=infoNode.createTextNode(Path);
              nextPath.appendChild(nextPathText);
              nextOutput.appendChild(nextPath);
              
              nextPortNum=infoNode.createElement('PortNum');
              nextPortNumText=infoNode.createTextNode(PortNum);
              nextPortNum.appendChild(nextPortNumText);
              nextOutput.appendChild(nextPortNum);             

              infoRoot.appendChild(nextOutput);    

            end



          case 'Inport'
            
            %if(length(strfind(blckpar,'/'))~=1)
            %  continue;
            %end
            if(~strcmp(blckpar,orgmodelname))
              continue;
            end

            Path=sprintf('%s/%s',blckpar,blckname);
            
            %blckname=blckname(1:length(blckname)-1);

            DataTypeStr=eval(sprintf('%s.DataType',blckname));
            
            DataTypeDes=eval(sprintf('%s.Description',DataTypeStr));
            
            PortNum=get_param(objhndl,'Port');
            

            if(strcmp(DataTypeStr,'T_BOOLEAN'))
 
              nextInput=infoNode.createElement('Input');

              nextName=infoNode.createElement('Name');
              nextNameText=infoNode.createTextNode(blckname);
              nextName.appendChild(nextNameText);
              nextInput.appendChild(nextName);

              nextDTName=infoNode.createElement('DataTypeName');
              nextDTNameText=infoNode.createTextNode('TbBOOLEAN');
              nextDTName.appendChild(nextDTNameText);
              nextInput.appendChild(nextDTName);
              
              nextPath=infoNode.createElement('Path');
              nextPathText=infoNode.createTextNode(Path);
              nextPath.appendChild(nextPathText);
              nextInput.appendChild(nextPath);
              
              nextPortNum=infoNode.createElement('PortNum');
              nextPortNumText=infoNode.createTextNode(PortNum);
              nextPortNum.appendChild(nextPortNumText);
              nextInput.appendChild(nextPortNum); 

              infoRoot.appendChild(nextInput);
            elseif(strfind(DataTypeDes,'enum'))
              
              MinVal=eval(sprintf('%s.Min',blckname));
                          
              MaxVal=eval(sprintf('%s.Max',blckname));
              
              nextInput=infoNode.createElement('Input');

              nextName=infoNode.createElement('Name');
              nextNameText=infoNode.createTextNode(blckname);
              nextName.appendChild(nextNameText);
              nextInput.appendChild(nextName);

              nextDTName=infoNode.createElement('DataTypeName');
              nextDTNameText=infoNode.createTextNode('enum');
              nextDTName.appendChild(nextDTNameText);
              nextInput.appendChild(nextDTName);
              
              
              nextMinVal=infoNode.createElement('MinVal');
              nextMinValText=infoNode.createTextNode(num2str(MinVal));
              nextMinVal.appendChild(nextMinValText);
              nextInput.appendChild(nextMinVal);

              nextMaxVal=infoNode.createElement('MaxVal');
              nextMaxValText=infoNode.createTextNode(num2str(MaxVal));
              nextMaxVal.appendChild(nextMaxValText);
              nextInput.appendChild(nextMaxVal);
              
              nextPath=infoNode.createElement('Path');
              nextPathText=infoNode.createTextNode(Path);
              nextPath.appendChild(nextPathText);
              nextInput.appendChild(nextPath);
              
              nextPortNum=infoNode.createElement('PortNum');
              nextPortNumText=infoNode.createTextNode(PortNum);
              nextPortNum.appendChild(nextPortNumText);
              nextInput.appendChild(nextPortNum); 

              infoRoot.appendChild(nextInput);
            else
              
              MinVal=eval(sprintf('%s.Min',blckname));
                          
              MaxVal=eval(sprintf('%s.Max',blckname));

              isSigned=eval(sprintf('%s.Signedness',DataTypeStr));
              
              if(strcmp(isSigned,'Unsigned'))
                isSigned=0;
              else
                isSigned=1;
              end
              
              wordLength=eval(sprintf('%s.WordLength',DataTypeStr));
              
              DataTypeMode=eval(sprintf('%s.DataTypeMode',DataTypeStr));
              if(strfind(DataTypeMode,'slope'))
                dtslope=eval(sprintf('%s.Slope',DataTypeStr));
                dtbias=eval(sprintf('%s.Bias',DataTypeStr));
                [TypeMin,TypeMax]=Fn_GetMinMaxFix_SlopeMode(isSigned,wordLength,dtslope,dtbias);
              else
                fractionLength=eval(sprintf('%s.FractionLength',DataTypeStr));
                [TypeMin,TypeMax]=Fn_getminmaxfix(isSigned,wordLength,fractionLength);
              end

              nextInput=infoNode.createElement('Input');
              
              nextName=infoNode.createElement('Name');
              nextNameText=infoNode.createTextNode(blckname);
              nextName.appendChild(nextNameText);
              nextInput.appendChild(nextName);

              nextDTName=infoNode.createElement('DataTypeName');
              nextDTNameText=infoNode.createTextNode(DataTypeStr);
              nextDTName.appendChild(nextDTNameText);
              nextInput.appendChild(nextDTName);
              
              
              nextDTMode=infoNode.createElement('DataTypeMode');
              if(strfind(DataTypeMode,'slope'))
                nextDTModeText=infoNode.createTextNode('Slope');
              else
                nextDTModeText=infoNode.createTextNode('Binary');
              end
              nextDTMode.appendChild(nextDTModeText);
              nextInput.appendChild(nextDTMode);

              nextIsSigned=infoNode.createElement('IsSigned');
              nextIsSignedText=infoNode.createTextNode(num2str(isSigned));
              nextIsSigned.appendChild(nextIsSignedText);
              nextInput.appendChild(nextIsSigned);

              nextWordLength=infoNode.createElement('WordLength');
              nextWordLengthText=infoNode.createTextNode(num2str(wordLength));
              nextWordLength.appendChild(nextWordLengthText);
              nextInput.appendChild(nextWordLength);

              if(strfind(DataTypeMode,'slope'))
                nextSlope=infoNode.createElement('Slope');
                nextSlopeText=infoNode.createTextNode(num2str(dtslope));
                nextSlope.appendChild(nextSlopeText);
                nextInput.appendChild(nextSlope);
 
                nextBias=infoNode.createElement('Bias');
                nextBiasText=infoNode.createTextNode(num2str(dtbias));
                nextBias.appendChild(nextBiasText);
                nextInput.appendChild(nextBias);
              else
                nextFractionLength=infoNode.createElement('FractionLength');
                nextFractionLengthText=infoNode.createTextNode(num2str(fractionLength));
                nextFractionLength.appendChild(nextFractionLengthText);
                nextInput.appendChild(nextFractionLength);
              end
              
              
              nextMinVal=infoNode.createElement('MinVal');
              nextMinValText=infoNode.createTextNode(num2str(MinVal));
              nextMinVal.appendChild(nextMinValText);
              nextInput.appendChild(nextMinVal);

              nextMaxVal=infoNode.createElement('MaxVal');
              nextMaxValText=infoNode.createTextNode(num2str(MaxVal));
              nextMaxVal.appendChild(nextMaxValText);
              nextInput.appendChild(nextMaxVal);
              
              nextMinVal=infoNode.createElement('MinType');
              nextMinValText=infoNode.createTextNode(num2str(TypeMin));
              nextMinVal.appendChild(nextMinValText);
              nextInput.appendChild(nextMinVal);
              
              nextMaxVal=infoNode.createElement('MaxType');
              nextMaxValText=infoNode.createTextNode(num2str(TypeMax));
              nextMaxVal.appendChild(nextMaxValText);
              nextInput.appendChild(nextMaxVal);
              
              nextPath=infoNode.createElement('Path');
              nextPathText=infoNode.createTextNode(Path);
              nextPath.appendChild(nextPathText);
              nextInput.appendChild(nextPath);
              
              nextPortNum=infoNode.createElement('PortNum');
              nextPortNumText=infoNode.createTextNode(PortNum);
              nextPortNum.appendChild(nextPortNumText);
              nextInput.appendChild(nextPortNum);             

              infoRoot.appendChild(nextInput);

            end

          otherwise

            continue;      

        end

      case 'line' 

        continue;

      otherwise

        continue;

    end

  end;
  %close_system(find_system());
  xmlwrite(infospath,infoNode);
  display('Info extraction finished successfully with no error!');
catch exc
  display(getReport(exc));
  display('Error in model test run!');
end
diary off;