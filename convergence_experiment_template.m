function convergence_experiment_template()
    % Target root reference using high-precision fzero
    x0_ref = 0.5;
    target_root = fzero(@test_func01, x0_ref);

    % Create instance of input_recorder
    my_recorder = input_recorder();
    f_record = my_recorder.generate_recorder_fun(@test_func01);
    
    num_iter = 500;

    % Solver tolerances
    dxtol = 1e-14;
    ftol = 1e-14;
    max_iter = 200;
    dxmax = 1e10;
    
    % Initial guesses for trials
    x0_list = linspace(x0_ref - 1.5, x0_ref + 1.5, num_iter);
    
    x_current_list = [];
    x_next_list = [];
    index_list = [];
    
    % Data Collection Loop
    for n = 1:num_iter
        x0 = x0_list(n);
        my_recorder.clear_input_list();
        
        
        % Newton:
        %[x_root, exit_flag, guess] = newton_solver(f_record, x0, dxtol, ftol, max_iter, dxmax);
       
        % Secant:
        %[x_root, exit_flag, guess] = secant_solver(f_record, x0-0.1, x0, dxtol, ftol, max_iter, dxmax);
       
        % Bisection:
        [x_root, exit_flag, guess] = bisection_solver(f_record, x0-1, x0+1, dxtol, ftol, max_iter);
      
        % fzero:
        % x_root = fzero(f_record, x0);
        
        input_list = my_recorder.get_input_list();

        
        if length(input_list) >= 2
            x_current_list = [x_current_list, input_list(1:end-1)];
            x_next_list = [x_next_list, input_list(2:end)];
            index_list = [index_list, 1:length(input_list)-1];
        end
    end

    % Calculate raw absolute errors
    e_n = abs(x_current_list - target_root);
    e_n_1 = abs(x_next_list - target_root);

    % --- Step 5: Filter raw data to isolate the asymptotic linear slope ---
    filter_mask = (e_n > 1e-14) & (e_n < 1e-2) & (e_n_1 > 1e-14) & (e_n_1 < 1e-2);
    e_n_filt = e_n(filter_mask);
    e_n_1_filt = e_n_1(filter_mask);

    % --- Step 6: Perform Linear Regression ---
    [p_measured, k_measured] = generate_error_fit(e_n_filt, e_n_1_filt);

    fprintf('Measured Order of Convergence (p): %.4f\n', p_measured);
    fprintf('Measured Error Constant (k): %.4f\n', k_measured);

    % --- Step 7: Plot Results ---
    figure;
    loglog(e_n, e_n_1, 'r.', 'MarkerSize', 4); hold on;
    loglog(e_n_filt, e_n_1_filt, 'b.', 'MarkerSize', 4);

    fit_x = 10.^linspace(-14, -2, 100);
    fit_y = k_measured * (fit_x .^ p_measured);
    loglog(fit_x, fit_y, 'k-', 'LineWidth', 2);

    xlabel('\epsilon_n (-)'); ylabel('\epsilon_{n+1} (-)');
    title(sprintf('Convergence Analysis (p = %.2f, k = %.2f)', p_measured, k_measured));
    legend('Raw Data', 'Filtered Data', 'Fit Line', 'Location', 'northwest');
    xlim([10e-18, 10e2]);    % X-axis from 10^0 to 10^4
    ylim([10e-18, 10e2]);  % Y-axis from 10^-3 to 10^4
    grid on;
end

% Multilinear regression helper function
function [p, k] = generate_error_fit(x_regression, y_regression)
    Y = log(y_regression)';
    X1 = log(x_regression)';
    X2 = ones(length(X1), 1);

    coeff_vec = regress(Y, [X1, X2]);

    p = coeff_vec(1);
    k = exp(coeff_vec(2));
end

% Test function
function [fval, dfdx] = test_func01(x)
    fval = (x.^3)/100 - (x.^2)/8 + 2*x + 6*sin(x/2+6) - 0.7 - exp(x/6);
    dfdx = 3*(x.^2)/100 - 2*x/8 + 2 + (6/2)*cos(x/2+6) - exp(x/6)/6;
end



% 
%% 
%starter code for convergence experiments
function convergence_experiment_template()
%Initial guess near the root we are analyzing convergence behavior
%(you will need to change this depending on the test function and root)
x0_ref = 0.5;
target_root = fzero(@test_func01,x0_ref);
%Create an instance of the input_recorder
my_recorder = input_recorder();
%Use input_recorder to generate a version of the test function
%that records the input after every iteration
%Since test_fun is defined using function keyword
f_record = my_recorder.generate_recorder_fun(@test_func01);
%number of trials we would like to perform
num_iter = 1000;
%solver parameters
dxtol = 1e-12;
ftol = 1e-12;
max_iter = 200;
dxmax = 1e10;
%list for the initial guesses that we would like
%to use each trial. These guesses have all been chosen
%so that each trial will converge to the same root
x0_list = linspace(x0_ref-2,x0_ref+2,num_iter);
%list of estimate at current iteration (x_{n})
%compiled across all trials
x_current_list = [];
%list of estimate at next iteration (x_{n+1})
%compiled across all trials
x_next_list = [];
%keeps track of which iteration (n) in a trial
%each data point was collected from
index_list = [];
%loop through each trial
for n = 1:num_iter
%pull out the left and right guess for the trial
x0 = x0_list(n);
%reset input_list for the next test
my_recorder.clear_input_list();
%Call your root finder using the recording function
%you will need to change this, depending on the solver
x_root = newton_solver(f_record,x0,dxtol,ftol,max_iter,dxmax);
%See what input values were used when f_record was called:
input_list = my_recorder.get_input_list();
%at this point, input_list will be populated with the values that
%the solver called at each iteration.
%In other words, it is now [x_1,x_2,...x_n-1,x_n]
%append the collected data to the compilation
x_current_list = [x_current_list,input_list(1:end-1)];
x_next_list = [x_next_list,input_list(2:end)];
index_list = [index_list,1:length(input_list)-1];
end
%At this point, x_current_list corresponds to many many
%measurements of x_{n} across many trials
%and x_next_list corresponds to many many measurements of
%the corresponding value of x_{n+1} across many trials
%this is the data the you want to clean and analaze
%compute the absolute value of the error for current/next iteration
abs_error_current = abs(x_current_list-target_root);
abs_error_next = abs(x_next_list-target_root);
%generate a loglog plot
loglog(abs_error_current,abs_error_next,...
'ro','markerfacecolor','r','markersize',2);
xlabel('\epsilon_n (-)'); ylabel('\epsilon_{n+1} (-)');
title('Error Convergence Plot for Solver');
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