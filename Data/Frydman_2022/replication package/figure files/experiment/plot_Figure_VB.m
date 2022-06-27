clear

%load data set of common trials from first condition (see
%"plot_Figure_VA.m" for code that generates the output "cleanedmatrix")
load cleanedmatrix

%load parameter values for 30 common trials
load testtrials

%create frequency of risk taking and standard errors for 30 trials in high
%vol condition

%t indexes the 30 different common trials
for t=1:1:30
    count=0;
    summer=0;
    for i=1:1:length(cleanedmatrix)
        
        %if high vol condition
        if cleanedmatrix(i,9)==1
            if testtrials(t,1)==cleanedmatrix(i,1)
                if testtrials(t,2)==cleanedmatrix(i,2)
                    count=count+1;
                    summer=summer+cleanedmatrix(i,4);
                end
            end
        end
    end
    
    %create frequency of risk taking
    data(t,1)=summer/count;
    
    %standard error
    data(t,2)=(data(t,1)*(1-data(t,1))/(count-1))^.5;
end


%create frequency of risk taking and standard errors for 30 trials in low
%vol condition

%t indexes the 30 different common trials
for t=1:1:30
    count=0;
    summer=0;
    for i=1:1:length(cleanedmatrix)
        
        %if low vol condition
        if cleanedmatrix(i,9)==0
            if testtrials(t,1)==cleanedmatrix(i,1)
                if testtrials(t,2)==cleanedmatrix(i,2)
                    count=count+1;
                    summer=summer+cleanedmatrix(i,4);
                end
            end
        end
    end
    
    %create frequency of risk taking
    data(t,3)=summer/count;
    
    %standard error
    data(t,4)=(data(t,3)*(1-data(t,3))/(count-1))^.5;
end
    
    

%draw scatterplot

set(gcf,'color','w');
set(0,'defaultTextInterpreter','latex');
set(gca,'FontName','Times New Roman');

errorbar(data(:,1),data(:,3),data(:,4),data(:,4),data(:,2),data(:,2),'CapSize',0,'linestyle','none','marker','.','markersize',20,'markerfacecolor','k')
set(gca,'FontSize',16);
hold on

%overlay 45-deg line
hline = refline([1 0]);
hline.Color = 'k';
hline.LineStyle = '-';
hline.HandleVisibility = 'off';
xticks(0:0.2:1);
ylim([0 1])
xlim([0 1])

ylabel('Low volatility','Interpreter','Latex','FontSize', 16)
xlabel('High volatility','Interpreter','Latex','FontSize', 16)
plot(0:1);