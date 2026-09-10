function convergence_experiment_template()
    % Target root reference
    x0_ref = 0.5;
    target_root = fzero(@test_func01, x0_ref);

    % Create instance of input_recorder
    my_recorder = input_recorder();
    f_record = my_recorder.generate_recorder_fun(@test_func01);

    num_iter = 500;
    solver_flag = 1;

    % Solver tolerances
    dxtol = 1e-14;
    ftol = 1e-14;
    max_iter = 200;
    dxmax = 1e10;

    % Initial guesses for trials
    x0_list = linspace(x0_ref - 1.5, x0_ref + 1.5, num_iter);
    x_left_list = linspace(target_root - 1.5, target_root - 0.05, num_iter);
    x_right_list = linspace(target_root + 0.05, target_root + 1.5, num_iter);

    x_current_list = [];
    x_next_list = [];
    index_list = [];

    % Data collection
    for n = 1:num_iter
        x0 = x0_list(n);
        my_recorder.clear_input_list();

        if solver_flag == 1
            [x_root, exit_flag, guess] = bisection_solver(@test_func01, x_left_list(n), x_right_list(n), dxtol, ftol, max_iter);

            if exit_flag == 1 && length(guess) >= 2
                x_current_list = [x_current_list, guess(1:end-1)];
                x_next_list = [x_next_list, guess(2:end)];
                index_list = [index_list, 1:length(guess)-1];
            end
        elseif solver_flag == 2
            [x_root, exit_flag, guess] = newton_solver(f_record, x0, dxtol, ftol, max_iter, dxmax);

            input_list = my_recorder.get_input_list();

            if exit_flag == 1 && length(input_list) >= 2
                x_current_list = [x_current_list, input_list(1:end-1)];
                x_next_list = [x_next_list, input_list(2:end)];
                index_list = [index_list, 1:length(input_list)-1];
            end
        elseif solver_flag == 3
            [x_root, exit_flag, guess] = secant_solver(f_record, x0-0.1, x0, dxtol, ftol, max_iter, dxmax);

            input_list = my_recorder.get_input_list();

            if exit_flag == 1 && length(input_list) >= 2
                x_current_list = [x_current_list, input_list(1:end-1)];
                x_next_list = [x_next_list, input_list(2:end)];
                index_list = [index_list, 1:length(input_list)-1];
            end
        elseif solver_flag == 4
            [x_root, fval, exit_flag] = fzero(f_record, x0);

            input_list = my_recorder.get_input_list();

            if exit_flag > 0 && length(input_list) >= 2
                x_current_list = [x_current_list, input_list(1:end-1)];
                x_next_list = [x_next_list, input_list(2:end)];
                index_list = [index_list, 1:length(input_list)-1];
            end
        end
    end

    % Calculate raw error
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

    % Plot
    figure;
    loglog(e_n, e_n_1, 'r.', 'MarkerSize', 4); hold on;
    loglog(e_n_filt, e_n_1_filt, 'b.', 'MarkerSize', 4);

    fit_x = 10.^linspace(-14, -2, 100);
    fit_y = k_measured * (fit_x .^ p_measured);
    loglog(fit_x, fit_y, 'k-', 'LineWidth', 2);
    xlabel('\epsilon_n (-)'); ylabel('\epsilon_{n+1} (-)');
    title(sprintf('Convergence Analysis (p = %.2f, k = %.2f)', p_measured, k_measured));
    legend('Raw Data', 'Filtered Data', 'Fit Line', 'Location', 'northwest');
    xlim([10e-18, 10e2]);
    ylim([10e-18, 10e2]);
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