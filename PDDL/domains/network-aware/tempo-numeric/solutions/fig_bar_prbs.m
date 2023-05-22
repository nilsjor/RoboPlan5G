clear all, close all, clc % Clean slate

%% Setup
% Load data
load('tn-207-prbs.mat')
Y = fliplr(Y);

% Design scalars
COLUMNWIDTH = 252;  % width of page in pts
K = 2;              % scaling factor to apply to all measurements

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
colors = (0:0.25:1).' .* [1,1,1];

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
ax = axes;
bar(Y,'stacked', 'LineWidth', LW)

% Update color scheme
set(ax, 'ColorOrder', colors)

% Configure Axes
N = length(ax);
for i=1:N
    set(ax(i), 'Parent', fig, 'Units', 'normalized', 'NextPlot', 'add', ...
        'XScale', 'linear', 'YScale', 'linear', 'LineWidth', LW, ...
        'XGrid', 'off', 'YGrid', 'off', 'XColor', 'k', 'YColor', 'k',...
        'XMinorTick','off','YMinorTick','off', 'Box', 'off', ...
        'FontSize', TINY, 'FontName', FN);
    
    set(ax(i).YLabel ,'String','No. of PRBs assigned', 'FontSize', SCRIPTSIZE, 'FontName', FN);
    
    % Add labeling to bottom x-axis
    set(ax(i).XLabel ,'String','Planned sequence of MOVE actions', 'FontSize', SCRIPTSIZE, 'FontName', FN);
    set(ax(i) ,'XTickLabel', '');
end

set(ax, 'YTick', 0:8:32);

% Add Legend
leg = legend('Parent',fig,...
    'String',{'Robot 1','Robot 2','Robot 3','Robot 4','Unassigned'}, ...
    'NumColumns', 5, 'Location', 'north', 'Fontname', FN, 'FontSize', TINY);

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

% Print Figure to file, using the vector format
exportgraphics(fig, 'Results-BarStacked-PRB.pdf')
