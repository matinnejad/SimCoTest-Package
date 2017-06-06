%Generating new values
    NumCandidatePointsInAdaptiveRandom=[NumCandidatePointsInAdaptiveRandomVal];
    CandidatePoints=zeros(NumCandidatePointsInAdaptiveRandom,SearchVariablesCnt);
    for i=1:SearchVariablesCnt,
      for j=1:NumCandidatePointsInAdaptiveRandom,
        CandidatePoints(j,i)=MinValues(i)+(MaxValues(i)-MinValues(i))*rand(1);
      end
    end

    dist=abs(norm(CandidatePoints(1,:)-TestInputValues(1,:)));
    for k=2:LoopCnt,
      if(dist>abs(norm(CandidatePoints(1,:)-TestInputValues(k,:))))
        dist=abs(norm(CandidatePoints(1,:)-TestInputValues(k,:)));
      end
    end
    bestindex=1;
    biggestdis=dist;
    for j=2:NumCandidatePointsInAdaptiveRandom,
      dist=abs(norm(CandidatePoints(j,:)-TestInputValues(1,:)));
      for k = 2:LoopCnt,
        if(dist>abs(norm(CandidatePoints(j,:)-TestInputValues(k,:))))
          dist=abs(norm(CandidatePoints(j,:)-TestInputValues(k,:)));
        end
      end
      if(dist>biggestdis)
        bestindex=j;
        biggestdis=dist;
      end
    end
    CurrentValues=CandidatePoints(bestindex,:);