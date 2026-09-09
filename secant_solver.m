%Root finding function via secant method
%INPUTS:
%   fun: the function we are computing the root of
%   x0: first guess for secant method
%   x1: second guess for secant method
%   dxtol: termination threshold (stop when interval abs(x_{i+1}-x_i) < dxtol)
%   ftol: termination threshold (stop when abs(f(x_{i}))<ftol
%   max_iter: maximum iteration limit
%   dxmax: threshold for checking for a divide by zero error:
%   terminate when abs(x_{i+1}-x_i) > dxmax, where dxmax is a very large number
%OUTPUTS
%   x: estimate for root of fun
%   exit_flag: an integer indicating whether or not the solver succeeded
function [x, exit_flag, guesses] = secant_solver(fun, x0, x1, dxtol, ftol, max_iter, dxmax)
    f0 = fun(x0);
    f1 = fun(x1);
    guesses = [x0, x1];

    if abs(f0) < ftol
        x = x0;
        exit_flag = 1;
        return;
    elseif abs(f1) < ftol
        x = x1;
        exit_flag = 1;
        return;
    end

    for i = 1:max_iter
        if abs(f1 - f0) < 1e-15
            x = x1;
            exit_flag = -1;
            return;
        end

        x2 = x1 - f1 * ((x1 - x0) / (f1 - f0));

        if abs(x2 - x1) > dxmax
            x = x1;
            exit_flag = -1;
            return;
        end

        f2 = fun(x2);
        guesses(end+1) = x2;

        if abs(f2) < ftol || abs(x2 - x1) < dxtol
            x = x2;
            exit_flag = 1;
            return;
        end

        x0 = x1; f0 = f1;
        x1 = x2; f1 = f2;
    end
    x = x1;
    exit_flag = 0;
end