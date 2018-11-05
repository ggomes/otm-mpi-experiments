function plot_network()

numnodes = 100;
folder = fullfile('C:\Users\gomes\code\otm\otm-mpi-experiments\split_files',num2str(numnodes));
colors = [ [1 0 0] ; ...
           [0 1 0] ; ...
           [0 0 1] ; ...
           [1 1 0] ; ...
           [1 0 1] ; ...
           [0 1 1] ; ...
           rand(20,3) ];

if ~exist(fullfile(folder,'part1.mat'),'file')
    numpart = 1;
    prefix = fullfile(fullfile(folder,num2str(numpart)),sprintf('%d_%d_cfg_',numnodes,numpart));
    x = Scenario(sprintf('%s0.xml',prefix));
    save(fullfile(folder,'part1'))
else
    load(fullfile(folder,'part1'))
end

for logn=1:4
    plot_partition(x,2^logn)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function []=plot_partition(x,num_part)
        
        filename = fullfile(folder,sprintf('part%d',num_part));
        if ~exist([filename '.mat'],'file')
            p = fullfile(fullfile(folder,num2str(num_part)),sprintf('%d_%d_cfg_',numnodes,num_part));
            for i=0:num_part-1
                z = Scenario(sprintf('%s%d.xml',p,i));
                zlink_ids{i+1} = z.get_link_ids;
                clear z
            end
            save(filename)
        else
            load(filename)            
        end
        
        node_ids = x.get_node_ids();
        link_ids = x.get_link_ids();
        num_links = numel(link_ids);
        
        figure
        hold on
        
        for i=1:num_links
            start_node = x.scenario.network.nodes.node( x.link_id_begin_end(i,2)==node_ids ).ATTRIBUTE;
            end_node = x.scenario.network.nodes.node( x.link_id_begin_end(i,3)==node_ids ).ATTRIBUTE;
            h(i) = line([start_node.x end_node.x],[start_node.y end_node.y],'LineWidth',2);
        end
        
        set(gca,'YTickLabel',[],'YTick',[])
        set(gca,'XTickLabel',[],'XTick',[])
                
        for i=1:num_part
            set(h(ismember(link_ids,zlink_ids{i})),'Color',colors(i,:))
        end
        
        for i=1:num_part
            for j=i+1:num_part
                boundary = intersect(zlink_ids{i},zlink_ids{j});
                set(h(ismember(link_ids,boundary)),'Color',[0 0 0])
            end
            
        end
        
    end

end


