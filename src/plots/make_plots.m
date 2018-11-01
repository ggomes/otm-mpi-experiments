function make_plots()

close all

Aarray = struct(...
    'metagraph_load',[],  ...
    'scenario_load',[],  ...
    'translator_load',[],  ...
    'run',[],  ...
    'comm',[],  ...
    'double_send',[],  ...
    'double_receive',[] );

Anan = struct(...
    'metagraph_load',nan,  ...
    'scenario_load',nan,  ...
    'translator_load',nan,  ...
    'run',nan,  ...
    'comm',nan,  ...
    'double_send',nan,  ...
    'double_receive',nan );

here = fileparts(mfilename('fullpath'));
root = fileparts(fileparts(here));
jobs_folder = fullfile(root,'jobs');
data_folder = fullfile(root,'split_files');
out_folder = fullfile(root,'ppt');

T = readtable(fullfile(jobs_folder,'task_list.txt'));
T.config = nan(size(T,1),1);
for i=1:size(T,1)
    z = sscanf(T.prefix{i},'%d_%d');
    T.config(i) = z(1);
end
size(T,1)

unique_configs = sort(unique(T.config));

for ic = 1:numel(unique_configs)
           
    config = unique_configs(ic);
    Tx = T(T.config==config,:);
    unique_n = sort(unique(Tx.n));
    
    A = Aarray;
    A.n = [];
    folder1 = fullfile(data_folder,sprintf("%d",config));

    data = table(   'Size',[numel(unique_n) 12], ...
                    'VariableTypes',{'double','double'  ,'double'   ,'double'   ,'double' ,'double'  ,'double' ,'double'  ,'double'   ,'double'  ,'double'     ,'double'}, ...
                    'VariableNames',{   'n'  ,'load_min','load_mean','load_max' ,'run_min','run_mean','run_max','comm_min','comm_mean','comm_max','double_send','double_receive'});

    remove_row = false(numel(unique_n),1);
    for in = 1:numel(unique_n)
                
        n = unique_n(in);
        Txx = Tx(Tx.n==n,:);
        folder2 = fullfile(folder1,sprintf("%d",n));

        % iterate over repetitions
        timers = repmat(Anan,1,size(Txx,1));
        for ir = 1:size(Txx,1)        
            Txxx = Txx(Txx.repetition==Txx.repetition(ir),:);
            timers(ir) = read_timers(folder2,Txxx,Anan);
        end
        clear Txxx ir
        
        % gather timer info
        data.n(in) = n;
        
        load_time = [timers.metagraph_load]+[timers.scenario_load]+[timers.translator_load];
        data.load_min(in) = min(load_time);
        data.load_mean(in) = mean(load_time);
        data.load_max(in) = max(load_time);
        
        data.run_min(in) = min([timers.run]);
        data.run_mean(in) = mean([timers.run]);
        data.run_max(in) = max([timers.run]);
        
        data.comm_min(in) = min([timers.comm]);
        data.comm_mean(in) = mean([timers.comm]);
        data.comm_max(in) = max([timers.comm]);
        
        if all(isnan([timers.double_send]))
            data.double_send(in) = nan;
            data.double_receive(in) = nan;
        else
            data.double_send(in) = unique([timers.double_send]);
            data.double_receive(in) = unique([timers.double_receive]);
        end
        
        remove_row(in) = all(isnan(table2array(data(in,2:end))));
        
        clear n Txx folder2 timers z i
    end
    clear Tx in
    
    data(remove_row,:)=[];
    sortrows(data);
    
    % plots
    if ~isempty(data)
        comm_plot(data,config,out_folder);
        pieplots(data,config,out_folder)
        speedplots(data,config,out_folder)
    end

end
clear ic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A = read_timers(folder,T,Astruct)

if size(T,1)>1
    error('size(T,1)>1')
end

A = Astruct;
n = unique(T.n);
config = unique(T.config);
rep = unique(T.repetition);

filename = fullfile(folder,sprintf('%d_%d_%d_%d_timers.txt',config,n,0,rep));
if ~exist(filename,'file')
    return
end
    
As = repmat(Astruct,1,n);
for in=1:n
    filename = fullfile(folder,sprintf('%d_%d_%d_%d_timers.txt',config,n,in-1,rep));
    S = fileread(filename);
    C = regexpi(S,'(\w+)\s(\d*.\d*)','tokens');
    for c=1:numel(C)
        As(in).(C{c}{1}) = str2double(C{c}{2});
    end
end

A.metagraph_load	= mean([As.metagraph_load]);
A.scenario_load 	= mean([As.scenario_load]);
A.translator_load   = mean([As.translator_load]);
A.run               = mean([As.run]);
A.comm              = mean([As.comm]);
A.double_send       = sum([As.double_send]);
A.double_receive    = sum([As.double_receive]);

function comm_plot(data,config,out_folder)

figure('Visible','off')
[ppt,op]=openppt(fullfile(out_folder,sprintf('commplot_%d',config)),true);
plot(data.n,data.double_send,'LineWidth',1.5,'Marker','.','MarkerSize',13)
xlabel('# MPI processes')
ylabel('# doubles')
grid
tit = sprintf('Communication config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)

clf
plot(log2(data.n),data.double_send,'LineWidth',1.5,'Marker','.','MarkerSize',13)
xlabel('log(# MPI processes)')
ylabel('# doubles')
grid
tit = sprintf('Communication config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)
close
closeppt(ppt,op)

function []=pieplots(data,config,out_folder)

figure('Visible','off')
[ppt,op]=openppt(fullfile(out_folder,sprintf('pieplots_%d',config)),true);

% pie plot for times of each run
for in=1:numel(data.n)
            
    clf

    pie( [data.load_mean(in) data.run_mean(in) data.comm_mean(in)] , { ...
        sprintf('load (%.1f)',data.load_mean(in)) , ...
        sprintf('run (%.1f)',data.run_mean(in)) , ...
        sprintf('comm (%.1f)',data.comm_mean(in)) })

    tit = sprintf('Config %d with %d MPI processes',config,data.n(in));
    
    addslide(op,tit,'new',[0.5 0.5],[],0.9)
    
end
close
closeppt(ppt,op)

function []=speedplots(data,config,out_folder)

figure('Visible','off')
[ppt,op]=openppt(fullfile(out_folder,sprintf('speedplots_%d',config)),true);

% run
clf, hold on
h(1)=plot_fill(data.n,data.run_min,data.run_mean,data.run_max);
h(2)=plot_fill(data.n,data.load_min,data.load_mean,data.load_max);
h(3)=plot_fill(data.n,data.comm_min,data.comm_mean,data.comm_max);
legend(h,'run','load','comm')
xlabel('# MPI processes')
ylabel('time [sec]')
grid
tit = sprintf('Config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)

clf, hold on
h(1)=plot_fill(log2(data.n),data.run_min,data.run_mean,data.run_max);
h(2)=plot_fill(log2(data.n),data.load_min,data.load_mean,data.load_max);
h(3)=plot_fill(log2(data.n),data.comm_min,data.comm_mean,data.comm_max);
legend(h,'run','load','comm')
xlabel('log2(# MPI processes)')
ylabel('time [sec]')
grid
tit = sprintf('Config %d',config);
addslide(op,tit,'new',[0.5 0.5],[],0.9)

% speedup
if any(data.n==1)
    
    mean_serial = data.run_mean(data.n==1);
    data.speedup_min = mean_serial ./ data.run_max;
    data.speedup_mean = mean_serial ./ data.run_mean;
    data.speedup_max= mean_serial ./ data.run_min;

    clf, hold on
    plot_fill(data.n,data.speedup_min,data.speedup_mean,data.speedup_max);
    xlabel('# MPI processes')
    ylabel('ratio')
    grid
    tit = sprintf('Config %d',config);
    addslide(op,tit,'new',[0.5 0.5],[],0.9)


    clf, hold on
    plot_fill(log2(data.n),data.speedup_min,data.speedup_mean,data.speedup_max);
    xlabel('log2(# MPI processes)')
    ylabel('speedup')
    grid
    tit = sprintf('Config %d',config);
    addslide(op,tit,'new',[0.5 0.5],[],0.9)
end

close
closeppt(ppt,op)

% function [data]=extract_stats(A,val)
% 
% V = A.(val);
% n = sort(unique(A.n));
% data.n = n;
% data.vals = arrayfun( @(x) V(A.n==x) , n ,'UniformOutput' , false);
% data.mean = arrayfun(@(x)  mean(x{1}), data.vals);
% data.median = arrayfun(@(x)  median(x{1}), data.vals);
% data.std = arrayfun(@(x)  std(x{1}), data.vals);

% function [M] = meanwithnan(X)
% M = mean(X(~isnan(X)));

function [h2,h1] = plot_fill(n,xmin,xmean,xmax)

h2=plot(n,xmean,'LineWidth',1.5,'Marker','.','MarkerSize',13);
c = h2.get('Color');
h1=fill([n;flipud(n)],[xmax;flipud(xmin)],c);
h1.FaceAlpha = 0.5;
h1.EdgeAlpha = 0;




