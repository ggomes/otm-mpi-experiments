function make_plots()

close all

Aarray = struct(...
    'load',[],  ...
    'run',[],...
    'metis_run',[],...
    'metagraph_config',[],...
    'create_subscenario',[],...
    'create_translator',[],...
    'comminication',[],...
    'num_double_send',[],...
    'num_double_receive',[]);

Anan = struct(...
    'load',nan,...
    'run',nan,...
    'metis_run',nan,...
    'metagraph_config',nan,...
    'create_subscenario',nan,...
    'create_translator',nan,...
    'comminication',nan,...
    'num_double_send',nan,...
    'num_double_receive',nan);

here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(here));
hpc_folder = fullfile(root,'output_hpc');
jobs_folder = fullfile(hpc_folder,'jobs');
data_folder = fullfile(hpc_folder,'out');
out_folder = fullfile(root,'output_analysis');

T = readtable(fullfile(jobs_folder,'task_list.txt'));
unique_configs = sort(unique(T.configid));
for ic = 1:numel(unique_configs)
                
    configid = unique_configs(ic);
    Tx = T(T.configid==configid,:);
    unique_n = sort(unique(Tx.n));
    
    A = Aarray;
    A.n = [];
    for in = 1:numel(unique_n)
                
        n = unique_n(in);
        Txx = Tx(Tx.n==n,:);
        num_rep = size(Txx,1);
        
        %  task type
        unique_type = unique(Txx.type);
        if numel(unique_type)~=1
            error('asdf')
        end
        task_type = unique_type{1};
        
        % iterate over repetitions
        timers = repmat(Anan,1,num_rep);
        for ir = 1:num_rep
            task_id = Txx.x_taskid(ir);
            folder = fullfile(data_folder,sprintf("%.3d",task_id));
            if ~check_complete(folder,task_type,n)
                warning(sprintf('incomplete run: task id %d',task_id))
            else
                timers(ir) = read_timers(folder,task_type,n,Anan);
            end
        end
        clear task_id ir folder
        
        % gather timer info
        z = fields(timers);
        for i=1:numel(z)
            A.(z{i}) = [A.(z{i}) ; [timers.(z{i})]'];
        end
        A.n = [A.n;n*ones(numel(timers),1)];
        
        clear Txx z i n num_rep ir task_type unique_type timers
    end
    clear Tx in
    
    % plots
    comm_plot(A,configid,out_folder);
    pieplots(A,configid,out_folder)
    speedplots(A,configid,out_folder)

end
clear ic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [b]=check_complete(folder,task_type,n)

switch(task_type)
    case 'SERIAL'
        expected_files{1} = 'serial_10_g_link_veh.txt';
        expected_files{2} = 'serial_10_g_link_veh_links.txt';
        expected_files{3} = 'serial_10_g_link_veh_time.txt';
        expected_files{4} = 'serial_timers.txt';
        
        
    case 'MPI'
        expected_files{1} = '_metis';
        expected_files{2} = '_nodemap.txt';        
        expected_files{3} = ['_metis.part.' num2str(n)];
        for i=0:n-1
            expected_files{end+1} = ['mpi' num2str(i) '_10_g_link_veh.txt'];
            expected_files{end+1} = ['mpi' num2str(i) '_10_g_link_veh_links.txt'];
            expected_files{end+1} = ['mpi' num2str(i) '_10_g_link_veh_time.txt'];
            expected_files{end+1} = ['mpi' num2str(i) '_timers.txt'];
        end
        
    otherwise
        
end

a = dir(folder);
a = a(~[a.isdir]);
b = ( numel(expected_files)==numel(a) ) && all(ismember(expected_files,{a.name}));

function A = read_timers(folder,task_type,n,Astruct)

As = repmat(Astruct,1,n);
for in=0:n-1
    switch task_type
        case 'SERIAL'
            S = fileread(fullfile(folder,'serial_timers.txt'));
        case 'MPI'
            S = fileread(fullfile(folder,['mpi' num2str(in) '_timers.txt']));
    end
    C = regexpi(S,'(\w+)\s(\d*.\d*)','tokens');
    for c=1:numel(C)
        As(in+1).(C{c}{1}) = str2double(C{c}{2});
    end
end

A = Astruct;
A.load                  = max([As.load]);
A.run                   = max([As.run]);
A.metis_run             = max([As.metis_run]);
A.metagraph_config      = max([As.metagraph_config]);
A.create_subscenario    = max([As.create_subscenario]);
A.create_translator     = max([As.create_translator]);
A.comminication         = max([As.comminication]);
A.num_double_send       = sum([As.num_double_send]);
A.num_double_receive    = sum([As.num_double_receive]);

function comm_plot(A,config,out_folder)

n = sort(unique(A.n));
SND = nan(1,numel(n));
for in=1:numel(n)
    ind = A.n==n(in);
    snd = A.num_double_send(ind);
    SND(in) = mean(snd);
end

figure('Visible','off')
[ppt,op]=openppt(fullfile(out_folder,sprintf('commplot_%d',config)),true);
plot(n,SND,'LineWidth',1.5,'Marker','.','MarkerSize',13)
xlabel('# MPI processes')
ylabel('# doubles')
grid
tit = sprintf('Communication config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)

clf
plot(log2(n),SND,'LineWidth',1.5,'Marker','.','MarkerSize',13)
xlabel('log(# MPI processes)')
ylabel('# doubles')
grid
tit = sprintf('Communication config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)
close
closeppt(ppt,op)

function []=pieplots(A,config,out_folder)

unique_n = unique(A.n);

figure('Visible','off')
[ppt,op]=openppt(fullfile(out_folder,sprintf('pieplots_%d',config)),true);

% pie plot for times of each run
for in=1:numel(unique_n)
        
    ind = A.n==unique_n(in);
    
    M = struct(...
        'load' , meanwithnan(A.load(ind)) , ...
        'run_all' , meanwithnan(A.run(ind)) , ...
        'run_comm' , meanwithnan(A.comminication(ind)) , ...
        'metis_run' , meanwithnan(A.metis_run(ind)) , ...
        'other',meanwithnan(A.metagraph_config(ind))+meanwithnan(A.create_subscenario(ind)));
    
    clf
    
    if unique_n(in)==1
        pie( [M.load M.run_all] , ...
            {sprintf('load (%.1f)',M.load) , ...
            sprintf('run (%.1f)',M.run_all) })
        tit = sprintf('Config %d, serial run',config);
    else
        data = [M.load M.metis_run M.other M.run_comm M.run_all-M.run_comm];
        
        if all(isnan(data))
            continue
        else
            if any(isnan(data))
                error('asdgas')
            end

            pie( [M.load M.metis_run M.other M.run_comm M.run_all-M.run_comm] , { ...
                sprintf('load (%.1f)',M.load) , ...
                sprintf('METIS (%.1f)',M.metis_run) , ...
                sprintf('other (%.1f)',M.other) ...
                sprintf('run comm (%.1f)',M.run_comm) , ...
                sprintf('run comp (%.1f)',M.run_all-M.run_comm) , ...
                })
        end
        
        tit = sprintf('Config %d with %d MPI processes',config,unique_n(in));
    end
    
    addslide(op,tit,'new',[0.5 0.5],[],0.9)
    
end
close
closeppt(ppt,op)

function []=speedplots(A,config,out_folder)

figure('Visible','off')
[ppt,op]=openppt(fullfile(out_folder,sprintf('speedplots_%d',config)),true);

data.run = extract_stats(A,'run');
data.load = extract_stats(A,'load');
data.comm = extract_stats(A,'comminication');
data.send = extract_stats(A,'num_double_send');
data.rcv = extract_stats(A,'num_double_receive');

% speedup
N = numel(data.run.n);
data.speedup = struct('n',data.run.n,'mean',nan(N,1),'std',nan(N,1));
mean_serial = data.run.mean(data.run.n==1);
for i=1:numel(data.run.n)
    vals = mean_serial./data.run.vals{i};
    data.speedup.mean(i) = mean(vals);
    data.speedup.std(i) = std(vals);
end

% run
clf, hold on
h(1)=plot_fill(data.run);
h(2)=plot_fill(data.load);
h(3)=plot_fill(data.comm);
legend(h,'run','load','comm')
xlabel('# MPI processes')
ylabel('time [sec]')
grid
tit = sprintf('Config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)


clf, hold on
h(1)=plot_fill_log(data.run);
h(2)=plot_fill_log(data.load);
h(3)=plot_fill_log(data.comm);
legend(h,'run','load','comm')
xlabel('log2(# MPI processes)')
ylabel('time [sec]')
grid
tit = sprintf('Config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)

% speedup
clf, hold on
plot_fill(data.speedup);
min_n = data.run.n(1);
max_n = data.run.n(find(~isnan(data.run.mean),1,'last'));
plot([min_n max_n],[min_n max_n],'k--','LineWidth',1.5)
xlabel('# MPI processes')
ylabel('ratio')
grid
tit = sprintf('Config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)

close
closeppt(ppt,op)

function [data]=extract_stats(A,val)

V = A.(val);
n = sort(unique(A.n));
data.n = n;
data.vals = arrayfun( @(x) V(A.n==x) , n ,'UniformOutput' , false);
data.mean = arrayfun(@(x)  mean(x{1}), data.vals);
data.median = arrayfun(@(x)  median(x{1}), data.vals);
data.std = arrayfun(@(x)  std(x{1}), data.vals);

function [M] = meanwithnan(X)
M = mean(X(~isnan(X)));

function [h2,h1] = plot_fill(x)
up = (x.mean + x.std)';
dn = (x.mean - x.std)';
h2=plot(x.n,x.mean,'LineWidth',1.5,'Marker','.','MarkerSize',13);
c = h2.get('Color');
h1=fill([x.n' fliplr(x.n')],[up fliplr(dn)],c);
h1.FaceAlpha = 0.5;
h1.EdgeAlpha = 0;

function [h2,h1] = plot_fill_log(x)
up = (x.mean + x.std)';
dn = (x.mean - x.std)';
log2n = log2(x.n);
h2=plot(log2n,x.mean,'LineWidth',1.5,'Marker','.','MarkerSize',13);
c = h2.get('Color');
h1=fill([log2n' fliplr(log2n')],[up fliplr(dn)],c);
h1.FaceAlpha = 0.5;
h1.EdgeAlpha = 0;




