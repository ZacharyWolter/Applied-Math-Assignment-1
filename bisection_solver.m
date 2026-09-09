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
function [x, exit_flag, guesses] = bisection_solver(fun,x_left,x_right,dxtol,ftol,max_iter)
    guesses = [];
    for i = 0:max_iter
        x = (x_left+x_right)/2;
        value = fun(x);
        if abs(value)<ftol || (x_right - x_left) < dxtol
            exit_flag = 1;
            return
        elseif sign(value) ~= sign(fun(x_left))
            guesses(end+1) = x_right;
            x_right = x;
        elseif sign(value) ~= sign(fun(x_right))
            guesses(end+1) = x_left;
            x_left = x;
        else
            disp("Failed: Bad starting points.")
            exit_flag = -1;
            return
        end

    end
    exit_flag = 0;
    disp("Failed: Too many iterations.")
end


