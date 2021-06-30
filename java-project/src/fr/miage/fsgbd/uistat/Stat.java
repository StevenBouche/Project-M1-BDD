package fr.miage.fsgbd.uistat;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;

public class Stat {

    public int nbLine = 0;
    public int nbSearch = 0;
    public int degree = 0;
    public long minTree = 0L;
    public long maxTree = 0L;
    public long sumTree = 0L;
    public long meanTree = 0L;
    public long minLinear = 0L;
    public long maxLinear = 0L;
    public long sumLinear = 0L;
    public long meanLinear = 0L;
    public long minFile = 0L;
    public long maxFile = 0L;
    public long sumFile = 0L;
    public long meanFile = 0L;

    public Stat(){

    }

    public static void save(String path, List<Stat> data) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        mapper.writeValue(Paths.get(path).toFile(), data);
    }

    @Override
    public String toString() {
        return
                "nbLine=" + nbLine +
                "\n nbSearch=" + nbSearch +
                "\n degree=" + degree +
                "\n minTree=" + minTree +
                "\n maxTree=" + maxTree +
                "\n sumTree=" + sumTree +
                "\n meanTree=" + meanTree +
                "\n minLinear=" + minLinear +
                "\n maxLinear=" + maxLinear +
                "\n sumLinear=" + sumLinear +
                "\n meanLinear=" + meanLinear;
    }
}
