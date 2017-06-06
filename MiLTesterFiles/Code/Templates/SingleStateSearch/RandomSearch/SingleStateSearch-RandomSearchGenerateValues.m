      %Generating new values            
      for i=1:SearchVariablesCnt,          
        NewValues(i)=MinValues(i)+(MaxValues(i)-MinValues(i))*rand(1);           
      end