package exp;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;

public class Job {

    public static Map<Task.TaskType,String> script_name = new HashMap<>();
    static {
        script_name.put(Task.TaskType.SERIAL,"serial_task.sh");
        script_name.put(Task.TaskType.MPI,"mpi_task.sh");
    }

    public int job_id;
    public int allocate_minutes;
    public int allocate_nodes;
    public List<Task> tasks;

    public Job(int job_id, int allocate_minutes, List<Task> tasks) {
        this.job_id = job_id;
        this.allocate_minutes = allocate_minutes;
        this.tasks = tasks;
    }

    public void write_files(Path jobs_folder,float sim_dt,float duration){

        try {

            // create job id folder
            Path path = Paths.get(jobs_folder.toString(), String.format("%d", job_id));
            if (!Files.exists(path))
                Files.createDirectory(path);

            // write manual batch runner
            Path manual_file = Paths.get(path.toString(),"manual_job");
            PrintWriter manual_writer = new PrintWriter(manual_file.toFile(), "UTF-8");
            int total_nodes = tasks.stream().mapToInt(x->x.get_num_nodes()).max().getAsInt() + 1;
            int total_minutes = 40;
            manual_writer.write(get_manual_batch_string(path,job_id,total_nodes,total_minutes));
            for (Task task : tasks)
                manual_writer.write(String.format("mpiexec -n %d java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:$OTMMPIHOME/out_mpijavac runner/RunnerMPI %s %.0f %.0f false &\n",
                        task.num_partitions, task.get_prefix_generic(),sim_dt,duration));
            manual_writer.write("wait\n");
            manual_writer.close();


        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public String get_manual_batch_string(Path path,int job_id,int total_nodes,int total_minutes){

        String generic_path = Utils.to_generic(path.toString());

        String jobname = String.format("job%d",job_id);

        Date d = new Date(total_minutes * 60L * 1000L);
        SimpleDateFormat df = new SimpleDateFormat("HH:mm:ss"); // HH for 0-23
        df.setTimeZone(TimeZone.getTimeZone("GMT"));
        String time = df.format(d);

        return String.format(
                        "#!/bin/bash\n"+
                        "#SBATCH --nodes=%d\n"+
                        "#SBATCH --time=%s\n"+
                        "#SBATCH --job-name=%s\n"+
                        "#SBATCH --mail-user=gomes@berkeley.edu\n"+
                        "#SBATCH --mail-type=ALL,TIME_LIMIT\n"+
                        "#SBATCH --constraint=haswell\n"+
                        "#SBATCH --qos=regular\n"+
                        "#SBATCH --output=my_job.o%%j\n"
                        , total_nodes,time,jobname);
    }

}
