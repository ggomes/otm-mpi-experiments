package exp;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.nio.file.Path;
import java.nio.file.Paths;

public class RunSplitter {

    public static String OTMBASEJAR = "C:/Users/gomes/code/otm/otm-base/target/otm-base-1.0-SNAPSHOT-jar-with-dependencies.jar";
    public static String OTMSIMJAR = "C:/Users/gomes/code/otm/otm-sim/target/otm-sim-1.0-SNAPSHOT-jar-with-dependencies.jar";
    public static String JSONJAR = "C:/Users/gomes/code/otm/otm-mpi/lib/json-simple-1.1.1.jar";
    public static String OMPIHOME = "C:/Users/gomes/code/otm/otm-mpi";

    public static void main(String[] args) {

        String split_config_folder = "C:/Users/gomes/code/otm/otm-mpi-experiments/split_scripts";
        String script_folder = "C:/Users/gomes/code/otm/otm-mpi-experiments/split_scripts";

        Path task_file = Paths.get(script_folder,"split_script.sh");
        PrintWriter task_writer = null;
        try {
            task_writer = new PrintWriter(task_file.toFile(), "UTF-8");
            task_writer.write("#!/bin/bash\n");
            task_writer.write(String.format("cd %s/src/main/java\n",OMPIHOME));
            task_writer.write(String.format("javac -d %s/out_javac -cp %s:%s:%s/lib/* metis/*.java metagraph/*.java translator/*.java xmlsplitter/*.java\n",
                    OMPIHOME,OTMSIMJAR,OTMBASEJAR,OMPIHOME));
            task_writer.write(String.format("cd %s/out_javac\n",OMPIHOME));

            for(String config : Utils.get_configs()){
                for(double log_num_partitions=1;log_num_partitions<=7;log_num_partitions++) {
                    int num_partitions = (int) Math.pow(2d,log_num_partitions);
                    File config_file = new File(config);
                    String config_name =  config_file.getName().replaceFirst("[.][^.]+$", "");;
                    Path prefix = Paths.get(split_config_folder, String.format("%s_%d", config_name, num_partitions));
                    task_writer.write(String.format("java -cp %s:%s:%s:. xmlsplitter.XMLSplitter %s %s %d\n",
                            OTMSIMJAR,OTMBASEJAR, JSONJAR, prefix, config_file, num_partitions));
                }
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        } finally {
            task_writer.close();
        }

    }

}
