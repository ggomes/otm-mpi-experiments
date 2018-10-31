package exp;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

import static java.util.stream.Collectors.toList;

public class MakeScripts {

    public static Path script_folder;
    public static Path split_files_folder;

    public static final int num_jobs = 6;
    public static final int job_minutes = 120;

    public static final float sim_dt = 2f;
    public static final float duration = 1000f;
    public static final int num_repetitions = 5;
    public static final int max_exponent = 7;

    public static int task_id = 0;
    public static int job_id = 0;

    public static void main(String[] args) {

        script_folder = Paths.get(Utils.get_root_path().toString(),"scripts");
        split_files_folder = Paths.get(Utils.get_root_path().toString(),"split_files");

        List<Task> tasks = create_tasks();
        make_splitter_script(tasks);
        List<Job> jobs = tasks_to_jobs(tasks);
        make_mpi_scripts(jobs);
    }

    public static List<Task> create_tasks() {

        List<Task> tasks = new ArrayList<>();

        for(String config : Utils.get_configs()){
            File config_file = new File(config);
            String config_name =  config_file.getName().replaceFirst("[.][^.]+$", "");
            int num_nodes = Integer.parseInt(config_name);

            for(double log_num_partitions=0;log_num_partitions<=max_exponent;log_num_partitions++) {

                int num_partitions = (int) Math.pow(2d,log_num_partitions);

                if( 2*num_partitions > num_nodes )
                    continue;

                if( num_nodes>5000 && num_partitions<4 )
                    continue;

                if( num_nodes>10000 && num_partitions<32 )
                    continue;

                Path out_path = Paths.get(split_files_folder.toString(), config_name,String.format("%d",num_partitions));
                Path prefix = Paths.get(out_path.toString(),String.format("%s_%d", config_name, num_partitions));

                for(int r=0;r<num_repetitions;r++)
                    tasks.add(new Task(task_id++,config,num_nodes,prefix,num_partitions,r));
            }
        }
        return tasks;

    }

    public static void make_splitter_script(List<Task> tasks) {

        // make the scripts
        Path script = Paths.get(script_folder.toString(),"split_all.sh");
        PrintWriter task_writer = null;
        try {
            task_writer = new PrintWriter(script.toFile(), "UTF-8");
            task_writer.write("#!/bin/bash\n");
            task_writer.write("cd $OTMMPIHOME/src/main/java\n");
            task_writer.write("javac -d $OTMMPIHOME/out_javac -cp $OTMSIMJAR:$OTMMPIHOME/lib/* metis/*.java metagraph/*.java translator/*.java xmlsplitter/*.java\n");
            task_writer.write("cd $OTMMPIHOME/out_javac\n");
            for(Task task : tasks){
                Path out_path = Paths.get(split_files_folder.toString(), task.get_config_name(),String.format("%d",task.num_partitions));
                task_writer.write(String.format("mkdir -p %s\n",out_path));
                File config_file = new File(task.config);
                task_writer.write(String.format("java -cp $OTMSIMJAR:$OTMMPIHOME/lib/*:. xmlsplitter.XMLSplitter %s %s %d\n",
                        task.get_prefix_generic(), Utils.to_generic(config_file.toString()), task.num_partitions));
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        } finally {
            task_writer.close();
        }

    }

    public static List<Job> tasks_to_jobs(List<Task> tasks){

        List<Job> jobs = new ArrayList<>();

        List<Integer> task_size = tasks.stream().map(x->x.get_size()).collect(toList());

        int total_size = tasks.stream().mapToInt(x->x.get_size()).sum();

        float avg_job_size =((float) total_size) / ((float)num_jobs);

        Job curr_job = new Job(job_id++,100);
        jobs.add(curr_job);
        for(Task task : tasks)
            if(curr_job.get_size()<avg_job_size)
                curr_job.tasks.add(task);
            else {
                curr_job = new Job(job_id++, 100);
                jobs.add(curr_job);
            }

//        Map<String,List<Task>> config_to_tasks = new HashMap<>();
//
//        for(Task task : tasks){
//            if(config_to_tasks.containsKey(task.get_config_name())){
//                config_to_tasks.get(task.get_config_name()).add(task);
//            } else {
//                List<Task> x = new ArrayList<>();
//                x.add(task);
//                config_to_tasks.put(task.get_config_name(),x);
//            }
//        }
//
//        // put them all into a single job
//        for(List<Task> e : config_to_tasks.values())
//            jobs.add(new Job(job_id++, 100, e));

        return jobs;
    }

    public static void make_mpi_scripts(List<Job> jobs){

        // write files
        Path jobs_folder = Utils.get_jobs_path();

        // write individual job files
        for(Job job : jobs)
            job.write_files(jobs_folder,sim_dt,duration,job_minutes);

        // write job and task list
        try {
            Path job_file = Paths.get(jobs_folder.toString(),"job_list.txt");
            PrintWriter job_writer = new PrintWriter(job_file.toFile(), "UTF-8");
            Path task_file = Paths.get(jobs_folder.toString(),"task_list.txt");
            PrintWriter task_writer = new PrintWriter(task_file.toFile(), "UTF-8");

            job_writer.write("#jobid,minute,nodes\n");
            task_writer.write("#taskid,type,jobid,prefix,n,repetition\n");
            for(Job job : jobs) {
                job_writer.write(String.format("%d,%d,%d\n", job.job_id, job.allocate_minutes, job.allocate_nodes));
                for(Task task : job.tasks)
                    task_writer.write(String.format("%d,%s,%d,%s,%d,%d\n",task.task_id,task.get_type(),job.job_id,task.get_prefix(),task.num_partitions,task.repetition));
            }
            job_writer.close();
            task_writer.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

    }

}
