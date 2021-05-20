function Kilosort2Neurosuite(rez,varargin)
% Converts KiloSort output (.rez structure) to Neurosuite files: fet,res,clu,spk files.
% Based on the GPU enable filter from Kilosort and fractions from Brendon
% Watson's code for saving Neurosuite files. 

% The script has a high memory usage as all waveforms are loaded into 
% memory at the same time. If you experience a memory error, increase 
% your swap/cashe file, and increase the amount of memory MATLAB c
%
% 1) Waveforms are extracted from the dat file via GPU enabled filters.
% 2) Features are calculated in parfor loops.
%
% Inputs:
% rez           rez structure from Kilosort
% bigSpkfiles   boolean, to extract large spke files (optional)

% By Peter Petersen 2018, modified by A Peyrache 2020
% petersen.peter@gmail.com

largeSpk = 0;
if ~isempty(varargin)
    largeSpk = varargin{1};
end

t1 = tic;
spikeTimes = uint64(rez.st3(:,1)); % uint64
spikeTemplates = uint32(rez.st3(:,2)); % uint32 % template id for each spike
kcoords = rez.ops.kcoords;
basename = rez.ops.basename;

Nchan = rez.ops.Nchan;
nSamples = 32;%rez.ops.nt0;

%templates = gpuArray(zeros(Nchan, size(rez.W,1), rez.ops.Nfilt, 'single'));
templates = gpuArray(zeros(Nchan, size(rez.W,1), size(rez.U,2), 'single'));
for iNN = 1:size(rez.U,2)%rez.ops.Nfilt %

    templates(:,:,iNN) = squeeze(rez.U(:,iNN,:)) * squeeze(rez.W(:,iNN,:))';
end

templates = gather(templates);

amplitude_max_channel = [];
for i = 1:size(templates,3)
    [~,amplitude_max_channel(i)] = max(range(templates(:,:,i)'));
end
clear templates

template_kcoords = kcoords(amplitude_max_channel);
kcoords2 = unique(template_kcoords);

ia = [];
for i = 1:length(kcoords2)
    kcoords3 = kcoords2(i);
    if mod(i,4)==1; fprintf('\n'); end
    fprintf(['Loading data for spike group ', num2str(kcoords3),'. '])
    template_index = find(template_kcoords == kcoords3);
    ia{i} = find(ismember(spikeTemplates,template_index));
end
rez.ia = ia;
fprintf('\n'); toc(t1)

fprintf('\nSaving .clu files to disk (cluster indexes)')
for i = 1:length(kcoords2)
    kcoords3 = kcoords2(i);
    if mod(i,4)==1; fprintf('\n'); end
    fprintf(['Saving .clu file for group ', num2str(kcoords3),'. '])
    tclu = spikeTemplates(ia{i})+1; %we don't want any cluster=1
    tclu = cat(1,length(unique(tclu)),double(tclu));
    cluname = fullfile([basename '.clu.' num2str(kcoords3)]);
    fid=fopen(cluname,'w');
    fprintf(fid,'%.0f\n',tclu);
    fclose(fid);
    clear fid
    
    if ~exist('OriginalClus','dir')
        mkdir('OriginalClus')
    end
    system(['cp ' cluname ' OriginalClus/'])
    
end
clear tclu cluname spikeTemplates
fprintf('\n'); toc(t1)

fprintf('\nSaving .res files to disk (spike times)')
for i = 1:length(kcoords2)
    kcoords3 = kcoords2(i);
    tspktimes = spikeTimes(ia{i});
    if mod(i,4)==1; fprintf('\n'); end
    fprintf(['Saving .res file for group ', num2str(kcoords3),'. '])
    resname = fullfile([basename '.res.' num2str(kcoords3)]);
    fid=fopen(resname,'w');
    fprintf(fid,'%.0f\n',tspktimes);
    fclose(fid);
    clear fid
end
clear tspktime resname
fprintf('\n'); toc(t1)

fprintf('\nExtracting waveforms\n')

%try %There are often 'out of memory' or other issues here. Better to catch them
    
if  (length(kcoords2)==1 && rez.ops.NchanTOT>16) || largeSpk == 1
    fprintf('Extracting Spikes for linear shanks\n\n')
    Process_ExtractLargeSpk(rez);
else

    waveforms_all = Kilosort_ExtractWaveforms(rez);
    clear rez;
    
    nChannels = zeros(length(kcoords2),1);
    
    fprintf('\n'); toc(t1)

    fprintf('\nSaving .spk files to disk (waveforms)')
    for i = 1:length(kcoords2)
        kcoords3 = kcoords2(i);
        if mod(i,4)==1; fprintf('\n'); end
        fprintf(['Saving .spk for group ', num2str(kcoords2(i)),'. '])
        fid=fopen([basename,'.spk.',num2str(kcoords3)],'w');
        fwrite(fid,waveforms_all{i}(:),'int16');
        fclose(fid);
        
        nChannels(i) = size(waveforms_all{i},1);
       
    end
    fprintf('\n'); toc(t1)
    
    clear waveforms_all

    fprintf('\nComputing PCAs')
    % Starting parpool if stated in the Kilosort settings
    %if (rez.ops.parfor & isempty(gcp('nocreate'))); parpool; end

    for i = 1:length(kcoords2)
        kcoords3 = kcoords2(i);
        if mod(i,2)==1; fprintf('\n'); end
        fprintf(['Computing PCAs for group ', num2str(kcoords3),'. '])

        
        %% Adrien's modification 15 May 2019
        fprintf(['Loading .spk for group ', num2str(kcoords2(i)),'. '])
        waveforms = LoadSpikeWaveforms([basename,'.spk.',num2str(kcoords3)],nChannels(i),nSamples);
        
        PCAs_global = zeros(3,size(waveforms,1),length(ia{i}));

        % Calculating PCAs in parallel if stated in ops.parfor
        %if isempty(gcp('nocreate'))
            for k = 1:size(waveforms,1)
                PCAs_global(:,k,:) = pca(zscore(permute(double(waveforms(k,:,:)),[2,3,1]),[],2),'NumComponents',3)';
            end
        %else
        %    parfor k = 1:size(waveforms,1)
        %        PCAs_global(:,k,:) = pca(zscore(permute(waveforms(k,:,:),[2,3,1]),[],2),'NumComponents',3)';
        %    end
        %end
        
        fprintf(['Saving .fet files for group ', num2str(kcoords3),'. '])
        PCAs_global = reshape(PCAs_global,size(PCAs_global,1)*size(PCAs_global,2),size(PCAs_global,3));
        factor = (2^15)./max(abs(PCAs_global'));
        PCAs_global = int64(PCAs_global .* factor');

        waveforms = reshape(waveforms,[size(waveforms,1)*size(waveforms,2),size(waveforms,3)]);
        wpowers = sum(waveforms.^2,1)/size(waveforms,1)/100;
        wranges = range(waveforms,1);
        
        fid=fopen([basename,'.fet.',num2str(kcoords3)],'w');
        Fet = double([PCAs_global; int64(wranges); int64(wpowers); spikeTimes(ia{i})']);
        nFeatures = size(Fet, 1);
        formatstring = '%d';
        for ii=2:nFeatures
            formatstring = [formatstring,'\t%d'];
        end
        formatstring = [formatstring,'\n'];

        fprintf(fid, '%d\n', nFeatures);
        fprintf(fid,formatstring,Fet);
        fclose(fid);
        
        clear Fet wranges wpowers PCAs_global waveforms
    end
    
end

% catch
%     warning(lasterr)
%     keyboard
% end

gpuDevice([])

fprintf('\n'); toc(t1)
fprintf('\nComplete!')

function waveforms_all = Kilosort_ExtractWaveforms(rez)
        % Extracts waveforms from a dat file using GPU enable filters.
        % Based on the GPU enable filter from Kilosort.
        % All settings and content are extracted from the rez input structure
        %
        % Inputs:
        %   rez -  rez structure from Kilosort
        %
        % Outputs:
        %   waveforms_all - structure with extracted waveforms
        
        % Extracting content from the .rez file
        ops = rez.ops;
        NT = ops.NT;
        if exist('ops.fbinary') == 0
            warning(['Binary file does not exist: ', ops.fbinary])
        end
        d = dir(ops.fbinary);

        NchanTOT = ops.NchanTOT;
        chanMap = ops.chanMap;
        chanMapConn = chanMap; %(rez.connected>1e-6);
        kcoords = ops.kcoords;
        ia = rez.ia;
        spikeTimes = rez.st3(:,1);

        ops.ForceMaxRAMforDat   = 10000000000;

        if ispc
            dmem         = memory;
            memfree      = dmem.MemAvailableAllArrays/8;
            memallocated = min(ops.ForceMaxRAMforDat, dmem.MemAvailableAllArrays) - memfree;
            memallocated = max(0, memallocated);
        else
            memallocated = ops.ForceMaxRAMforDat;
        end
        
        %memallocated = ops.ForceMaxRAMforDat;
        nint16s      = memallocated/2;
        
        %HEre, a lot of space should have been cleared from memory. It's OK
        %to make the batch bigger than in KiloSort.
        NT          = 2^14*32+ ops.ntbuff;
        NTbuff      = NT + 4*ops.ntbuff;
        Nbatch      = ceil(d.bytes/2/NchanTOT /(NT-ops.ntbuff));
        Nbatch_buff = floor(4/5 * nint16s/ops.Nchan /(NT-ops.ntbuff)); % factor of 4/5 for storing PCs of spikes
        Nbatch_buff = min(Nbatch_buff, Nbatch);
        
        if isfield(ops,'fslow')&&ops.fslow<ops.fs/2
            [b1, a1] = butter(3, [ops.fshigh/ops.fs,ops.fslow/ops.fs]*2, 'bandpass');
        else
            [b1, a1] = butter(3, ops.fshigh/ops.fs*2, 'high');
        end
        
        if isfield(ops,'xml')
            disp('Loading xml from rez for probe layout')
            xml = ops.xml;
        elseif exist(fullfile(ops.root,[ops.basename,'.xml']),'file')
            disp('Loading xml for probe layout from root folder')
            xml = LoadXml(fullfile(ops.root,[ops.basename,'.xml']));
            %ops.xml = xml;
        end
        
        fid = fopen(ops.fbinary, 'r');
        
        waveforms_all = cell(length(kcoords2),1);
        template_kcoords = kcoords(amplitude_max_channel);
        kcoords2 = unique(template_kcoords);
    
        channel_order = {};
        indicesTokeep = cell(length(kcoords2),1);
        
        for i = 1:length(kcoords2)
            kcoords3 = kcoords2(i);            
            waveforms_all{i} = zeros(sum(kcoords==kcoords3),nSamples,size(rez.ia{i},1));
                          
            channel_order = xml.AnatGrps(kcoords2(i)).Channels+1;
            [~,~,indicesTokeep{i}] = intersect(channel_order,chanMapConn,'stable');
            
        end
        
        fprintf('Extraction of waveforms begun \n')
        for ibatch = 1:Nbatch
            if mod(ibatch,10)==0
                if ibatch~=10
                    fprintf(repmat('\b',[1 length([num2str(round(100*(ibatch-10)/Nbatch)), ' percent complete'])]))
                end
                fprintf('%d percent complete', round(100*ibatch/Nbatch));
            end
            
            offset = max(0, 2*NchanTOT*((NT - ops.ntbuff) * (ibatch-1) - 2*ops.ntbuff));
            if ibatch==1
                ioffset = 0;
            else
                ioffset = ops.ntbuff;
            end
            fseek(fid, offset, 'bof');
            buff = fread(fid, [NchanTOT NTbuff], '*int16');
            
            if isempty(buff)
                break;
            end
            nsampcurr = size(buff,2);
            if nsampcurr<NTbuff
                buff(:, nsampcurr+1:NTbuff) = repmat(buff(:,nsampcurr), 1, NTbuff-nsampcurr);
            end
            if ops.GPU
                dataRAW = gpuArray(buff);
            else
                dataRAW = buff;
            end
            clear buff
            
            dataRAW = dataRAW';
            dataRAW = single(dataRAW);
            dataRAW = dataRAW(:, chanMapConn);
            dataRAW = dataRAW-median(dataRAW,2);
            dataRAW = filter(b1, a1, dataRAW);
            dataRAW = flipud(dataRAW);
            dataRAW = filter(b1, a1, dataRAW);
            dataRAW = flipud(dataRAW);
            dataRAW = gather_try(int16( dataRAW(ioffset + (1:NT),:)));
            dat_offset = offset/NchanTOT/2+ioffset;
            
            % Saves the waveforms occuring within each batch
            for i = 1:length(kcoords2)
                kcoords3 = kcoords2(i);
%                 ch_subset = 1:length(chanMapConn);
                temp = find(ismember(spikeTimes(ia{i}), [nSamples/2+1:size(dataRAW,1)-nSamples/2] + dat_offset));
                temp2 = spikeTimes(ia{i}(temp))-dat_offset;
                
                startIndicies = temp2-nSamples/2+1;
                stopIndicies = temp2+nSamples/2;
                X = cumsum(accumarray(cumsum([1;stopIndicies(:)-startIndicies(:)+1]),[startIndicies(:);0]-[0;stopIndicies(:)]-1)+1);
                X = X(1:end-1);
                waveforms_all{i}(:,:,temp) = reshape(dataRAW(X,indicesTokeep{i})',size(indicesTokeep{i},1),nSamples,[]);
            end
            clear dataRAW
        end
    end
end
