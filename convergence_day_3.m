function convergence_day_3()
    close all 
    % Target root reference
    x0_ref = 26;
    target_root = fzero(@test_func03, x0_ref);

    % Create instance of input_recorder
    my_recorder = input_recorder();
    f_record = my_recorder.generate_recorder_fun(@test_func03);

    num_iter = 50;
    solver_flag = 2;

    % Solver tolerances
    dxtol = 1e-14;
    ftol = 1e-14;
    max_iter = 200;
    dxmax = 1e10;
    x_range = 20;

    % Initial guesses for trials
    x0_list = linspace(x0_ref - x_range, x0_ref + x_range, num_iter);
    x1_list = linspace(x0_ref - x_range+1, x0_ref + x_range+1, num_iter);

    x_left_list = linspace(target_root - x_range + 1, target_root + x_range + 1, num_iter);
    x_right_list = linspace(target_root - x_range, target_root + x_range, num_iter);

    [x_left, x_right] = meshgrid(x_left_list, x_right_list);
    [x0, x1] = meshgrid(x0_list, x1_list);

    x_current_list = [];
    x_next_list = [];
    index_list = [];
    x_left_fail = [];
    x_right_fail = [];
    x0_fail = [];
    x1_fail = [];
    x_left_success = [];
    x_right_success = [];
    x0_success = [];
    x1_success = [];
    y0_success = [];
    y0_fail = [];

    % Data collection
    for n = 1:num_iter^2
        if solver_flag == 1
            [~, exit_flag, guess] = bisection_solver(@test_func03, x_left(n), x_right(n), dxtol, ftol, max_iter);

            if exit_flag == 1 && length(guess) >= 2
                x_left_success(end+1) = x_left(n);
                x_right_success(end+1) = x_right(n);
           
            elseif exit_flag == 0 || exit_flag == -1
                x_left_fail(end+1) = x_left(n);
                x_right_fail(end+1) = x_right(n);
            end      
        elseif solver_flag == 2
            my_recorder.clear_input_list();
            [~, exit_flag, ~] = newton_solver( ...
                f_record, x0(n), dxtol, ftol, max_iter, dxmax);
        
            input_list = my_recorder.get_input_list();

            if exit_flag == 1 && length(input_list) >= 2
                x0_success(end+1) = x0(n);
                y0_success(end+1) = test_func03(x0(n));
                x_current_list = [x_current_list, input_list(1:end-1)];
                x_next_list = [x_next_list, input_list(2:end)];
                index_list = [index_list, 1:length(input_list)-1];
            else
                x0_fail(end+1) = x0(n);
                y0_fail(end+1) = test_func03(x0(n));
            end
        elseif solver_flag == 3
            my_recorder.clear_input_list();
            [~, exit_flag, ~] = secant_solver(f_record, x0(n), x1(n), dxtol, ftol, max_iter, dxmax);

            input_list = my_recorder.get_input_list();

            if exit_flag == 1 && length(input_list) >= 2
                 x0_success(end+1) = x0(n);
                x1_success(end+1) = x1(n);
                x_current_list = [x_current_list, input_list(1:end-1)];
                x_next_list = [x_next_list, input_list(2:end)];
                index_list = [index_list, 1:length(input_list)-1];
            elseif exit_flag == 0 || exit_flag == -1
                x0_fail(end+1) = x0(n);
                x1_fail(end+1) = x1(n);
            end
        elseif solver_flag == 4
            my_recorder.clear_input_list();
            [~, ~, exit_flag] = fzero(f_record, x0(n));
            input_list = my_recorder.get_input_list();
            if exit_flag == 1 && length(input_list) >= 2
                x0_success(end+1) = x0(n);
                y0_success(end+1) = test_func03(x0(n));
                x_current_list = [x_current_list, input_list(1:end-1)];
                x_next_list = [x_next_list, input_list(2:end)];
                index_list = [index_list, 1:length(input_list)-1];
            else
                x0_fail(end+1) = x0(n);
                y0_fail(end+1) = test_func03(x0(n));
            end
        end
    end

    figure;
    if solver_flag == 1
        plot(x_left_fail, x_right_fail, 'ro','markerfacecolor','r'); hold on
        plot(x_left_success, x_right_success, 'bo','MarkerFaceColor','b');
        xlabel('Left Guess');
        ylabel('Right Guess');
        title('Bisection Solver');
        legend('Failed', 'Converged');
    elseif solver_flag == 2
        plot(x0_success, y0_success, 'bo', 'MarkerFaceColor', 'b'); hold on
        plot(x0_fail, y0_fail, 'ro','markerfacecolor','r');
        xlabel('Initial Guess');
        ylabel('Next Guess');
        title('Newton Solver');
        legend('Newton');
    elseif solver_flag == 3
        plot(x0_fail, x1_fail, 'ro','markerfacecolor','r'); hold on
        plot(x0_success, x1_success, 'bo','MarkerFaceColor','b');
        xlabel('First Guess');
        ylabel('Second Guess');
        title('Secant Solver');
        legend('Failed', 'Converged');
    elseif solver_flag == 4
        plot(x0_success, y0_success, 'bo', 'MarkerFaceColor', 'b'); hold on
        plot(x0_fail, y0_fail, 'ro','markerfacecolor','r');
        xlabel('Current Guess');
        ylabel('Next Guess');
        title('fzero Solver');
        legend('fzero');
    end

    % Calculate raw error using sequence history
    e_n = abs(x_current_list - target_root);
    e_n_1 = abs(x_next_list - target_root);

    if solver_flag == 3
        index_min = 3;
    else
        index_min = 2;
    end

    filter_mask = (e_n > 1e-14) & (e_n < 1e-2) & ...
        (e_n_1 > 1e-14) & (e_n_1 < 1e-2) & ...
        (index_list > index_min);

    e_n_filt = e_n(filter_mask);
    e_n_1_filt = e_n_1(filter_mask);

    % Linear regression
    [p_measured, k_measured] = generate_error_fit(e_n_filt, e_n_1_filt);

    fprintf('Measured Order of Convergence (p): %.4f\n', p_measured);
    fprintf('Measured Error Constant (k): %.4f\n', k_measured);
end

%Example sigmoid function
function [f_val,dfdx] = test_func03(x)
a = 27.3; b = 2; c = 8.3; d =-3;
H = exp((x-a)/b);
dH = H/b;
L = 1+H;
dL = dH;
f_val = c*H./L+d;
dfdx = c*(L.*dH-H.*dL)./(L.^2);
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