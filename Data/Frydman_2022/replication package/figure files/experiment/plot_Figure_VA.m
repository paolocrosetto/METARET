clear

%load dataset
load mastermatrix
%"mastermatrix" is a 90,0000 x 10 matrix 

    %Column 1: X
    %Column 2: C
    %Column 3: risky on left = 1, 0 if on right
    %Column 4: risky choice = 1 if choose risky lottery, 0 otherwise
    %Column 5: response time (seconds)
    %Column 6: trial (1-600)
    %Column 7: SubjectID (1-150)
    %Column 8: High condition first=1, 0 otherwise 
    %Column 9: High condition=1, low condition=0
    %Column 10: Test trial = 1, adapt trial =0
    
    
%load parameter values for 30 common trials
load testtrials
    %Column 1: X
    %Column 2: C
    


%clean data with the following four exclusions:
    %remove subj 148 
    %remove 30 adapt trials from each condition
    %remove trials with response time <.5
    %remove second condition

    cleanedmatrix=zeros(1,10);
    count=0;

    for i=1:1:90000
        if mastermatrix(i,7)~=148
            if mastermatrix(i,5)>.5
                if mastermatrix(i,10)==1
                    if mastermatrix(i,6)<301
                        teston=0;
                        
                        %keep only the common trials
                        for t=1:1:30
                            if and(mastermatrix(i,1)==testtrials(t,1),mastermatrix(i,2)==testtrials(t,2))
                                teston=1;
                            end
                        end
                    
                        %filter out trial 144 from subject ID 90, which is a
                        %duplicate common trial (by random chance)
                        if and(teston, not(and(mastermatrix(i,7)==90, mastermatrix(i,6)==144)))
                            count=count+1;
                            cleanedmatrix(count,:)=mastermatrix(i,:);
                        end
                    end
                end
            end
        end
    end


%add 3 columns which round the values X, C, and 0.5*X-C to nearest integer
for i=1:1:length(cleanedmatrix(:,1))
    cleanedmatrix(i,11)=round(cleanedmatrix(i,1));
    cleanedmatrix(i,12)=round(cleanedmatrix(i,2));
    cleanedmatrix(i,13)=round(.5*cleanedmatrix(i,1)-cleanedmatrix(i,2));
end


%create average risk taking curve for high vol condition
high=0;

%k is the integer value of 0.5*X-C
for k=-12:1:12
    count=0;
    summer=0;
    condspecific=zeros(1,13);
    for i=1:1:length(cleanedmatrix(:,1))
        %if high cond
        if cleanedmatrix(i,9)==1
            if k==cleanedmatrix(i,13)
                count=count+1;
                condspecific(count,:)=cleanedmatrix(i,:);
                summer=summer+cleanedmatrix(i,4);
            end
        end
    end
    
    
    high(k+13,1)=summer;
    high(k+13,2)=count;
    
    %frequency of risk taking 
    high(k+13,3)=summer/count;
    
    %standard error
    high(k+13,4)=clusterederrors(condspecific(:,4), condspecific(:,7),150);
end


%create average risk taking curve for low vol condition

low=0;

%k is the integer value of 0.5*X-C
for k=-12:1:12
    count=0;
    summer=0;
    condspecific=zeros(1,13);
    for i=1:1:length(cleanedmatrix(:,1))
        %if low cond
        if cleanedmatrix(i,9)==0
            if k==cleanedmatrix(i,13)
                count=count+1;
                condspecific(count,:)=cleanedmatrix(i,:);
                summer=summer+cleanedmatrix(i,4);
            end
        end
    end
    
    low(k+13,1)=summer;
    low(k+13,2)=count;
    
    %frequency of risk taking
    low(k+13,3)=summer/count;
    
    %standard error
    low(k+13,4)=clusterederrors(condspecific(:,4), condspecific(:,7),150);
end

set(gcf,'color','w');
set(0,'defaultTextInterpreter','latex');
set(gca,'FontName','Times New Roman');

errorbar(-4:1:4, low(9:17,3),low(9:17,4),'-or','MarkerFaceColor','r','MarkerSize', 6,'CapSize',0)
set(gca,'FontSize',16);
hold

errorbar(-12:1:12, high(:,3),high(:,4),'-ob','MarkerSize', 6,'CapSize',0)
set(gca,'FontSize',16);

h = legend('Low vol','High vol');
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest');

ylabel('Frequency of risk taking','Interpreter','Latex','FontSize', 16)
xlabel('$pX-C$','Interpreter','Latex','FontSize', 16)

ylim([0 1])
xlim([-3.5 4.5])
xticks([-3: 1: 4])
