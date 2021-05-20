function savepath = Kilosort25Wrapper_workshop(varargin)
% Creates channel map from Neuroscope xml files, runs KiloSort and
% writes output data to Neurosuite format or Phy.
% 
% USAGE
%
% KiloSortWrapper()
% Should be run from the data folder, and file basenames are the
% same as the name as current directory
%
% KiloSortWrapper(varargin)
%
% INPUTS
% basepath           path to the folder containing the data
% basename           file basenames (of the dat and xml files)
% config             Specify a configuration file to use from the
%                    ConfigurationFiles folder. e.g. 'Omid'
% GPU_id             Specify the GPU id
%
% Dependencies:  KiloSort (https://github.com/cortex-lab/KiloSort)
% 
% Copyright (C) 2016 Brendon Watson and the Buzsakilab
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
disp('Running Kilosort spike sorting with the Buzsaki lab wrapper')

%% If function is called without argument
p = inputParser;
basepath = cd;
[~,basename] = fileparts(basepath);

addParameter(p,'basepath',basepath,@ischar)
addParameter(p,'basename',basename,@ischar)
addParameter(p,'GPU_id',1,@isnumeric)

parse(p,varargin{:})

basepath = p.Results.basepath;
basename = p.Results.basename;
GPU_id = p.Results.GPU_id;

cd(basepath)

%% Checking if dat and xml files exist
if ~exist(fullfile(basepath,[basename,'.xml']))
    warning('KilosortWrapper  %s.xml file not in path %s',basename,basepath);
    return
elseif ~exist(fullfile(basepath,[basename,'.dat']))
    warning('KilosortWrapper  %s.dat file not in path %s',basename,basepath)
    return
end

%% Creates a channel map file
disp('Creating ChannelMapFile')
createChannelMapFile_KSW(basepath,basename,'staggered');



%% Loading configurations
XMLFilePath = fullfile(basepath, [basename '.xml']);

disp('Running Kilosort2 with standard settings')
ops = Kilosort25Configuration(XMLFilePath);

%% % Defining SSD location if any

%addpath(genpath('/GitHub/Kilosort2')) % path to kilosort folder
%addpath(genpath('/home/adrien/Kilosort2'));
%addpath(genpath('/home/adrien/Toolbox/Kilosort'));
%addpath('~/GitHub/npy-matlab/npy-matlab') % for converting to Phy

rootZ = basepath; % the raw data binary file is in this folder
%rootH = '/mnt/DataSSD'; % path to temporary binary file (same size as data, should be on fast SSD)
mkdir('tmp')
rootH = '/tmp';
ops.trange = [0 Inf]; % time range to sort

ops.fproc   = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD

% is there a channel map file in this folder?
fs = dir(fullfile(rootZ, 'chan*.mat'));if ~isempty(fs)
    ops.chanMap = fullfile(rootZ, fs(1).name);
else
    error('No chan Map file!')
end
load(fullfile(basepath,'chanMap.mat'))

ops.NchanTOT            = length(connected); % total number of channels
ops.Nchan = sum(~connected); % number of active channels

% preprocess data to create temp_wh.dat
rez = preprocessDataSub(ops);
%
% NEW STEP TO DO DATA REGISTRATION
rez = datashift2(rez, 1); % last input is for shifting data

% ORDER OF BATCHES IS NOW RANDOM, controlled by random number generator
iseed = 1;
                 
% main tracking and template matching algorithm
rez = learnAndSolve8b(rez, iseed);

% OPTIONAL: remove double-counted spikes - solves issue in which individual spikes are assigned to multiple templates.
% See issue 29: https://github.com/MouseLand/Kilosort/issues/29
%rez = remove_ks2_duplicate_spikes(rez);

% final merges
rez = find_merges(rez, 1);

% final splits by SVD
rez = splitAllClusters(rez, 1);

% decide on cutoff
rez = set_cutoff(rez);
% eliminate widely spread waveforms (likely noise)
rez.good = get_good_units(rez);

fprintf('found %d good units \n', sum(rez.good>0))

% Adrian's temporary fix below
load('chanMap.mat')

rez.connected = connected;
rez.ops.root = pwd;
rez.ops.basename = basename;


% discard features in final rez file (too slow to save)
rez.cProj = [];
rez.cProjPC = [];

% final time sorting of spikes, for apps that use st3 directly
[~, isort]   = sortrows(rez.st3);
rez.st3      = rez.st3(isort, :);

% Ensure all GPU arrays are transferred to CPU side before saving to .mat
rez_fields = fieldnames(rez);
for i = 1:numel(rez_fields)
    field_name = rez_fields{i};
    if(isa(rez.(field_name), 'gpuArray'))
        rez.(field_name) = gather(rez.(field_name));
    end
end

% save final results as rez2
fprintf('Saving final results in rez2  \n')
fname = fullfile(rootZ, 'rez2.mat');
save(fname, 'rez', '-v7.3');

%% export Phy files
% write to Phy
%fprintf('Saving results to Phy  \n')
%rezToPhy(rez, rootZ);


%% export Neurosuite files
% if ops.export.neurosuite
    disp('Converting to Klusters format')
%    load('rez2.mat')
    
    %rez.ops.fbinary = fullfile(pwd, [basename,'.dat']);
    Kilosort2Neurosuite(rez)
% end

%% Remove temporary file and resetting GPU
delete(ops.fproc);
%reset(gpudev)
gpuDevice([])
disp('Kilosort Processing complete')
