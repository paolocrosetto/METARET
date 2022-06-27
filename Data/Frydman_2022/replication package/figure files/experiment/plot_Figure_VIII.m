clear

%load perceptual choice dataset
%data is a 120,0000 x 9 matrix called "mastermatrix"
load mastermatrixperceptual

    %Column 1: stimulus number (33 - 99)
    %Column 2: correct=1, incorrect=0
    %Column 3: response time (seconds)
    %Column 4: trial (1--800)
    %Column 5: SubjectID (1-150)
    %Column 6: High condition first=1, 0 otherwise
    %Column 7: High condition = 1, 0 otherwise
    %Column 8: Test trial (trials 61-400 & 461-800)
    %Column 9: Classify as greater than 65 = 1, 0 otherwise

%dummy variable to plot either panel A (panel_a = 1) or panel B (panel_a = 0) 
panel_a = 1;

%clean data with the following four exclusions:

    %remove subj 3 & 8 (because of excessively fast average RTs) 
    %remove subj 148
    %remove 60 adapt trials from each condition
    %remove second condition

    cleanedmatrix=zeros(1,9);
    count=0;

    %loop over whole data set
    for i=1:1:120000
    
        %if subject not excessively fast RT
        if ~or(mastermatrix(i,5)==3, mastermatrix(i,5)==8)
            %if subject not excluded based on risky choice task exclusion
            if (mastermatrix(i,5)~=148)
                %if non-adapt trial
                if mastermatrix(i,8)==3
                    % if first condition
                    if mastermatrix(i,4)<401
                        count=count+1;
                        cleanedmatrix(count,:)=mastermatrix(i,:);
                    end
                end
            end
        end
    end


%******CHOICE DATA ANALYSIS******

%create classification average for each X in high vol condition
high=0;

for k=31:1:99
    count=0;
    summer=0;
    condspecific=zeros(1,9);
    
    %loop through whole dataset
    for i=1:1:length(cleanedmatrix(:,1))
        
        %if high condition
        if cleanedmatrix(i,7)==1
            
            % if num matches
            if k==cleanedmatrix(i,1)
                count=count+1;
                
                if cleanedmatrix(i,1)>65
                    
                    %if classified as greater than 65
                    if cleanedmatrix(i,2)==1
                        summer=summer+1;
                    end
                    
                else
                    
                    %if classified as greater than 65
                    if cleanedmatrix(i,2)==0
                        summer=summer+1;
                    end
                end
                
                %store cleaned data for high vol condition
                condspecific(count,:)=cleanedmatrix(i,:);      
            end
        end
    end
    
    high(k,1)=summer;
    high(k,2)=count;
    
    %average classification 
    high(k,3)=summer/count;
    
    %standard errors
    high(k,4)=clusterederrors(condspecific(:,9), condspecific(:,5),150);
end

%create classification average for each X in low vol condition
low=0;

for k=56:1:74
    count=0;
    summer=0;
    condspecific=zeros(1,9);
    
    %loop through whole dataset
    for i=1:1:length(cleanedmatrix(:,1))
        
        %if low condition
        if cleanedmatrix(i,7)==0
            
            %if num matches
            if k==cleanedmatrix(i,1)
                count=count+1;
                
                if cleanedmatrix(i,1)>65
                    
                    %if classified as greater than 65
                    if cleanedmatrix(i,2)==1
                        summer=summer+1;
                    end
                    
                else
                    
                    %if classified as greater than 65
                    if cleanedmatrix(i,2)==0
                        summer=summer+1;
                    end
                end
                
                 %store cleaned data for low vol condition
                condspecific(count,:)=cleanedmatrix(i,:);    
            end
        end
    end
    
    low(k,1)=summer;
    low(k,2)=count;
    
    %average classification
    low(k,3)=summer/count;
    
    %standard errors
    low(k,4)=clusterederrors(condspecific(:,9), condspecific(:,5),150);
end



%set fig properties
set(gcf,'color','w');
set(0,'defaultTextInterpreter','latex');
set(gca,'FontName','Times New Roman');

%plot upper panel
if (panel_a == 1)
    errorbar(56:1:74, low(56:74,3),low(56:74,4),'or','MarkerFaceColor','r','MarkerSize', 4,'CapSize',0)
    set(gca,'FontSize',16);
    hold on
    
    errorbar(31:1:99, high(31:99,3),high(31:99,4),'ob','MarkerSize', 4,'CapSize',0)
    set(gca,'FontSize',16);
    line([65 65], [0 1],'color','k','LineWidth',1);
    h = legend('Low vol','High vol');
    set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest');
    ylabel('Probability to classify $X$ above 65','Interpreter','Latex','FontSize', 16)
    xlabel('$X$','Interpreter','Latex','FontSize', 16)
    ylim([0 1])
end



%******RESPONSE TIME DATA ANALYSIS******

%create RT average for each X in high vol condition
high=0;
for k=31:1:99
    count=0;
    summer=0;
    condspecific=zeros(1,9);
    
    %loop through whole dataset
    for i=1:1:length(cleanedmatrix(:,1))
        
        %if high condition
        if cleanedmatrix(i,7)==1
            
            % if num matches
            if k==cleanedmatrix(i,1)
                
                %if correct classification
                if cleanedmatrix(i,2)==1
                    count=count+1;
                    summer=summer+cleanedmatrix(i,3);
                    condspecific(count,:)=cleanedmatrix(i,:);     
                end
            end
        end
    end
    
    high(k,1)=summer;
    high(k,2)=count;
    
    %average RT
    high(k,3)=summer/count;
    
    %standard error
    high(k,4)=clusterederrors(condspecific(:,3), condspecific(:,5),150);
end


%create RT average for each X in low vol condition
low=0;
for k=56:1:74
    count=0;
    summer=0;
    condspecific=zeros(1,9);
    
    %loop through whole dataset
    for i=1:1:length(cleanedmatrix(:,1))
        
        %if low condition
        if cleanedmatrix(i,7)==0
            
            %if num matches
            if k==cleanedmatrix(i,1)
                
                %if correct classification
                if cleanedmatrix(i,2)==1
                    count=count+1;
                    summer=summer+cleanedmatrix(i,3);
                    condspecific(count,:)=cleanedmatrix(i,:);  
                end
            end
        end
    end
    
    low(k,1)=summer;
    low(k,2)=count;
    
    %average RT
    low(k,3)=summer/count;
    
    %standard error
    low(k,4)=clusterederrors(condspecific(:,3), condspecific(:,5),150);
    
end

%plot lower panel
if (panel_a == 0)    
    errorbar(56:1:74, low(56:74,3),low(56:74,4),'-or','MarkerFaceColor','r','MarkerSize', 4,'CapSize',0)
    set(gca,'FontSize',16);
    hold on
    
    errorbar(31:1:99, high(31:99,3),high(31:99,4),'-ob','MarkerSize', 4,'CapSize',0,'LineWidth',.15)
    set(gca,'FontSize',16);
    line([65 65], [.45, .75],'color','k','LineWidth',1);
    h = legend('Low vol','High vol');
    set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest');
    ylabel('Average response time (seconds)','Interpreter','Latex','FontSize', 16)
    xlabel('$X$','Interpreter','Latex','FontSize', 15)
    ylim([.45 .75])
end




            
        