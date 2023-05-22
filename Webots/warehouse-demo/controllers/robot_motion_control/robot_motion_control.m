function robot_motion_control(varargin)

% Process name
if ~nargin, error("Argument 'name' not provided!"); end
NAME = varargin{1};

% Time (in seconds)
TIME_SCALING = 8;
time_step_sec = wb_robot_get_basic_time_step * 1e-3;

% Load PDDL-plan
PLAN_PATH = '..\\..\\..\\..\\PDDL\\domains\\network-aware\\tempo-numeric\\solutions\\tn-207.plan';
plan = readtable([PLAN_PATH, '.csv']);
plan_sorted = sortrows(plan);
plan_singleagent = plan_sorted(contains(plan_sorted{:,2}, NAME),:);

% Planning horizon (N), agent count (M)
N = height(plan_singleagent);
M = 4; 

% Constants
ANGLE_TOL = 1e-1;
WHEEL_RADIUS = 0.0625;
DISTANCE_TO_CENTER = 0.2226;

% Motor handles
motor_left_wheel = wb_robot_get_device('middle_left_wheel_joint');
motor_right_wheel = wb_robot_get_device('middle_right_wheel_joint');

% Wheels in velocity control, so position must be set to infinity.
wb_motor_set_position(motor_left_wheel, Inf);
wb_motor_set_position(motor_right_wheel, Inf);
wb_motor_set_velocity(motor_left_wheel, 0.0);
wb_motor_set_velocity(motor_right_wheel, 0.0);


% Convert a grid, e.g. "C5" to a xy-vector, i.e. (9,6)
grid2sim = @(c) diag([2,-2])*(fliplr(char(c)) - [char(48), char(64)]).' + [-1; 12];

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
    
    %% Execute action
    switch action_split{1}
        case 'PICK'
            
        case 'DROP'
            
        case 'MOVE'          
            % Target positions
            from = grid2sim(action_split{3});
            to = grid2sim(action_split{4});
            diff_pos = to-from;
            
            % Measure pose
            position = wb_supervisor_node_get_position(wb_supervisor_node_get_self);
            orientation = wb_supervisor_node_get_orientation(wb_supervisor_node_get_self);
            
            % Transformed to 3-DOF
            pos = position(1:2).';
            rot = rotm2eul(orientation);
            
            % Calculate error
            rot_des = -atan2(diff_pos(2), diff_pos(1));
            diff_rot = rot(1)-rot_des; %OBS: Defined in the opposite direction
            
            % Determine modality    
            if abs(diff_rot) < ANGLE_TOL
                % disp('Going forwards')
                target_speed = norm(diff_pos) / (action_end - wb_robot_get_time);
                target_omega = 0.0;

            elseif abs(abs(diff_rot)-pi) < ANGLE_TOL
                % disp('Going backwards')
                target_speed = -norm(diff_pos) / (action_end - wb_robot_get_time);
                target_omega = 0.0;

            elseif diff_rot > pi
                % disp('Turning+going backwards')
                duration_exec = time_step_sec * floor((action_duration/3) / time_step_sec);
                target_speed = 0.0;
                target_omega = (diff_rot-sign(diff_rot)*2*pi) / duration_exec;
                
                %Execute turn
                wb_motor_set_velocity(motor_left_wheel, (target_speed - target_omega * DISTANCE_TO_CENTER) / WHEEL_RADIUS);
                wb_motor_set_velocity(motor_right_wheel, (target_speed + target_omega * DISTANCE_TO_CENTER) / WHEEL_RADIUS);
                if wb_robot_step(duration_exec * 1e3) == -1, return; end
                
                % Fix rotation -- to ensure satisfaction
                wb_supervisor_field_set_sf_rotation(wb_supervisor_node_get_field(...
                    wb_supervisor_node_get_self, 'rotation'), [0,0,1,-rot_des]);
                
                % Then move
                target_speed = norm(diff_pos) / (action_end - wb_robot_get_time);
                target_omega = 0.0;

            else
                % disp('Turning+going forwards')
                duration_exec = time_step_sec * floor((action_duration/3) / time_step_sec);
                target_speed = 0.0;
                target_omega = diff_rot / duration_exec;

                %Execute turn
                wb_motor_set_velocity(motor_left_wheel, (target_speed - target_omega * DISTANCE_TO_CENTER) / WHEEL_RADIUS);
                wb_motor_set_velocity(motor_right_wheel, (target_speed + target_omega * DISTANCE_TO_CENTER) / WHEEL_RADIUS);
                if wb_robot_step(duration_exec * 1e3) == -1, return; end

                % Fix rotation afterwards -- to ensure satisfaction
                wb_supervisor_field_set_sf_rotation(wb_supervisor_node_get_field(...
                    wb_supervisor_node_get_self, 'rotation'), [0,0,1,-rot_des]);
                
                % Then move
                target_speed = norm(diff_pos) / (action_end - wb_robot_get_time);
                target_omega = 0.0;
            end

            % Set motor speed
            wb_motor_set_velocity(motor_left_wheel, (target_speed - target_omega * DISTANCE_TO_CENTER) / WHEEL_RADIUS);
            wb_motor_set_velocity(motor_right_wheel, (target_speed + target_omega * DISTANCE_TO_CENTER) / WHEEL_RADIUS);

            % Execute for the given time (in milliseconds)
            duration_exec = time_step_sec * floor((action_end - wb_robot_get_time) / time_step_sec);
            if wb_robot_step(duration_exec * 1e3) == -1, return; end

            % Then stop
            wb_motor_set_velocity(motor_left_wheel, 0.0);
            wb_motor_set_velocity(motor_right_wheel, 0.0);
            if wb_robot_step(time_step_sec * 1e3) == -1, return; end

            % Teleport after the movement is done -- to ensure satisfaction
            wb_supervisor_field_set_sf_vec3f(wb_supervisor_node_get_field(...
                wb_supervisor_node_get_self, 'translation'), [to.', 0]);
            
        case 'ASSIGN_PRB'
            
        case 'FREE_PRB'
            
        otherwise
            fprintf('Unknown action: %s', action_split{1});
    end

end
