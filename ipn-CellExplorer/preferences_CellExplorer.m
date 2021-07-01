% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% CellExplorer Preferences  
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%
% Preferences loaded by the CellExplorer at startup
% Check the website of the CellExplorer for more details: https://cellexplorer.org/
  
% By Peter Petersen
% petersen.peter@gmail.com
% Last edited: 24-04-2020

% Display preferences - An incomplete list:
% 'Waveforms (single)','Waveforms (all)','Waveforms (image)','Raw waveforms (single)','Raw waveforms (all)','ACGs (single)',
% 'ACGs (all)','ACGs (image)','CCGs (image)','sharpWaveRipple'
UI.preferences.customCellPlotIn{1} = 'Waveforms (single)';
UI.preferences.customCellPlotIn{2} = 'ACGs (single)'; 
UI.preferences.customCellPlotIn{3} = 'RCs_firingRateAcrossTime';
UI.preferences.customCellPlotIn{4} = 'Waveforms (all)';
UI.preferences.customCellPlotIn{5} = 'ACGs (all)';
UI.preferences.customCellPlotIn{6} = 'Connectivity graph';

UI.preferences.acgType = 'Normal';                 % Normal (100ms), Wide (1s), Narrow (30ms), Log10
UI.preferences.acgYaxisLog = 1;
UI.preferences.isiNormalization = 'Occurrence';     % 'Rate', 'Occurrence'
UI.preferences.rainCloudNormalization = 'Peak';    % 'Probability'
UI.preferences.monoSynDispIn = 'Selected';         % 'All', 'Upstream', 'Downstream', 'Up & downstream', 'Selected', 'None'
UI.preferences.metricsTable = 1; 
UI.preferences.metricsTableType = 'Metrics';       % ['Metrics','Cells','None']
UI.preferences.plotCountIn = 'GUI 3+3';            % ['GUI 1+3','GUI 2+3','GUI 3+3','GUI 3+4','GUI 3+5','GUI 3+6']
UI.preferences.dispLegend = 0;                     % [0,1] Display legends in plots?
UI.preferences.plotWaveformMetrics = 0;            % show waveform metrics on the single waveform
UI.preferences.sortingMetric = 'burstIndex_Royer2012'; % metrics used for sorting image data
UI.preferences.markerSize = 15;                    % marker size in the group plots [default: 20]
UI.preferences.logMarkerSize = 0;
UI.preferences.plotInsetChannelMap = 3;            % Show a channel map inset with waveforms.
UI.preferences.plotInsetACG = 0;                   % Show a ACG plot inset with waveforms.
UI.preferences.plotChannelMapAllChannels = true;   % Boolean. Show a select set of channels or all 
UI.preferences.waveformsAcrossChannelsAlignment = 'Probe layout'; % 'Probe layout', 'Electrode groups'
UI.preferences.peakVoltage_all_sorting = 'channelOrder'; % 'channelOrder', 'amplitude', 'none'
UI.preferences.peakVoltage_session = true;         %
UI.preferences.colormap = 'hot';                   % colormap of image plots
UI.preferences.colormapStates = 'lines';           % colormap of states plots
UI.preferences.showAllTraces = 0;                  % Show all traces or a random subset (maxi 2000; faster UI)
UI.preferences.zscoreWaveforms = 1;                % Show zscored or full amplitude waveforms
UI.preferences.trilatGroupData = 'session';        % 'session','animal','all'
UI.preferences.hoverEffect = 1;                    % Highlights cells by hovering the mouse
UI.preferences.plotLinearFits = 0;                 % Linear fit shown in group plot for each cell group
UI.preferences.graph_depth = 4;                    % Allen Institute Brain region atlas depth [1:7]
UI.preferences.hoverTimer = 0.045;                 % A minimum interval timer between each hover call (in seconds. Increase if you have issue with CellExplorer not detecting your mouse clicks on graths)
UI.preferences.binCount = 100;
UI.preferences.customPlotHistograms = 1; 
UI.preferences.plotZLog = 0; 
UI.preferences.plot3axis = 0;
UI.preferences.layout = 3;
UI.preferences.raster = 'cv2';
UI.preferences.displayMenu = 0; 
UI.preferences.stickySelection = false; 
UI.preferences.referenceData = 'None'; 
UI.preferences.groundTruthData = 'None'; 
UI.preferences.channelMapColoring = false;         % Color groups in channel map inset with waveforms

% Autosave preferences
UI.preferences.autoSaveFrequency = 5;              % How often you want to autosave (classifications steps). Put to 0 to turn autosave off
UI.preferences.autoSaveVarName = 'cell_metrics';   % Variable name used in autosave

% Initial data displayed in the customPlot
UI.preferences.plotXdata = 'firingRate';
UI.preferences.plotYdata = 'peakVoltage';
UI.preferences.plotZdata = 'troughToPeak';
UI.preferences.plotMarkerSizedata = 'peakVoltage';

% Cell type classification definitions
UI.preferences.cellTypes = {'Unknown','Pyramidal Cell','Narrow Interneuron','Wide Interneuron'};
UI.preferences.deepSuperficial = {'Unknown','Cortical','Deep','Superficial'};
UI.preferences.tags = {'Good','Bad','Noise','InverseSpike'};
UI.preferences.groundTruth = {'PV','NOS1','GAT1','SST','Axoaxonic','CellType_A'};
UI.preferences.groupDataMarkers = ce_append(["o","d","s","*","+"],["m","k","g"]'); 

UI.preferences.putativeConnectingMarkers = {'k','m','c','b'}; % 1) Excitatory, 2) Inhibitory, 3) Receiving Excitation, 4) receiving Inhibition, 
UI.preferences.groundTruthMarker = 'o'; % Supports any Matlab marker symbols: https://www.mathworks.com/help/matlab/creating_plots/create-line-plot-with-markers.html
UI.preferences.groundTruthColors = [[.9,.2,.2];[.2,.2,.9];[0.2,0.9,0.9];[0.9,0.2,0.9];[.2,.9,.2];[.5,.5,.5];[.8,.2,.2];[.2,.2,.8];[0.2,0.8,0.8];[0.8,0.2,0.8]];
UI.preferences.cellTypeColors = [[.5,.5,.5];[.8,.2,.2];[.2,.2,.8];[0.2,0.8,0.8];[0.8,0.2,0.8];[.2,.8,.2]];

% tSNE representation
UI.preferences.tSNE.metrics = {'troughToPeak','ab_ratio','burstIndex_Royer2012','acg_tau_rise','firingRate'};
UI.preferences.tSNE.dDistanceMetric = 'chebychev'; % default: 'euclidean'
UI.preferences.tSNE.exaggeration = 10;             % default: 15
UI.preferences.tSNE.standardize = true;           % boolean
UI.preferences.tSNE.NumPCAComponents = 0;
UI.preferences.tSNE.LearnRate = 1000;
UI.preferences.tSNE.Perplexity = 30;
UI.preferences.tSNE.InitialY = 'Random';

% Highlight excitatory / inhibitory cells
UI.preferences.displayInhibitory = false;          % boolean
UI.preferences.displayExcitatory = false;          % boolean
UI.preferences.displayExcitatoryPostsynapticCells = false; % boolean
UI.preferences.displayInhibitoryPostsynapticCells = false; % boolean
UI.preferences.plotExcitatoryConnections = true; 
UI.preferences.plotInhibitoryConnections = true; 

% Firing rate map setting
UI.preferences.firingRateMap.showHeatmap = false;          % boolean
UI.preferences.firingRateMap.showLegend = false;           % boolean
UI.preferences.firingRateMap.showHeatmapColorbar = false;  % boolean

% Supplementary figure
UI.supplementaryFigure.waveformNormalization = 1;
UI.supplementaryFigure.groupDataNormalization = 1;
UI.supplementaryFigure.metrics = {'troughToPeak'  'acg_tau_rise'  'firingRate'  'cv2'  'peakVoltage'  'isolationDistance'  'lRatio'  'refractoryPeriodViolation'};
UI.supplementaryFigure.axisScale = [1 2 2 2 2 2 2 2];
UI.supplementaryFigure.smoothing = [1 1 1 1 1 1 1 1];
