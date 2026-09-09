%Root finding function via Newton's method
%INPUTS:
%   fun: the function we are computing the root of
%   Note that fun(x) should output [f,dfdx], where dfdx is the derivative of f
%   (see test_func01 below for example)
%   x0: initial guess for Newton's method
%   dxtol: termination threshold (stop when interval abs(x_{i+1}-x_i) < dxtol)
%   ftol: termination threshold (stop when abs(f(x_{i}))<ftol
%   max_iter: maximum iteration limit
%   dxmax: threshold for checking for a divide by zero error:
%   terminate when abs(x_{i+1}-x_i) > dxmax, where dxmax is a very large number
%OUTPUTS
%   x: estimate for root of fun
%   exit_flag: an integer indicating whether or not the solver succeeded
function [x, exit_flag, guesses] = newton_solver(fun,x0,dxtol,ftol,max_iter,dxmax)
    count = 0;
    [fval,dfdx] = fun(x0);
    dx = 2*dxtol;
    guesses = [];

    while count<max_iter && abs(fval)>=ftol && abs(dx)>=dxtol
        if abs(dfdx) < 1e-15
            disp("Divide by zero")
            x = x0;
            exit_flag = -1;
            return
        end

        dx = -(fval/dfdx);

        if abs(dx) > dxmax
            x = x0;
            exit_flag = -1;
            return
        end

        count = count+1;
        guesses(count) = x0;
        x0 = x0 + dx;
        [fval,dfdx] = fun(x0);
    end

    x = x0;

    if abs(fval)<ftol || abs(dx)<dxtol
        exit_flag = 1;
        return
    end

    exit_flag = 0;
    disp("Failed: Too many iterations.")
end