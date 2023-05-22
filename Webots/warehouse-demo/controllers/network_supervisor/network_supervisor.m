function network_supervisor(varargin)

% Process name
if ~nargin, error("Argument 'name' not provided!"); end
NAME = varargin{1};

% Time (in seconds)
TIME_SCALING = 8;
time_step_sec = wb_robot_get_basic_time_step() * 1e-3;

% Load PDDL-plan
PLAN_PATH = '..\\..\\..\\..\\PDDL\\domains\\network-aware\\tempo-numeric\\solutions\\tn-207.plan';
plan = readtable([PLAN_PATH, '.csv']);
plan_sorted = sortrows(plan);
plan_singleagent = plan_sorted(contains(plan_sorted{:,2}, NAME),:);

% Planning horizon (N), agent count (M)
N = height(plan_singleagent);
M = 4; 

% Look-up tables for PRB-assignment
I = eye(M);
incr = @(i) I(:,i);

% Look-up table for throughput
load data_rate
grid_kbps = @(grid) Z(grid(1)-64, grid(2)-48);

% Pre-allocate vectors
PRB_MAX = 32;
prbs = [8; 8; 5; 2];
prbs_vec = [prbs; PRB_MAX - sum(prbs)];
prbs_t_vec = zeros(1,1);

data_vec = nan(M,1);
data_t_vec = nan(1,1);

set(groot,'Units','pixels')
scrn = get(groot,'ScreenSize') - pos;
pos(1:2) = scrn(3:4)/2;
figure('Units','pixels','Position', [])

% Iterate through each plan step
for k = 1:N

    % Load plan step
    plan_step = plan_singleagent(k,:);

    % Extract action
    action = char(plan_step{1,2});
    action_split = split(action);

    % Action times (expressed in wall-time)
    action_start = plan_step.Time * TIME_SCALING;
    action_duration = plan_step.Duration * TIME_SCALING;
    action_end = action_start + action_duration;

    % Skip expired step (for re-launches)
    if wb_robot_get_time > action_end, continue; end

    % Wait the sufficient multiples of 'time_step_sec' until execution
    if wb_robot_get_time < action_start

        % Calculate the multiples of 'time-step' until next event (in seconds)
        time_until_exec = time_step_sec * ceil((action_start - wb_robot_get_time) / time_step_sec);

        % Wait the given time (in milliseconds)
        if wb_robot_step(time_until_exec * 1e3) == -1, return; end
    end

    % Get the index of the current robot
    robot = str2double(action_split{2}(end));

    %% Execute action
    fprintf('%.1f %s\n', plan_step.Time, action);
    switch action_split{1}
        case 'PICK'

        case 'DROP'

        case 'MOVE'        
            % Get transmission characteristics
            from_kbps = grid_kbps(action_split{3});
            to_kbps = grid_kbps(action_split{4});

            % Update vectors (apply saturation at 1 Mbps)
            data_t_vec(:,end+1) = wb_robot_get_time;
            data_vec(:,end+1) = data_vec(:,end);
            data_vec(robot,end) = min(1000, min(to_kbps, from_kbps) * prbs(robot) );

            % Update graphics partially
            subplot(3,1,1)
            stairs(data_t_vec.', data_vec.');
            title('Throughput (kbps)');

            % Update PRB vector
            prbs_t_vec(:,end+1) = wb_robot_get_time;
            prbs_vec(:,end+1) = prbs_vec(:,end);
            prbs_vec(robot,end) = prbs(robot);
            prbs_vec(end,end) = PRB_MAX - sum(prbs_vec(1:M,end));

            % Refresh all graphics
            subplot(3,1,2)
            stairs(prbs_t_vec.', prbs_vec.');
            title('Assigned PRBs');

            % Refresh all graphics
            subplot(3,1,3)
            bar(prbs_vec.', 'stacked');
            title('Total distribution of PRBs');
            legend({'Robot 1','Robot 2','Robot 3','Robot 4','Unassigned'}, 'Orientation', 'horizontal')
            drawnow;

            % Reset PRBs
            prbs(robot) = 0;

        case 'ASSIGN-PRB'
            % fprintf('%s: Exec %s\n', NAME, action);
            prbs = prbs + incr(robot);

        case 'FREE-PRB'
            % fprintf('%s: Exec %s\n', NAME, action);
            prbs = prbs - incr(robot);

        otherwise
            fprintf('Unknown action: %s', action_split{1});
    end

end

savefig([PLAN_PATH, '.fig']);
