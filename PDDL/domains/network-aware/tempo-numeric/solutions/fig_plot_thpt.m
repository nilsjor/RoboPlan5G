clear all, close all, clc % Clean slate

%% Setup
% Load data
load('tn-207-thpt.mat')

% Design scalars
COLUMNWIDTH = 252;  % width of page in pts
K = 4;              % scaling factor to apply to all measurements

% FontSize (10pt)
TINY = 5 * K;
SCRIPTSIZE = 7 * K;
FOOTNOTESIZE = 8 * K;
SMALL = 9 * K;
NORMALSIZE = 10 * K;
LARGE = 12 * K;

FN = 'Times'; %FontName
LW = 0.25 * K; %LineWidth

% Custom colors (B/W)
red = [255, 50, 50]/255;

% Figure size in pts
width = COLUMNWIDTH * K;
height = width * 432/768 / 2;
pos = [0, 0, width, height];

%% Create Figure

% Screen placement
set(groot,'Units','points')
scrn = get(groot,'ScreenSize') - pos;
pos(1:2) = scrn(3:4)/2;

% Sanity check
if any(scrn(3:4) < 0), error('Scaling factor K is too large for the screen.'); end

% Create Figure
fig = figure('Units','points','Position',pos);

%% Add data
ax(1) = subplot(4,1,1);
st(1) = stairs(x(1,:), y(1,:), 'LineWidth', LW*3, 'Color', red);
% leg = legend('Robot 1', 'Location', 'northeast', 'Fontname', FN, 'FontSize', FS/4*3);

ax(2) = subplot(4,1,2);
st(2) = stairs(x(2,:), y(2,:), 'LineWidth', LW*3, 'Color', red);
% leg = legend('Robot 2', 'Location', 'northeast', 'Fontname', FN, 'FontSize', FS/4*3);

ax(3) = subplot(4,1,3);
st(3) = stairs(x(3,:), y(3,:), 'LineWidth', LW*3, 'Color', red);
% leg = legend('Robot 3', 'Location', 'northeast', 'Fontname', FN, 'FontSize', FS/4*3);

ax(4) = subplot(4,1,4);
st(4) = stairs(x(4,:), y(4,:), 'LineWidth', LW*3, 'Color', red);
% leg = legend('Robot 4', 'Location', 'northeast', 'Fontname', FN, 'FontSize', FS/4*3, 'AutoUpdate', 'off');

% Configure Axes
N = length(ax);
for i=1:N
    set(ax(i), 'Parent', fig, 'Units', 'normalized', 'NextPlot', 'add', ...
        'XScale', 'linear', 'YScale', 'linear', 'LineWidth', LW, ...
        'XGrid', 'off', 'YGrid', 'off', 'XColor', 'k', 'YColor', 'k',...
        'XMinorTick','off','YMinorTick','off', 'Box', 'off', ...
        'FontSize', TINY, 'FontName', FN);
    
    set(ax(i), 'XLim', [0,300], 'YLim', [500,1000]);
    
    % Add labeling to bottom x-axis
    if i == N
        xlabel('Simulation time (sec)', 'FontSize', SCRIPTSIZE, 'FontName', FN);
        ylab = ylabel('Throughput (kbps)', 'FontSize', SCRIPTSIZE, 'FontName', FN, ...
            'Parent', ax(i), 'Units', 'normalized');
    else
        set(ax(i) ,'XTickLabel', '');
    end
    
    drawnow;
    
    text(ax(i), x(i,sum(isnan(y(i,:)))+1), y(i,sum(isnan(y(i,:)))+1), sprintf(' Robot %d',i), 'FontSize', TINY, 'FontName', FN, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'BackgroundColor', 'none');
   
    line(ax(i), [0,300], [640,640], 'LineWidth', 2*LW, 'Color', 'k', 'LineStyle', '--');

end

%% Resize Axes to fill Figure, export result

% [left bottom right top]
t = get(ax,'TightInset');
% [left bottom width height]
p = get(ax,'Position');

if iscell(t)
    t = cell2mat(t);
    p = cell2mat(p);
end

% All Axes have the same 'left', and 'width'
left = max(t(:,1));
width = 1 - max(t(:,1)) - max(t(:,3));

% Their height is distributed equally
total_height = 1 - sum(t(:,2)) - sum(t(:,4));
height = total_height / N;

% Finally, we determine their 'bottom' position dynamically
bottom = zeros(N,1);
for i=N:-1:1
    if i==N
        bottom(i) = t(i,2);
    else
        bottom(i) = bottom(i+1) + height + t(i+1,4) + t(i,2);
    end
    set(ax(i),'Position',[left, bottom(i), width, height])
end

drawnow
% Super cheeky stuff
ylab.Position(2) = 2.5;

% Print Figure to file, using the vector format
exportgraphics(fig, 'Results-Plot-Throughput.pdf')
