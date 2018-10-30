package exp;

import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class Utils {

    public static List<String> get_configs(){
        Path config_path = get_config_path();
        List<String> fileNames = new ArrayList<>();
        try (DirectoryStream<Path> directoryStream = Files.newDirectoryStream(config_path)) {
            for (Path path : directoryStream) {
                fileNames.add(path.toString());
            }
        } catch (IOException ex) {}
        return fileNames;
    }

    public static Path get_config_path(){
        return Paths.get(get_root_path().toString(), "cfg");
    }

    public static Path get_jobs_path(){
        return Paths.get(get_root_path().toString(), "jobs");

    }

    public static Path get_root_path(){
        return Paths.get(System.getProperty("user.dir"));
    }
    
    public static String to_generic(String x){
        return x.replace(System.getenv("HOME"),"$HOME");
    }

}
