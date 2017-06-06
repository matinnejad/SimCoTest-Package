      %Comparing Current and Old Objective Fnction
      if(ObjectiveFunctionValueCurrent(IndexOfTheSelectedObjectiveFunction)>ObjectiveFunctionValueOld(IndexOfTheSelectedObjectiveFunction))
        ;
      else 
        diffQuality=ObjectiveFunctionValueCurrent(IndexOfTheSelectedObjectiveFunction)-ObjectiveFunctionValueOld(IndexOfTheSelectedObjectiveFunction);
        diffQuality=diffQuality/SATemprature;
        if(rand(1)>exp(diffQuality))
          CurrentValues=OldValues;
          ObjectiveFunctionValueCurrent=ObjectiveFunctionValueOld;
        end
      end
      SATemprature=SATemprature-SATempratureInit/(AlgorithmIterations+1);