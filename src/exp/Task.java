package exp;

import java.nio.file.Path;

public class Task {

    public enum TaskType {SERIAL,MPI}
    public int task_id;
    public String config;
    public String config_name;
    private Path prefix;
    public int num_partitions;
    public int repetition;

    public Task(int task_id, String config,String config_name,Path prefix, int num_partitions, int repetition) {
        this.task_id = task_id;
        this.config = config;
        this.config_name = config_name;
        this.prefix = prefix;
        this.num_partitions = num_partitions;
        this.repetition = repetition;
    }

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
    }
}
