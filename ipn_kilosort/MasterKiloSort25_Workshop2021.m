
%Guillaume Viejo, 2021

function MasterKiloSort25_Workshop2021


[~,mergename] = fileparts(pwd);

datName = [mergename '.dat'];

if ~exist(datName,'file')
    error('No dat file!')
end

Kilosort25Wrapper_workshop;
