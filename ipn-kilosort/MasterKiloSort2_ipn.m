
%Guillaume Viejo, 2021

function MasterKiloSort2_ipn


[~,mergename] = fileparts(pwd);
[~,mergename] = fileparts(pwd);

datName = [mergename '.dat'];

if ~exist(datName,'file')
    error('No dat file!')
end

datName = [mergename '.dat'];

if ~exist(datName,'file')
    error('No dat file!')
end

KiloSort2Wrapper_ipn;
