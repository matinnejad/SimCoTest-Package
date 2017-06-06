   %Generating new values            
   if(LoopCnt<=NextLoopCntRestart)
      for i=1:SearchVariablesCnt,      
        NewValues(i)=CurrentValues(i)+Fn_MiLTester_My_Normal_Rnd(0,[MiLTester_EASigmalVal]);
      end
      NewValuesAreInMinMaxRanges=true;
      for i=1:SearchVariablesCnt,
        if(NewValues(i)>MaxValues(i) || NewValues(i)<MinValues(i))
          NewValuesAreInMinMaxRanges=false;      
        end  
      end 
      while(~NewValuesAreInMinMaxRanges)
          for i=1:SearchVariablesCnt,      
              NewValues(i)=CurrentValues(i)+Fn_MiLTester_My_Normal_Rnd(0,[MiLTester_EASigmalVal]);
          end
          NewValuesAreInMinMaxRanges=true; 
          for i=1:SearchVariablesCnt,
            if(NewValues(i)>MaxValues(i) || NewValues(i)<MinValues(i))
              NewValuesAreInMinMaxRanges=false;      
            end  
          end 
      end
   else
      for i=1:SearchVariablesCnt,          
        NewValues(i)=MinValues(i)+(MaxValues(i)-MinValues(i))*rand(1);           
      end
      NextLoopCntRestart=(AlgorithmIterations/2.5-AlgorithmIterations/5)*rand(1)+AlgorithmIterations/5+LoopCnt;
      ObjectiveFunctionValueOld=zeros(NumberOfObjectives,1);
   end