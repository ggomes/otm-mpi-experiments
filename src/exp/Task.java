package exp;

public class Task {

    public enum TaskType {SERIAL,MPI}
    public int task_id;
    public TaskType type;
    public int config_id;
    public int num_partitions;
    public int num_nodes;
    public int max_run_minutes;

    public Task(int task_id, TaskType type, int config_id, int num_partitions,int max_run_minutes) {
        this.task_id = task_id;
        this.type = type;
        this.config_id = config_id;
        this.num_partitions = num_partitions;
        this.num_nodes = 1 + Math.floorDiv(num_partitions,32);
        this.max_run_minutes = max_run_minutes;
    }

}
