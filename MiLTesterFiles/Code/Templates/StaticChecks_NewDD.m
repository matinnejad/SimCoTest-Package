%diary('D:\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Code\Temp\output.log');
try
  wsstr=who; 
  %if(length(wsstr)<=0)
    addpath(genpath('D:\Desktop\MiLTester\bin\Debug\MiLTesterFiles\Code\Functions'));
    %run('SC_MiLTester_ModelSettingsScript');
  %end
  %close_system(find_system); 

  %orgmodelname='etc_oil_pres_diag_autocode';
  %orgmodelname='etc_oil_pres_duty_cycle_autocode';
  orgmodelname='etc_oil_pres_pmp_cntl_autocode';
  %orgmodelname='etc_oil_pres_pmp_diag_autocode';

  orgmodelpath='D:\projfiles\simulink\models\';

  addpath(orgmodelpath);

  load_system(sprintf('%s%s',orgmodelname,'.mdl'));

  filesdirectory=sprintf('%s\\%s-Files\\',orgmodelpath,orgmodelname);
  if(~exist(filesdirectory,'dir'))
    mkdir(filesdirectory)
  end

  stchecksNode = com.mathworks.xml.XMLUtils.createDocument('root_stchecks');
  stchecksRoot = stchecksNode.getDocumentElement;
  stchecksblockspath = sprintf('%s\\%s-Files\\StChecksBlocks.xml',orgmodelpath,orgmodelname);
  
  fromcnt=1;
  gotocnt=1;
  clear fromStringTag;
  clear gotoStringTag;
  clear fromStringFullTag;
  clear gotoStringFullTag;
  clear fromStringPath;
  clear gotoStringPath; 
  %Simulink blocks and lines manipulation
  objhandles=find_system(orgmodelname,'FindAll','on');
  objcnt=0;
  while(objcnt<length(objhandles))   
    objcnt=objcnt+1;
    objhndl=objhandles(objcnt);
    objecttype=get_param(objhndl,'Type');  
    switch(objecttype)
      case 'block'     
        blckname=get_param(objhndl,'Name');
        blckpar=get_param(objhndl,'Parent');
        blcktype=get_param(objhndl,'BlockType');
        blckpath=sprintf('%s/%s',blckpar,blckname);
        
        oparams=get_param(objhndl,'ObjectParameters');
        if(isfield(oparams,'SaturateOnIntegerOverflow'))
          if(strcmp(get_param(objhndl,'SaturateOnIntegerOverflow'),'off'))
            nextnstof=stchecksNode.createElement('NoStOF');
            %%%
            nextTag=stchecksNode.createElement('Tag');
            nextTagText=stchecksNode.createTextNode(blckname);
            nextTag.appendChild(nextTagText);
            nextnstof.appendChild(nextTag);

            nextPath=stchecksNode.createElement('Path');
            nextPathText=stchecksNode.createTextNode(blckpath);
            nextPath.appendChild(nextPathText);
            nextnstof.appendChild(nextPath);

            stchecksRoot.appendChild(nextnstof);   
          end
        end
        if(strcmp(blcktype,'From'))
          fromStringTag{fromcnt}=sprintf('%s',get_param(objhndl,'GotoTag'));
          fromStringFullTag{fromcnt}=sprintf('%s/%s',blckpar,get_param(objhndl,'GotoTag'));
          fromStringPath{fromcnt}=blckpath;
          fromcnt=fromcnt+1;
        end
        if(strcmp(blcktype,'Goto'))
          gotoStringTag{gotocnt}=sprintf('%s',get_param(objhndl,'GotoTag'));
          gotoStringFullTag{gotocnt}=sprintf('%s/%s',blckpar,get_param(objhndl,'GotoTag'));
          gotoStringPath{gotocnt}=blckpath;
          gotocnt=gotocnt+1;
        end 
        if(strcmp(blcktype,'Constant'))
          if(find(ismember(fieldnames(get_param(objhndl,'ObjectParameters')),'Value')))
            value=str2num(get_param(objhndl,'Value'));
            if(isempty(value))
              constName=get_param(objhndl,'Value');
              if(constName(1)=='K')
                if(findstr(constName,'High'))
                  lowConstName=strrep(constName,'High','Low')
                  %if(eval(sprintf('exist(''lowConstName'',''var'')',constName))==1)())
                  
                  %end
                end
                if(strcmp(constName(1:2),'Kt'))
                  
                  
                  if((eval(sprintf('size(%s.Value,1)',constName))==1) && (eval(sprintf('size(%s.Value,2)',constName))==1))
                    nexttbloneval=stchecksNode.createElement('TblOneVal');
                    %%%
                    nextTag=stchecksNode.createElement('Tag');
                    nextTagText=stchecksNode.createTextNode(constName);
                    nextTag.appendChild(nextTagText);
                    nexttbloneval.appendChild(nextTag);

                    nextPath=stchecksNode.createElement('Path');
                    nextPathText=stchecksNode.createTextNode(blckpath);
                    nextPath.appendChild(nextPathText);
                    nexttbloneval.appendChild(nextPath);

                    stchecksRoot.appendChild(nexttbloneval);  
                  
                  end
                  if(eval(sprintf('size(%s.Value,1)',constName))==eval(sprintf('size(unique(%s.Value),1)',constName))...
                    &&eval(sprintf('size(%s.Value,2)',constName))==eval(sprintf('size(unique(%s.Value),2)',constName)))
                    nexttblthesame=stchecksNode.createElement('TblAllTheSame');
                    %%%
                    nextTag=stchecksNode.createElement('Tag');
                    nextTagText=stchecksNode.createTextNode(constName);
                    nextTag.appendChild(nextTagText);
                    nexttblthesame.appendChild(nextTag);

                    nextPath=stchecksNode.createElement('Path');
                    nextPathText=stchecksNode.createTextNode(blckpath);
                    nextPath.appendChild(nextPathText);
                    nexttblthesame.appendChild(nextPath);

                    stchecksRoot.appendChild(nexttblthesame);  
                  end
                
                  
                
                elseif(eval(sprintf('size(%s.Value,1)',constName))~=1 || eval(sprintf('size(%s.Value,2)',constName))~=1)
                  nextvalmult=stchecksNode.createElement('ParMultVal');
                  %%%
                  nextTag=stchecksNode.createElement('Tag');
                  nextTagText=stchecksNode.createTextNode(blckname);
                  nextTag.appendChild(nextTagText);
                  nextvalmult.appendChild(nextTag);

                  nextPath=stchecksNode.createElement('Path');
                  nextPathText=stchecksNode.createTextNode(blckpath);
                  nextPath.appendChild(nextPathText);
                  nextvalmult.appendChild(nextPath);

                  stchecksRoot.appendChild(nextvalmult);  
                end
              end
            end
          end
        end
    end
  end;
  [diff,diffind]=setdiff(fromStringFullTag,gotoStringFullTag);
  for i=1:length(diffind),
    nextfng=stchecksNode.createElement('FromNoGoTo');
    
    nextTag=stchecksNode.createElement('Tag');
    nextTagText=stchecksNode.createTextNode(fromStringTag{i});
    nextTag.appendChild(nextTagText);
    nextfng.appendChild(nextTag);
    
    nextPath=stchecksNode.createElement('Path');
    nextPathText=stchecksNode.createTextNode(fromStringPath{i});
    nextPath.appendChild(nextPathText);
    nextfng.appendChild(nextPath);

    stchecksRoot.appendChild(nextfng);   
  end
  [diff,diffind]=setdiff(gotoStringFullTag,fromStringFullTag);
  for i=1:length(diff),
    nextgnf=stchecksNode.createElement('GoToNoFrom');

    nextTag=stchecksNode.createElement('Tag');
    nextTagText=stchecksNode.createTextNode(gotoStringTag{i});
    nextTag.appendChild(nextTagText);
    nextgnf.appendChild(nextTag);
    
    nextPath=stchecksNode.createElement('Path');
    nextPathText=stchecksNode.createTextNode(gotoStringPath{i});
    nextPath.appendChild(nextPathText);
    nextgnf.appendChild(nextPath);    
    
    stchecksRoot.appendChild(nextgnf);
  end
  xmlwrite(stchecksblockspath,stchecksNode);
  display('Static checks finished successfully with no error!');
catch excp
  display(getReport(excp));
  close_system(find_system()); 
end