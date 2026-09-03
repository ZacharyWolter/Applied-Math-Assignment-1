%template for testing your basic root finding implementations
function basic_solver_with_tests_template()
    xvals = linspace(-50,50,201);
    [yvals,~] = test_func01(xvals);

    hold on
    axis([-15,40,-50,80]);
    plot(xvals,yvals,'r','linewidth',2);
    plot(xvals,0*xvals,'k--','linewidth',1);
    xlabel('x'); ylabel('y'); title('Test Function 1');
    

    %Secant method example test
    x0_guess = -5;
    x1_guess = 2;
    plot(x0_guess,test_func01(x0_guess),'bo','markerfacecolor','b','markersize',5);
    plot(x1_guess,test_func01(x1_guess),'ko','markerfacecolor','k','markersize',5);

    x_sol = secant_solver(@test_func01,x0_guess,x1_guess);
    plot(x_sol,test_func01(x_sol),'go','markerfacecolor','g','markersize',5);

end


%Definition of the test function and its derivative (as a single function):
%This definition uses the function keyword
%when passing this function as an argument to a solver,
%you'll need to use the handle operator
%ex. solver(@test_func01,x_guess)
function [fval,dfdx] = test_func01(x)
    fval = (x.^3)/100 - (x.^2)/8 + 2*x + 6*sin(x/2+6) -.7 - exp(x/6);
    dfdx = 3*(x.^2)/100 - 2*x/8 + 2 +(6/2)*cos(x/2+6) - exp(x/6)/6;
end


function x = bisection_solver(fun,x_left,x_right)
    x = x_left+1; %this is just dummy code. replace this with your code
end

%Note that fun(x) should output [f,dfdx], where dfdx is the derivative of f
function x = newton_solver(fun,x0)
    x = x0+1; %this is just dummy code. replace this with your code
end

function x = secant_solver(fun, x0, x1)
    x_nminus1 = x1;
    x_nminus2 = x0;

    while true
        [f1, ~] = fun(x_nminus1);
        [f2, ~] = fun(x_nminus2);

        x_n = x_nminus1 - f2 * ((x_nminus1 - x_nminus2)/(f1 - f2))
    
        if (x_nminus1 - x_n) < 1e-4
            x = x_n;
            break
        end

        if (f1 - f2) < 1e-3
            disp('Error: Denominator in update step is zero')
            break
        end

        if abs(x_n - x_nminus1) > 100
            disp('Error: Updated stepsize is huge')
        end
        
        x_nminus2 = x_nminus1;
        x_nminus1 = x_n;
    end
end




