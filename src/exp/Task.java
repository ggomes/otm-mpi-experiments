package exp;

import java.nio.file.Path;

public class Task {

    public enum TaskType {SERIAL,MPI}
    public int task_id;
    public String config;
    public int num_nodes;
    private Path prefix;
    public int num_partitions;
    public int repetition;

    public Task(int task_id, String config,int num_nodes,Path prefix, int num_partitions, int repetition) {
        this.task_id = task_id;
        this.config = config;
        this.num_nodes = num_nodes;
        this.prefix = prefix;
        this.num_partitions = num_partitions;
        this.repetition = repetition;
    }

    public int get_size(){
        return  num_nodes / num_partitions;
    }

//    public int num_nodes(){
//
//    }

    public int get_num_nodes(){
        return 1 + Math.floorDiv(num_partitions,32);
    }

    public TaskType get_type(){
        return num_partitions==1 ? TaskType.SERIAL : TaskType.MPI;
    }

    public String get_prefix(){
        return prefix.getFileName().toString();
    }

    public String get_prefix_generic(){
        return Utils.to_generic(prefix.toString());
//        return Utils.to_generic(String.format("%s_%d",prefix.toString(),repetition));
    }

    public String get_config_name(){
        return String.format("%d",num_nodes);
    }
}
