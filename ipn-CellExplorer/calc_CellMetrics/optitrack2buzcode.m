function optitrack = optitrack2buzcode(varargin)
% Loads position tracking data from Optitrack to buzcode/CellExplorer data container
% https://cellexplorer.org/datastructure/data-structure-and-format/#behavior
%
% Example calls
% optitrack = optitrack2buzcode('session',session)
% optitrack = optitrack2buzcode('basepath',basepath,'basename',basename,'filenames',filenames)

p = inputParser;
addParameter(p,'session', [], @isstruct); % A session struct
addParameter(p,'basepath', pwd, @isstr); % Basepath of the session
addParameter(p,'basename', [], @isstr); % Name of the session
addParameter(p,'filenames', []); % List of tracking files 
addParameter(p,'unit_normalization', 1, @isnumeric);
addParameter(p,'plot_on', true, @islogical); % Creates plot with behavior
addParameter(p,'saveMat', true, @islogical); % Creates behavior mat file
addParameter(p,'saveFig', true, @islogical); % Save figure with behavior to summary folder
parse(p,varargin{:})

parameters = p.Results;


if ~isempty(parameters.session)
    session = parameters.session;
    basename = session.general.name;
    basepath = session.general.basePath;
    filenames = session.behavioralTracking{1}.filenames;
else
    basepath = p.Results.basepath;
    basename = p.Results.basename;
    filenames = parameters.filenames;
end

if isempty(basename)
    basename = basenameFromBasepath(basepath);
end

% filename = [datapath recording '/' recordings(id).tracking_file];
formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';
header_length = 7;

if iscell(filenames)
    fileID = fopen(fullfile(basepath,filenames{1}),'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', ',',  'ReturnOnError', false); 
    fclose(fileID);
    FramesPrFile = size(dataArray{1}(header_length:end),1);
    for i = 2:length(filenames)
        fileID = fopen(fullfile(basepath,filenames{i}),'r');
        dataArray_temp = textscan(fileID, formatSpec, 'Delimiter', ',',  'ReturnOnError', false); 
        fclose(fileID);
        for j = 1:length(dataArray)
            dataArray{j} = [dataArray{j};dataArray_temp{j}(header_length:end)];
        end
        FramesPrFile = [FramesPrFile, size(dataArray_temp{1}(header_length:end),1)];
    end
else
    fileID = fopen(fullfile(basepath,filenames),'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', ',',  'ReturnOnError', false);
    fclose(fileID);
end

optitrack_temp = [];
optitrack_temp.Frame = str2double(dataArray{1}(header_length:end));
optitrack_temp.Time = str2double(dataArray{2}(header_length:end));
optitrack_temp.Xr = str2double(dataArray{3}(header_length:end));
optitrack_temp.Yr = str2double(dataArray{4}(header_length:end));
optitrack_temp.Zr = str2double(dataArray{5}(header_length:end));
optitrack_temp.Wr = str2double(dataArray{6}(header_length:end));
optitrack_temp.X = str2double(dataArray{7}(header_length:end));
optitrack_temp.Y = str2double(dataArray{8}(header_length:end));
optitrack_temp.Z = str2double(dataArray{9}(header_length:end));
optitrack_temp.TotalFrames = str2double(dataArray{12}(1));
optitrack_temp.TotalExportedFrames = str2double(dataArray{14}(1));
optitrack_temp.RotationType = dataArray{16}(1);
optitrack_temp.LenghtUnit = dataArray{18}(1);
optitrack_temp.CoorinateSpace = dataArray{20}(1);
optitrack_temp.FrameRate = str2double(dataArray{6}{1});
if exist('FramesPrFile')
    optitrack_temp.FramesPrFile = FramesPrFile;
end
clear dataArray
clearvars filename formatSpec fileID dataArray header_length;

% get position out in cm, and flipping Z and Y axis
position = 100*[-optitrack_temp.X,optitrack_temp.Z,optitrack_temp.Y]/parameters.unit_normalization;

% Estimating the speed of the rat
% animal_speed = 100*Optitrack.FrameRate*(diff(Optitrack.X).^2+diff(Optitrack.Y).^2+diff(Optitrack.Z).^2).^0.5;
animal_speed = [optitrack_temp.FrameRate*sqrt(sum(diff(position)'.^2)),0];
animal_speed = nanconv(animal_speed,ones(1,10)/10,'edge');
animal_acceleration = [0,diff(animal_speed)];

% Adding  output struct
optitrack_temp.position3D = position';

% Generating buzcode fields and output struct
optitrack.timestamps = optitrack_temp.Time;
optitrack.timestamps_reference = 'optitrack';
optitrack.sr = optitrack_temp.FrameRate;
optitrack.position.x = optitrack_temp.position3D(1,:);
optitrack.position.y = optitrack_temp.position3D(2,:);
optitrack.position.z = optitrack_temp.position3D(3,:);
optitrack.position.units = 'centimeters';
optitrack.position.referenceFrame = 'global';
optitrack.position.coordinateSystem = 'cartesian';
optitrack.speed = animal_speed;
optitrack.acceleration = animal_acceleration;
optitrack.orientation.x = optitrack_temp.Xr;
optitrack.orientation.y = optitrack_temp.Yr;
optitrack.orientation.z = optitrack_temp.Zr;
optitrack.orientation.rotationType = optitrack_temp.RotationType;
optitrack.nSamples = numel(optitrack.timestamps);
% Attaching info about how the data was processed
optitrack.processinginfo.function = 'optitrack2buzcode';
optitrack.processinginfo.version = 1;
optitrack.processinginfo.date = now;
optitrack.processinginfo.params.basepath = basepath;
optitrack.processinginfo.params.basename = basename;
try
    optitrack.processinginfo.username = char(java.lang.System.getProperty('user.name'));
    optitrack.processinginfo.hostname = char(java.net.InetAddress.getLocalHost.getHostName);
catch
    disp('Failed to retrieve system info.')
end

% Saving data
if parameters.saveMat
    saveStruct(optitrack,'behavior','session',session);
end

% Plotting
if parameters.plot_on
    fig1 = figure;
    subplot(1,2,1)
    plot3(position(:,1),position(:,2),position(:,3)), title('Position'), xlabel('X (cm)'), ylabel('Y (cm)'), zlabel('Z (cm)'),axis tight,view(2), hold on
    subplot(1,2,2)
    plot3(position(:,1),position(:,2),animal_speed), hold on
    xlabel('X (cm)'), ylabel('Y (cm)'),zlabel('Speed (cm/s)'), axis tight
    
    % Saving a summary figure for all cells
    timestamp = datestr(now, '_dd-mm-yyyy_HH.MM.SS');
    ce_savefigure(fig1,basepath,[basename, '.optitrack.behavior' timestamp])
    disp(['optitrack2buzcode: Summary figure saved to ', fullfile(basepath, 'SummaryFigures', [basename, '.optitrack.behavior', timestamp]),'.png'])
end
