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

    public Job(int job_id, int allocate_minutes) {
        this.job_id = job_id;
        this.allocate_minutes = allocate_minutes;
        this.tasks = new ArrayList<>();
    }

    public Job(int job_id, int allocate_minutes, List<Task> tasks) {
        this.job_id = job_id;
        this.allocate_minutes = allocate_minutes;
        this.tasks = tasks;
    }

    public void write_files(Path jobs_folder){

        try {

            // create job id folder
            Path path = Paths.get(jobs_folder.toString(), String.format("%d", job_id));
            if (!Files.exists(path))
                Files.createDirectory(path);

            // write manual batch runner
            Path manual_file = Paths.get(path.toString(),"manual_job");
            PrintWriter manual_writer = new PrintWriter(manual_file.toFile(), "UTF-8");
            int total_nodes = tasks.stream().mapToInt(x->x.get_num_nodes()).sum();
//            int total_minutes = tasks.stream().mapToInt(x->x.max_run_minutes).max().getAsInt() * 2;
            int total_minutes = 100;
            manual_writer.write(get_manual_batch_string(path,job_id,total_nodes,total_minutes));
            for (Task task : tasks)
                manual_writer.write(String.format("mpiexec -N %d -n %d java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:$HOME/otm-mpi/out_mpijavac runner/RunnerMPI %s 2 1000 false &\n",
                        task.get_num_nodes(),
                        task.num_partitions,
                        task.prefix) );
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

    public void write_executable_file(Path path,String name,String str){
        try {
            Path task_file = Paths.get(path.toString(),name);
            PrintWriter task_writer = new PrintWriter(task_file.toFile(), "UTF-8");
            task_writer.write(str);
            task_writer.close();
//            Files.setPosixFilePermissions(task_file, PosixFilePermissions.fromString("rwxrwxr-x"));
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    public String get_job_string(Path path,int job_id){

        String errorfile = Paths.get(path.toString(),"std_error").toString();
        String outfile = Paths.get(path.toString(),"std_out").toString();
        String jobname = String.format("job%d",job_id);

        return String.format(
                "#!/bin/bash\n"+
                "#SBATCH --nodes=%d\n"+
                "#SBATCH --cpus-per-task=64\n"+
                "#SBATCH --time=00:%02d:00\n"+
                "#SBATCH --job-name=%s\n"+
                "#SBATCH --error=%s\n"+
                "#SBATCH --output=%s\n"+
                "#SBATCH --mail-user=gomes@berkeley.edu\n"+
                "#SBATCH --mail-type=ALL,TIME_LIMIT\n"+
                "#SBATCH --constraint=haswell\n"+
                "#SBATCH --qos=regular\n"+
                "#SBATCH --ntasks-per-node=1\n"+
                "#SBATCH --license=SCRATCH\n"+
                "#SBATCH --output=my_job.o%%j\n" +
                "export PATH=$PATH:/usr/common/tig/taskfarmer/1.5/bin:$(pwd)\n" +
                "export THREADS=32\n" +
                "runcommands.sh tasks", allocate_nodes,allocate_minutes,jobname,errorfile,outfile );
    }

    public String get_manual_batch_string(Path path,int job_id,int total_nodes,int total_minutes){

        String errorfile = Paths.get(path.toString(),"std_error").toString();
        String outfile = Paths.get(path.toString(),"std_out").toString();
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
                        "#SBATCH --error=%s\n"+
                        "#SBATCH --output=%s\n"+
                        "#SBATCH --mail-user=gomes@berkeley.edu\n"+
                        "#SBATCH --mail-type=ALL,TIME_LIMIT\n"+
                        "#SBATCH --constraint=haswell\n"+
                        "#SBATCH --qos=regular\n"+
                        "#SBATCH --ntasks-per-node=1\n"+
                        "#SBATCH --license=SCRATCH\n"+
                        "#SBATCH --output=my_job.o%%j\n"
                        , total_nodes,time,jobname,errorfile,outfile );
    }

    public String get_serial_run_string(){

        // RunnerSerial:
        // 0 boolean : write_beats_output
        // 1 config_file_name
        // 2 float : sim_dt
        // 3 float : out_dt
        // 4 float : duration
        // 5 output_folder

        // args:
        // $1 id
        // $2 config_file_name
        // $3 num partitions (ignored)

        return String.format(
                        "#!/bin/bash\n" +
                        "mkdir $SCRATCH/out/$1\n" +
                        "java -cp $BEATSSIMJAR:$HOME/beats-mpi/out_javac runner/RunnerSerial true $SCRATCH/cfg/$2 %.0f %.0f %.0f $SCRATCH/out/$1\n",
                MakeScripts.sim_dt,null,MakeScripts.duration);
    }

    public String get_mpi_run_string(){

        // RunnerTask:
        // 0 mpi id
        // 1 config file name

        // args:
        // $1 id
        // $2 config file
        // $3 num partitions

        return "#!/bin/bash\n" +
                "mpiexec -n $3 java -cp $BEATSSIMJAR:$HOME/beats-mpi/out_mpijavac runner/RunnerTask $1 $2\n";
    }

}
