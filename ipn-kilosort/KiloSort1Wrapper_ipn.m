function savepath = KiloSort1Wrapper_ipn(varargin)
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
% (at your option) any later version
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




%% Loading configurations
XMLFilePath = fullfile(basepath, [basename '.xml']);

disp('Running Kilosort with standard settings')
ops = Kilosort1Configuration(XMLFilePath);

%% % Defining SSD location if any

%addpath(genpath('/GitHub/Kilosort2')) % path to kilosort folder
addpath(genpath('kilosort1'));
%addpath('~/GitHub/npy-matlab/npy-matlab') % for converting to Phy


mkdir('tmp')

ops.trange = [0 Inf]; % time range to sort


%% Creates a channel map file
disp('Creating ChannelMapFile')

rootZ = basepath; % the raw data binary file is in this folder

% is there a channel map file in this folder?
fs = dir(fullfile(rootZ, 'chan*.mat'));
if ~isempty(fs)
    ops.chanMap = fullfile(rootZ, fs(1).name);
    load(fullfile(rootZ, fs(1).name));
else
    error('No chan Map file!')
    createChannelMapFile_KSW(basepath,basename,'staggered');
    fs = dir(fullfile(rootZ, 'chan*.mat'));
    load(fullfile(rootZ, fs(1).name));
end
%load(fullfile(basepath,'chanMap.mat'))

ops.NchanTOT            = length(connected); % total number of channels
ops.Nchan = sum(connected); % number of active channels


%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', rootZ)

[rez, DATA, uproj] = preprocessData(ops); % preprocess data and extract spikes for initialization
rez                = fitTemplates(rez, DATA, uproj);  % fit templates iteratively
rez                = fullMPMU(rez, DATA);% extract final spike times (overlapping extraction)
%load('chanMap.mat')

rez.connected = connected;
rez.ops.root = pwd;
rez.ops.basename = basename;



save('rez.mat','rez','-v7.3');
%fprintf('found %d good units \n', sum(rez.good>0))

%% export Phy files
% write to Phy
fprintf('Saving results to Phy  \n')
savepath = fullfile(rootZ, 'Phy');
mkdir(savepath);
rezToPhy(rez, savepath);


%% export Neurosuite files
% if ops.export.neurosuite
    disp('Converting to Klusters format')
    load('rez.mat')
    
    %rez.ops.fbinary = fullfile(pwd, [basename,'.dat']);
    Kilosort2Neurosuite(rez)
% end

%% Remove temporary file and resetting GPU
delete(ops.fproc);
%reset(gpudev)
%gpuDevice([])
disp('Kilosort Processing complete')
