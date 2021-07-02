
%Guillaume Viejo, 2021

function MasterKiloSort1_ipn


[~,mergename] = fileparts(pwd);

datName = [mergename '.dat'];

if ~exist(datName,'file')
    error('No dat file!')
end

datName = [mergename '.dat'];

if ~exist(datName,'file')
    error('No dat file!')
end

KiloSort1Wrapper_ipn;
