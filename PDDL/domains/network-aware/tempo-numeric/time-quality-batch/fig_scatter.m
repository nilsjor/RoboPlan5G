clear all, close all, clc % Clean slate

% Load data
% batchInf = readtable('batch-Inf.csv');
batch32 = readtable('batch-32.csv');
batch16 = readtable('batch-16.csv');
batch12 = readtable('batch-12.csv');
batch10 = readtable('batch-10.csv');
batch08 = readtable('batch-8.csv');
batchBL = readtable('batch-baseline.csv');

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
MS = 4 * K;   %MarkerSize

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
pos = [0, 0, width, height];

% Screen placement
set(groot,'Units','points')
scrn = get(groot,'ScreenSize') - pos;
pos(1:2) = scrn(3:4)/2;

% Create Figure
fig = figure('Units','points','Position',pos);

% Add Axes
ax = axes('Parent',fig, 'Units', 'normalized', 'NextPlot', 'add', ...
    'XScale', 'log', 'YScale', 'log', 'LineWidth', LW, ...
    'XGrid', 'on', 'YGrid', 'on', 'XColor', 'k', 'YColor', 'k',...
    'XMinorTick','on','YMinorTick','on', 'Box', 'on', ...
    'FontSize', TINY, 'FontName', FN);

% Set axis labels
set(ax.XLabel ,'String','Search time (sec)', 'FontSize', SCRIPTSIZE, 'FontName', FN);
set(ax.YLabel ,'String','Plan quality', 'FontSize', SCRIPTSIZE, 'FontName', FN);

% Add Lines
ln(1) = plot(batch32.TotalTime, batch32.PlanQuality, '.', 'LineWidth', 2*LW, 'MarkerSize', MS/4*3);
ln(2) = plot(batch16.TotalTime, batch16.PlanQuality, '+', 'LineWidth', 2*LW, 'MarkerSize', MS);
ln(3) = plot(batch12.TotalTime, batch12.PlanQuality, 'o', 'LineWidth', 2*LW, 'MarkerSize', MS/4*3);
ln(4) = plot(batch10.TotalTime, batch10.PlanQuality, 'x', 'LineWidth', 2*LW, 'MarkerSize', MS);
ln(5) = plot(batch08.TotalTime, batch08.PlanQuality, '^', 'LineWidth', 2*LW, 'MarkerSize', MS/4*3);
drawnow
set(ax, 'XLimMode', 'manual', 'YLimMode', 'manual');
ln(6) = plot(batchBL.SearchTime, batchBL.PlanQuality, 'v', 'LineWidth', 2*LW, 'MarkerSize', MS/4*3);

% Add Legend
leg = legend('Parent',fig,...
    'String',{'prbs-max := 32','prbs-max := 16','prbs-max := 12','prbs-max := 10','prbs-max := 8'}, ...
    'NumColumns', 2, 'Location', 'northeast', 'Fontname', 'Courier', 'FontSize', TINY);

% Update color scheme
set(ax, 'ColorOrder', colors)

% Resize Axes to fill Figure
p = get(ax,'TightInset'); % Read only!
set(ax,'Position',[p(1),p(2),1-p(1)-p(3),1-p(2)-p(4)]);

% Print Figure to file, using the vector format
exportgraphics(fig, 'Results-Scatter-Time-Quality.pdf')
