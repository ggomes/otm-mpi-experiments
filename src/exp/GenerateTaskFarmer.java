package exp;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

/**
 * Specification of all of the experiments to be run.
 * Generation of TaskFarmer input files
 */
public class GenerateTaskFarmer {
    public static Map<Integer,Config> scenario_map;
    static {
        scenario_map = new HashMap<>();
        scenario_map.put(1,new Config("25_nodes.xml",5,6,1));
        scenario_map.put(2,new Config("100_nodes.xml",5,6,3));
        scenario_map.put(3,new Config("2500_nodes.xml",5,6,15));
        scenario_map.put(4,new Config("10000_nodes.xml",5,6,60));
        scenario_map.put(4,new Config("62500_nodes.xml",5,6,60));
    }
    public static float sim_dt = 2f;
//    public static float out_dt = 10f;
    public static float duration = 1000f;
    public static int task_id = 0;
    public static int job_id = 0;

    public static void main(String[] args) {

        // Check we are on Cori
        String scratch_folder = System.getenv().keySet().contains("SCRATCH") ?
                System.getenv("SCRATCH") :
                "C:/Users/gomes/code/otm/otm-mpi-experiments";   // for debugging by Gabriel

        List<Job> jobs = new ArrayList<>();

        // add serial runs
        jobs.add(all_serial_runs());

        // add mpi runs
        for(Integer config_id : scenario_map.keySet())
            jobs.add(mpi_runs(config_id));

        // write files
        write_files(jobs,Paths.get(scratch_folder,"jobs"));
    }

    private static Job all_serial_runs(){
        Job job = new Job(job_id++,30);
        for(Integer config_id : scenario_map.keySet()) {
            Config config = scenario_map.get(config_id);
            for (int r = 0; r < config.repetitions; r++)
                job.tasks.add(new Task(task_id++, Task.TaskType.SERIAL, config_id,1,2*config.max_run_minutes));
        }
        return job;
    }

    private static Job mpi_runs(int config_id){
        Config config = scenario_map.get(config_id);
        Job job = new Job(job_id++,30);
        for(int e=1;e<=config.max_exponent;e++) {
            int num_partitions = (int) Math.pow(2,e);
            for (int r = 0; r < config.repetitions; r++)
                job.tasks.add(new Task(task_id++, Task.TaskType.MPI, config_id,num_partitions,config.max_run_minutes));
        }
        return job;
    }

    private static void write_files(List<Job> jobs,Path jobs_folder){

        // write job and task list
        try {
            Path job_file = Paths.get(jobs_folder.toString(),"job_list.txt");
            PrintWriter job_writer = new PrintWriter(job_file.toFile(), "UTF-8");
            Path task_file = Paths.get(jobs_folder.toString(),"task_list.txt");
            PrintWriter task_writer = new PrintWriter(task_file.toFile(), "UTF-8");

            job_writer.write("#jobid,minute,nodes\n");
            task_writer.write("#taskid,type,jobid,configid,n\n");
            for(Job job : jobs) {
                job_writer.write(String.format("%d,%d,%d\n", job.job_id, job.allocate_minutes, job.allocate_nodes));
                for(Task task : job.tasks)
                    task_writer.write(String.format("%d,%s,%d,%d,%d\n",task.task_id,task.type,job.job_id,task.config_id,task.num_partitions));
            }
            job_writer.close();
            task_writer.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        // write individual job files
        for(Job job : jobs)
            job.write_files(jobs_folder);
    }

    public static class Config {
        String config;
        int repetitions;
        int max_exponent;
        int max_run_minutes;
        public Config(String config, int repetitions, int max_exponent, int max_run_minutes) {
            this.config = config;
            this.repetitions = repetitions;
            this.max_exponent = max_exponent;
            this.max_run_minutes = max_run_minutes;
        }
    }
}
