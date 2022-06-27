function plot_Figure_III
%%%%%%Note: this program produces Figure III in Frydman and Jin (2021)

%%%%%%%%%%%%%%%%%%%%%%%%%%parameter values (overall)%%%%%%%%%%%%%%%%%%%%%%%
N = 200;
decimal_pt = 6;
n = 10; %capacity constraint parameter
prob = 0.5; %probability that risky payoff is positive
%%%%%%%%%%%%%%%%%%parameter values (high vol condition)%%%%%%%%%%%%%%%%%%%%
x_u = 32;         %upper bound of X  (high vol condition)
x_l = 8;          %lower bound of X  (high vol condition)
c_u = prob.*x_u;  %upper bound of C  (high vol condition)
c_l = prob.*x_l;  %lower bound of C  (high vol condition)

%%%%%%%compute posterior means (Eqs. 13 and 14 in the paper)%%%%%%%
post_mean_x_vec = zeros(1,n+1);   
post_mean_c_vec = zeros(1,n+1);     
for i = 1:n+1
    k = i-1;
    func1 = @(x) nchoosek(n,k).*((sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^k.*(1-sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^(n-k)).*(1./(x_u - x_l)).*(x);  
    func2 = @(x) nchoosek(n,k).*((sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^k.*(1-sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^(n-k)).*(1./(x_u - x_l));
    p1 = integral(func1,x_l,x_u,'ArrayValued',true);
    p2 = integral(func2,x_l,x_u,'ArrayValued',true);
    post_mean_x_vec(i) = p1/p2;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    func1 = @(c) nchoosek(n,k).*((sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^k.*(1-sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^(n-k)).*(1./(c_u - c_l)).*(c);  
    func2 = @(c) nchoosek(n,k).*((sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^k.*(1-sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^(n-k)).*(1./(c_u - c_l));
    p1 = integral(func1,c_l,c_u,'ArrayValued',true);
    p2 = integral(func2,c_l,c_u,'ArrayValued',true);
    post_mean_c_vec(i) = p1/p2;
end

%%%%%%%set grid points%%%%%%%          
pX_C_vec = zeros(1,N); %vector of (pX - C) for common trials; (pX - C) goes from "-4" to "4"         
X_vec = []; %vector of X
C_vec = []; %vector of C

for j = 1:N  
   running_pX_C = -4 + (j-1)/(N-1)*8; 
   pX_C_vec(j) = running_pX_C;
   X_upper = min((running_pX_C + 12)/prob,24);
   X_lower = max((running_pX_C + 8)/prob,16);
   for w = 1:N
      running_X = X_lower + (w-1)/(N-1)*(X_upper - X_lower); 
      running_C = prob*running_X - running_pX_C;
      X_vec = [X_vec running_X];
      C_vec = [C_vec running_C];       
   end    
end

%%%%%%%evaluate probability of risk taking on N^2 grid points (high vol condition)%%%%%%%   
prob_rt_h = zeros(1,N^2);
for k_x = 0:n
    for k_c = 0:n
        if (round((post_mean_x_vec(k_x+1))*prob,decimal_pt) > round((post_mean_c_vec(k_c+1)),decimal_pt))
            prob_rt_h = prob_rt_h + binopdf(k_x,n,(sin(pi./2*(X_vec - x_l)./(x_u - x_l))).^2).*binopdf(k_c,n,(sin(pi./2*(C_vec - c_l)./(c_u - c_l))).^2);
        elseif (round((post_mean_x_vec(k_x+1))*prob,decimal_pt) == round((post_mean_c_vec(k_c+1)),decimal_pt))
            prob_rt_h = prob_rt_h + 0.5.*binopdf(k_x,n,(sin(pi./2*(X_vec - x_l)./(x_u - x_l))).^2).*binopdf(k_c,n,(sin(pi./2*(C_vec - c_l)./(c_u - c_l))).^2);       
        else
        end
    end
end   
          
%%%%%%%%%%%%%%%%%%parameter values (low vol condition)%%%%%%%%%%%%%%%%%%%%%
x_u = 24;          %upper bound of X  (low vol condition)
x_l = 16;          %lower bound of X  (low vol condition)
c_u = prob.*x_u;   %upper bound of C  (low vol condition)
c_l = prob.*x_l;   %lower bound of C  (low vol condition)

%%%%%%%compute posterior means (Eqs. 13 and 14 in the paper)%%%%%%%
post_mean_x_vec = zeros(1,n+1);   
post_mean_c_vec = zeros(1,n+1);     
for i = 1:n+1
    k = i-1;
    func1 = @(x) nchoosek(n,k).*((sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^k.*(1-sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^(n-k)).*(1./(x_u - x_l)).*(x);  
    func2 = @(x) nchoosek(n,k).*((sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^k.*(1-sin(pi/2.*(x - x_l)./(x_u - x_l)).^2).^(n-k)).*(1./(x_u - x_l));
    p1 = integral(func1,x_l,x_u,'ArrayValued',true);
    p2 = integral(func2,x_l,x_u,'ArrayValued',true);
    post_mean_x_vec(i) = p1/p2;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    func1 = @(c) nchoosek(n,k).*((sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^k.*(1-sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^(n-k)).*(1./(c_u - c_l)).*(c);  
    func2 = @(c) nchoosek(n,k).*((sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^k.*(1-sin(pi/2.*(c - c_l)./(c_u - c_l)).^2).^(n-k)).*(1./(c_u - c_l));
    p1 = integral(func1,c_l,c_u,'ArrayValued',true);
    p2 = integral(func2,c_l,c_u,'ArrayValued',true);
    post_mean_c_vec(i) = p1/p2;
end

%%%%%%%evaluate probability of risk taking on N^2 grid points (low vol condition)%%%%%%%  
prob_rt_l = zeros(1,N^2);
for k_x = 0:n
    for k_c = 0:n
        if (round((post_mean_x_vec(k_x+1))*prob,decimal_pt) > round((post_mean_c_vec(k_c+1)),decimal_pt))
            prob_rt_l = prob_rt_l + binopdf(k_x,n,(sin(pi./2*(X_vec - x_l)./(x_u - x_l))).^2).*binopdf(k_c,n,(sin(pi./2*(C_vec - c_l)./(c_u - c_l))).^2);
        elseif (round((post_mean_x_vec(k_x+1))*prob,decimal_pt) == round((post_mean_c_vec(k_c+1)),decimal_pt))
            prob_rt_l = prob_rt_l + 0.5.*binopdf(k_x,n,(sin(pi./2*(X_vec - x_l)./(x_u - x_l))).^2).*binopdf(k_c,n,(sin(pi./2*(C_vec - c_l)./(c_u - c_l))).^2);       
        else
        end
    end
end             

%%%%%%%aggregate risk taking probabilities for each level of pX - C%%%%%%% 
prob_rt_h_agg = zeros(1,N);
prob_rt_l_agg = zeros(1,N);

for j = 1:N
   agg_h = 0;
   agg_l = 0;   
   for w = 1:N
       index = (j-1)*N + w;
       agg_h = agg_h + prob_rt_h(index);
       agg_l = agg_l + prob_rt_l(index);
   end
   agg_h = agg_h/N;
   agg_l = agg_l/N;
   prob_rt_h_agg(j) = agg_h;
   prob_rt_l_agg(j) = agg_l;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot Figure III%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(gcf,'color','w');
set(0,'defaultTextInterpreter','latex');
set(gca,'FontName','Times New Roman');

set(gca,'FontSize',16);
h1 = plot(pX_C_vec, prob_rt_l_agg,'r');
hold on;
h2 = plot(pX_C_vec, prob_rt_h_agg,'b--');
set(gca,'FontSize',16);
h = legend([h1 h2],{'Low vol','High vol'});
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest')
xlabel('$pX - C$','Interpreter','Latex','FontSize', 16)
ylabel('Probability of risk taking','Interpreter','Latex','FontSize', 16)

end