      %Generating new values            
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
