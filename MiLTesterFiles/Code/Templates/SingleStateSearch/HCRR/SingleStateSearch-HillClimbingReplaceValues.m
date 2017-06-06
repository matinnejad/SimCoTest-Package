      %Comparing Current and Old Objective Fnction
      if(ObjectiveFunctionValueCurrent(IndexOfTheSelectedObjectiveFunction)>ObjectiveFunctionValueOld(IndexOfTheSelectedObjectiveFunction))
        ;
      else
        CurrentValues=OldValues;
        ObjectiveFunctionValueCurrent=ObjectiveFunctionValueOld;
      end
