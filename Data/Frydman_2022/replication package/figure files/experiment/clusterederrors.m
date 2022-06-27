function [clusteredSE] = clusterederrors(y, k, M)
%takes as input:

%y: Nx1 vector of responses
%k: Nx1 vector of subject IDs
%M: num subjects in experiment (ordered 1,2,...,M)

M=150;
grandsum=0;
%compute grand mean
beta=mean(y);
count=zeros(M,1);

%M is number of subjects in experiment, though not necessarily number of
%subjects who contribute observations in all conditions
for i=1:1:M
    resid=0;
    %loop through vector of all observations
    for t=1:1:length(y(:,1))        
        %if obs is for subject k
        if i==k(t,1)
            count(i,1)=count(i,1)+1;
            resid(count(i,1),1)=y(t,1)-beta;
        end
    end
    
    %number of obs for subj i
    Mlength=length(resid(:,1));
    f=ones(Mlength,1);
    grandsum=grandsum+f'*((resid*resid')*f);
end

%count number of distinct subjects (non-zero elements of 'count')
newM=0;
for i=1:1:M
    if count(i,1)>0
        newM=newM+1;
    end
end

N=length(y(:,1));
variance=(newM/(newM-1))*(1/N^2)*grandsum;
clusteredSE=variance^.5;
            
   