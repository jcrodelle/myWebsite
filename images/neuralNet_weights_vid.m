% Dynamic Hub-and-Spoke Network (Full Plot Capture)
numOuterNodes = 8;
numFrames = 150;
totalNodes = numOuterNodes + 1;

sourceNodes = ones(1, numOuterNodes);
targetNodes = 2:totalNodes;
G = graph(sourceNodes, targetNodes);

theta = linspace(0, 2*pi, numOuterNodes + 1);
xCoords = [0, cos(theta(1:end-1))];
yCoords = [0, sin(theta(1:end-1))];

% 1. Create Figure with explicit pixel units (prevents High-DPI cropping)
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 500, 500], ...
             'MenuBar', 'none', 'ToolBar', 'none', 'Resize', 'off');

% 2. Center plot with a 5% margin so outer node circles aren't cut off
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.9]);

hPlot = plot(ax, G, 'XData', xCoords, 'YData', yCoords, ...
    'NodeColor', '#0284c7', ...
    'MarkerSize', [14, 8*ones(1, numOuterNodes)], ...
    'LineWidth', 2, ...
    'EdgeColor', '#0284c7');

axis(ax, 'equal', 'off');

% 3. Set Up MP4 Video Writer
videoFilename = 'synaptic_weights.mp4';
v = VideoWriter(videoFilename, 'MPEG-4');
v.FrameRate = 30;
v.Quality = 100;
open(v);

t = linspace(0, 4*pi, numFrames);
phaseShifts = linspace(0, 2*pi, numOuterNodes);
frequencies = [1.2, 0.8, 1.5, 0.5, 1.0, 1.8, 0.7, 1.3];

% 4. Render & Capture Loop
for k = 1:numFrames
    currentWeights = 3.5 + 3.0 * sin(frequencies * t(k) + phaseShifts);
    hPlot.LineWidth = currentWeights;
    
    drawnow;
    
    % Capture full figure frame
    frame = getframe(fig);
    img = frame.cdata;
    
    % Force even pixel dimensions for H.264 codec
    if mod(size(img, 1), 2) ~= 0, img = img(1:end-1, :, :); end
    if mod(size(img, 2), 2) ~= 0, img = img(:, 1:end-1, :); end
    
    writeVideo(v, img);
end

close(v);
close(fig);

disp(['Full plot video saved cleanly as ', videoFilename]);