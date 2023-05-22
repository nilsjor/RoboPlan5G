clear all, close all, clc % Clean slate

%% Setup
% Load data
% batchInf = readtable('batch-Inf.csv');
batch32 = readtable('batch-32.csv');
batch16 = readtable('batch-16.csv');
batch12 = readtable('batch-12.csv');
batch10 = readtable('batch-10.csv');
batch08 = readtable('batch-8.csv');
batchBL = readtable('batch-baseline.csv');

edges = 2.15:0.05:2.7;

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

% Custom colors (Ericsson)
blue = [0, 130, 240]/255;
orange = [255, 140, 10]/255;
yellow = [250, 210, 45]/255;
purple = [175, 120, 210]/255;
green = [15, 195, 115]/255;
red = [255, 50, 50]/255;
grey = [127, 127, 127]/255;
colors = [blue; orange; green; red; purple; grey];

% Figure size in pts
width = COLUMNWIDTH * K;
height = width * 432/768;
pos = [0, 0, width*0.49, height];

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
ax(1) = subplot(6,1,1);
histogram(batch32.PlanQuality, 10 .^ edges, 'LineWidth', LW, 'FaceColor', blue)
tx(1) = text(ax(1), 0.98, 0.88, 'prbs-max := 32', 'FontSize', TINY*0.9, 'FontName', 'Courier', ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'BackgroundColor', 'none', 'Units', 'normalized');

ax(2) = subplot(6,1,2);
histogram(batch16.PlanQuality, 10 .^ edges, 'LineWidth', LW, 'FaceColor', orange)
tx(2) = text(ax(2), 0.98, 0.88, 'prbs-max := 16', 'FontSize', TINY*0.9, 'FontName', 'Courier', ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'BackgroundColor', 'none', 'Units', 'normalized');

ax(3) = subplot(6,1,3);
histogram(batch12.PlanQuality, 10 .^ edges, 'LineWidth', LW, 'FaceColor', green)
tx(3) = text(ax(3), 0.98, 0.88, 'prbs-max := 12', 'FontSize', TINY*0.9, 'FontName', 'Courier', ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'BackgroundColor', 'none', 'Units', 'normalized');

ax(4) = subplot(6,1,4);
histogram(batch10.PlanQuality, 10 .^ edges, 'LineWidth', LW, 'FaceColor', red)
tx(4) = text(ax(4), 0.985, 0.88, 'prbs-max := 10', 'FontSize', TINY*0.9, 'FontName', 'Courier', ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'BackgroundColor', 'none', 'Units', 'normalized');

ax(5) = subplot(6,1,5);
histogram(batch08.PlanQuality, 10 .^ edges, 'LineWidth', LW, 'FaceColor', purple)
tx(5) = text(ax(5), 0.98, 0.88, 'prbs-max := 8', 'FontSize', TINY*0.9, 'FontName', 'Courier', ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'BackgroundColor', 'none', 'Units', 'normalized');

ax(6) = subplot(6,1,6);
histogram(batchBL.PlanQuality, 10 .^ edges, 'LineWidth', LW, 'FaceColor', grey)

% Configure Axes
N = length(ax);
for i=1:N
    set(ax(i), 'Parent', fig, 'Units', 'normalized', 'NextPlot', 'add', ...
        'XScale', 'log', 'YScale', 'linear', 'LineWidth', LW, ...
        'XGrid', 'off', 'YGrid', 'on', 'XColor', 'k', 'YColor', 'k',...
        'XMinorTick','on','YMinorTick','on', 'Box', 'on', ...
        'FontSize', TINY, 'FontName', FN);
    
    % Add labeling to bottom x-axis
    if i == N
        set(ax(i).XLabel ,'String','Plan quality', 'FontSize', SCRIPTSIZE, 'FontName', FN);
    else
        set(ax(i) ,'XTickLabel', '');
    end
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

% Print Figure to file, using the vector format
exportgraphics(fig, 'Results-Hist-Quality.pdf')
