function nll = abs_dec_v2(alpha,beta,gamma,sigma,wealth,R_A_choice,control,safe_choice)
    value = alpha + beta.*wealth + control*gamma' - R_A_choice;
    prob = normcdf(value,0,sigma).*safe_choice + ...
        normcdf(-value,0,sigma).*(1-safe_choice);
    nll = (-1).*sum(log(prob));