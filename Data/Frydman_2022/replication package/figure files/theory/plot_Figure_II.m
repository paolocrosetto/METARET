function plot_Figure_II
%%%%%%Note: this program produces Figure II in Frydman and Jin (2021)

%%%%%%%%%%%%%%%%%%%%%%%%%%parameter values (overall)%%%%%%%%%%%%%%%%%%%%%%%
n = 10;     %capacity constraint parameter
N = 100;    %size of vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%volatility manipulation (Panel A)%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%parameter values%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_u_h = 32; %upper bound of X  (high vol condition)
x_l_h = 8;  %lower bound of X  (high vol condition)
x_u_l = 24; %upper bound of X  (low vol condition)
x_l_l = 16; %lower bound of X  (low vol condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%vectors to plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X_vec_h = zeros(1,N); %vector of X (high vol condition)
X_vec_l = zeros(1,N); %vector of X (low vol condition)
value_X_h = zeros(1,N); %vector of value function (high vol condition)
upper_value_X_h = zeros(1,N); %one-standard-deviation bound (upper)
lower_value_X_h = zeros(1,N); %one-standard-deviation bound (lower)
value_X_l = zeros(1,N); %vector of value function (low vol condition)
upper_value_X_l = zeros(1,N); %one-standard-deviation bound (upper)
lower_value_X_l = zeros(1,N); %one-standard-deviation bound (lower)
pdf_vec_h = zeros(1,N);  %vector of pdf (high vol condition)
pdf_vec_ll = zeros(1,N); %vector of pdf (low vol condition; low vol range)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:N
    X_vec_h(i) = x_l_h + (i-1)/N*(x_u_h - x_l_h);
    X_vec_l(i) = x_l_l + (i-1)/N*(x_u_l - x_l_l);
    pdf_vec_h(i) = 1/(x_u_h - x_l_h);
    if (X_vec_h(i) <= x_u_l && X_vec_h(i) >= x_l_l)
        pdf_vec_ll(i) = 1/(x_u_l - x_l_l);
    end        
    %%%%%%%%%%%%%high volatility%%%%%%%%%%%%%
    output = derived_posterior_mean_stdev_uni(X_vec_h(i),x_l_h,x_u_h);
    value_X_h(i) = output(1);
    upper_value_X_h(i) = output(1) + output(2);
    lower_value_X_h(i) = output(1) - output(2);
    %%%%%%%%%%%%%low volatility%%%%%%%%%%%%%    
    output = derived_posterior_mean_stdev_uni(X_vec_l(i),x_l_l,x_u_l);
    value_X_l(i) = output(1);
    upper_value_X_l(i) = output(1) + output(2);
    lower_value_X_l(i) = output(1) - output(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot Panel A%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%upper graph%%%%%%%
set(gcf,'color','w');
set(0,'defaultTextInterpreter','latex');
set(gca,'FontName','Times New Roman');

h1a = subplot(2,2,1);
set(gca,'FontSize',16);
h1 = plot(X_vec_h,pdf_vec_ll,'r');
hold on;
h2 = plot(X_vec_h,pdf_vec_h,'b--');
set(gca,'FontSize',16);
h = legend([h1 h2],{'Low vol','High vol'});
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest')
title('$\bf{Panel\hspace{0.05in}A}$','Interpreter','Latex','FontSize', 16)
xlabel('$X$','Interpreter','Latex','FontSize', 16)
xlim([x_l_h,x_u_h])
ylim([0.02,0.2])
ylabel('$f(X)$','Interpreter','Latex','FontSize', 16)
h1_pos = get(h1a,'Position');
h1_pos(3) = h1_pos(3) - 0.04;
set(h1a, 'Position', h1_pos);

%%%%%%%lower graph%%%%%%%
h3a = subplot(2,2,3);
set(gca,'FontSize',16);
h1 = plot(X_vec_l,value_X_l,'r','LineWidth',2);
hold on;
plot(X_vec_l,upper_value_X_l,'-.r');
plot(X_vec_l,lower_value_X_l,'-.r');
h2 = plot(X_vec_h,value_X_h,'b--','LineWidth',2);
plot(X_vec_h,upper_value_X_h,'-.b');
plot(X_vec_h,lower_value_X_h,'-.b');
plot(X_vec_h,X_vec_h,'k:');
set(gca,'FontSize',16);
h = legend([h1 h2],{'Low vol','High vol'});
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest')
xlabel('$X$','Interpreter','Latex','FontSize', 16)
xlim([x_l_h,x_u_h])
ylabel('Subjective valuation of $X$','Interpreter','Latex','FontSize', 16)
h3_pos = get(h3a,'Position');
h3_pos(3) = h3_pos(3) - 0.04;
set(h3a, 'Position', h3_pos);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%shape manipulation (Panel B)%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%parameter values%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_u = 8;     %upper bound of X
x_l = 2;     %lower bound of X
x_m_i = 4.5; %switching point for density of the increasing prior
x_m_d = 5.5; %switching point for density of the decreasing prior
ratio = 35;  %ratio of the high-to-low density
%%%%%%%%%%%%%%%%%%%%%%%%%%vectors to plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X_vec = zeros(1,N); %vector of X
value_X_i = zeros(1,N); %vector of value function (increasing prior)
upper_value_X_i = zeros(1,N); %one-standard-deviation bound (upper)
lower_value_X_i = zeros(1,N); %one-standard-deviation bound (lower)
value_X_d = zeros(1,N); %vector of value function (decreasing prior)
upper_value_X_d = zeros(1,N); %one-standard-deviation bound (upper)
lower_value_X_d = zeros(1,N); %one-standard-deviation bound (lower)
pdf_vec_i = zeros(1,N); %vector of pdf (increasing prior)
pdf_vec_d = zeros(1,N); %vector of pdf (decreasing prior)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:N
    X_vec(i) = x_l + (i-1)/N*(x_u - x_l);
    if (X_vec(i) <= x_m_i)
        pdf_vec_i(i) = 1/(ratio*(x_u - x_m_i) + (x_m_i - x_l));
    else
        pdf_vec_i(i) = ratio/(ratio*(x_u - x_m_i) + (x_m_i - x_l));
    end
    if (X_vec(i) <= x_m_d)
        pdf_vec_d(i) = ratio/((x_u - x_m_d) + ratio*(x_m_d - x_l));
    else
        pdf_vec_d(i) = 1/((x_u - x_m_d) + ratio*(x_m_d - x_l));
    end        
    %%%%%%%%%%%%%increasing prior%%%%%%%%%%%%%
    output = value_function_i(X_vec(i),x_l,x_u,x_m_i,ratio);
    value_X_i(i) = output(1);
    upper_value_X_i(i) = output(1) + output(2);
    lower_value_X_i(i) = output(1) - output(2);
    %%%%%%%%%%%%%decreasing prior%%%%%%%%%%%%%    
    output = value_function_d(X_vec(i),x_l,x_u,x_m_d,ratio);
    value_X_d(i) = output(1);
    upper_value_X_d(i) = output(1) + output(2);
    lower_value_X_d(i) = output(1) - output(2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%plot Panel B%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%upper graph%%%%%%%
h2a = subplot(2,2,2);
set(gca,'FontSize',16);
plot(X_vec,pdf_vec_d,'r',X_vec,pdf_vec_i,'b--');
set(gca,'FontSize',16);
h = legend('Decreasing','Increasing');
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest')
title('$\bf{Panel\hspace{0.05in}B}$','Interpreter','Latex','FontSize', 16)
xlabel('$X$','Interpreter','Latex','FontSize', 16)
xlim([x_l,x_u])
ylim([0.0,0.4])
ylabel('$f(X)$','Interpreter','Latex','FontSize', 16)
h2_pos = get(h2a,'Position');
h2_pos(3) = h2_pos(3) - 0.04;
set(h2a, 'Position', h2_pos);

%%%%%%%lower graph%%%%%%%
h4a = subplot(2,2,4);
set(gca,'FontSize',16);
h1 = plot(X_vec,value_X_d,'r','LineWidth',2);
hold on;
plot(X_vec,upper_value_X_d,'-.r');
plot(X_vec,lower_value_X_d,'-.r');
h2 = plot(X_vec,value_X_i,'b--','LineWidth',2);
plot(X_vec,upper_value_X_i,'-.b');
plot(X_vec,lower_value_X_i,'-.b');
plot(X_vec,X_vec,'k:');
set(gca,'FontSize',16);
h = legend([h1 h2],{'Decreasing','Increasing'});
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest')
xlabel('$X$','Interpreter','Latex','FontSize', 16)
xlim([x_l,x_u])
ylabel('Subjective valuation of $X$','Interpreter','Latex','FontSize', 16)
h4_pos = get(h4a,'Position');
h4_pos(3) = h4_pos(3) - 0.04;
set(h4a, 'Position', h4_pos);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%define sub-functions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%value function and standard deviation (uniform prior)%%%%%%%%%%%%%%%%
function [output_uniform] = derived_posterior_mean_stdev_uni(X,x_l,x_h)

%%%%%%%%%%%%%%%%%%%%%%%%%%basic description%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% this function produces the subjective valuation and its
%%% one-standard-deviation bounds when prior distribution is uniform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output_uniform = zeros(2,1);

%%%%%%%likelihood function%%%
P_x_k1 = @(k1) nchoosek(n,k1).*(theta_x(X)).^k1.*(1-theta_x(X)).^(n-k1);  

%%%%%%%compute valuation and standard deviation (Eqs. 15 and 16 in the
%%%%%%%paper)%%%%%%%
mean = 0;
mean_sq = 0;
for j = 0:n
    mean = mean+P_x_k1(j)*post_mean(j);
    mean_sq = mean_sq + P_x_k1(j)*(post_mean(j))^2;
end
output_uniform(1) = mean;
output_uniform(2) = sqrt(mean_sq - mean^2);
   
%%%%%%%posterior mean%%%%%%%
   function p = post_mean(k)
   func1 = @(x) (nchoosek(n,k).*(theta_x(x)).^k.*(1-theta_x(x)).^(n-k)).*(1./(x_h - x_l)).*x;  
   func2 = @(x) (nchoosek(n,k).*(theta_x(x)).^k.*(1-theta_x(x)).^(n-k)).*(1./(x_h - x_l));  
   p1 = integral(func1,x_l,x_h,'ArrayValued',true);
   p2 = integral(func2,x_l,x_h,'ArrayValued',true);
   p = p1/p2;
   end
%%%%%%%coding function%%%%%%
  function q = theta_x(x1)
      q = (sin(pi/2.*(x1 - x_l)./(x_h - x_l))).^2;        
  end
end

%%%%%%value function and standard deviation (increasing or decreasing prior)%%%%%%%%%%%%%

%%%%%%%increasing prior%%%
function [output_inc] = value_function_i(X,x_l,x_h,x_m,ratio)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%basic description%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% this function produces the subjective valuation and its
%%% one-standard-deviation bounds when prior distribution is increasing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%specify "l" and "h" in Eq. 18 of the paper%%%%%%%
l = 1/(ratio*(x_h - x_m) + (x_m - x_l));
h = l*ratio;

output_inc = zeros(2,1);

%%%%%%%likelihood function%%%
P_x_k1 = @(k1) nchoosek(n,k1).*(theta_x(X)).^k1.*(1-theta_x(X)).^(n-k1);

%%%%%%%compute valuation and standard deviation (Eqs. 15 and 16 in the
%%%%%%%paper)%%%%%%%
mean = 0;
mean_sq = 0;
for j = 0:n
    mean = mean+P_x_k1(j)*post_mean(j);
    mean_sq = mean_sq + P_x_k1(j)*(post_mean(j))^2;    
end
output_inc(1) = mean;
output_inc(2) = sqrt(mean_sq - mean^2);

%%%%%%%posterior mean%%%%%%%
   function p = post_mean(k)
   func1 = @(x) (nchoosek(n,k).*(theta_x(x)).^k.*(1-theta_x(x)).^(n-k)).*pdf_x(x).*x;  
   func2 = @(x) (nchoosek(n,k).*(theta_x(x)).^k.*(1-theta_x(x)).^(n-k)).*pdf_x(x);  
   p1 = integral(func1,x_l,x_h,'ArrayValued',true);
   p2 = integral(func2,x_l,x_h,'ArrayValued',true);
   p = p1/p2;
   end
%%%%%%%coding function%%%%%%
  function q = theta_x(x1)
      denom = l.^(2/3).*(x_m - x_l) + h.^(2/3).*(x_h - x_m);
      if (x1 <= x_m)
        numer = l.^(2/3).*(x1 - x_l);
      else
        numer = l.^(2/3).*(x_m - x_l) + h.^(2/3).*(x1 - x_m);
      end
      q = (sin(pi/2.*numer/denom))^2;             
  end
%%%%%%%pdf%%%%%%
  function G = pdf_x(x)
        if (x <= x_m)
            G = l;
        else
            G = h;
        end
  end
end

%%%%%%%decreasing prior%%%
function [output_dec] = value_function_d(X,x_l,x_h,x_m,ratio)

%%%%%%%%%%%%%%%%%%%%%%%%%%basic description%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% this function produces the subjective valuation and its
%%% one-standard-deviation bounds when prior distribution is decreasing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%specify "l" and "h" in Eq. 19 of the paper%%%%%%%
l = 1/((x_h - x_m) + ratio*(x_m - x_l));
h = l*ratio;

output_dec = zeros(2,1);

%%%%%%%likelihood function%%%
P_x_k1 = @(k1) nchoosek(n,k1).*(theta_x(X)).^k1.*(1-theta_x(X)).^(n-k1);

%%%%%%%compute valuation and standard deviation (Eqs. 15 and 16 in the
%%%%%%%paper)%%%%%%%
mean = 0;
mean_sq = 0;
for j = 0:n
    mean = mean+P_x_k1(j)*post_mean(j);
    mean_sq = mean_sq + P_x_k1(j)*(post_mean(j))^2; 
end
output_dec(1) = mean;
output_dec(2) = sqrt(mean_sq - mean^2);

%%%%%%%posterior mean%%%%%%%
   function p = post_mean(k)
   func1 = @(x) (nchoosek(n,k).*(theta_x(x)).^k.*(1-theta_x(x)).^(n-k)).*pdf_x(x).*x;  
   func2 = @(x) (nchoosek(n,k).*(theta_x(x)).^k.*(1-theta_x(x)).^(n-k)).*pdf_x(x);  
   p1 = integral(func1,x_l,x_h,'ArrayValued',true);
   p2 = integral(func2,x_l,x_h,'ArrayValued',true);
   p = p1/p2;
   end
%%%%%%%coding function%%%%%%
  function q = theta_x(x1)
      denom = h.^(2/3).*(x_m - x_l) + l.^(2/3).*(x_h - x_m);
      if (x1 <= x_m)
        numer = h.^(2/3).*(x1 - x_l);
      else
        numer = h.^(2/3).*(x_m - x_l) + l.^(2/3).*(x1 - x_m);
      end
      q = (sin(pi/2.*numer/denom))^2;        
  end
%%%%%%%pdf%%%%%%
  function G = pdf_x(x)
        if (x <= x_m)
            G = h;
        else
            G = l;
        end
  end
end

end

