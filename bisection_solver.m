%Root finding function via bisection algorithm
%INPUTS:
%   fun: the function we are computing the root of
%   x_left: left guess
%   x_right: right guess
%   note that f(x_left) and f(x_right) should have different signs
%   dxtol: termination threshold (stop when interval x_right-x_left < dxtol)
%   ftol: termination threshold (stop when abs(f(x_guess))<ftol
%   max_iter: maximum iteration limit
%OUTPUTS
%   x: estimate for root of fun
%   exit_flag: an integer indicating whether or not the solver succeeded
function [x, exit_flag] = bisection_solver(fun,x_left,x_right,dxtol,ftol,max_iter)
    x = (x_left + x_right)/2;
    f_mid = fun(x);
    exit_flag = 0;

    if fun(x_left) * fun(x_right) > 0 % exit if bad initial guess
        exit_flag = 1;
        fprintf('ERROR: Initial guess does not include zero-crossing')
        return;
    end
    
    for i=1:max_iter
        if fun(x_left) * f_mid < 0
            x_right = x;
        else
            x_left = x;
        end
        x = (x_left + x_right) / 2;
        f_mid = fun(x); 
        
        if abs(f_mid) < ftol
            fprintf('Termination Threshold Reached: f(x_mid) sufficiently close to 0')
            return;
        end

        if x_right-x_left < dxtol
            fprintf('Termination Threshold Reached: x-interval sufficiently close to 0')
            return;
        end
    end
end