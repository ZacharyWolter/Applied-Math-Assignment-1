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
    f_left = fun(x_left);
    f_right = fun(x_right);

    if abs(f_left) < ftol
        x = x_left;
        exit_flag = 1;
        return
    elseif abs(f_right) < ftol
        x = x_right;
        exit_flag = 1;
        return
    elseif sign(f_left) == sign(f_right)
        x = (x_left+x_right)/2;
        disp("Failed: Bad starting points.")
        exit_flag = -1;
        return
    end

    x = (x_left+x_right)/2;

    for i = 1:max_iter
        x = (x_left+x_right)/2;
        value = fun(x);
        if abs(value)<ftol || abs(x_right - x_left) < dxtol
            exit_flag = 1;
            return
        elseif sign(value) ~= sign(f_left)
            guesses(end+1) = x_right;
            x_right = x;
            f_right = value;
        elseif sign(value) ~= sign(f_right)
            guesses(end+1) = x_left;
            x_left = x;
            f_left = value;
        else
            disp("Failed: Bad starting points.")
            exit_flag = -1;
            return
        end

    end
    exit_flag = 0;
    disp("Failed: Too many iterations.")
end