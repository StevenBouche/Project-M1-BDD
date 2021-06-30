package fr.miage.fsgbd;
import fr.miage.fsgbd.bplustree.BTreePlus;
import fr.miage.fsgbd.uistat.Stat;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.function.Consumer;
import java.util.function.Predicate;
import java.util.stream.Stream;

public class StatIndex {

    public static void main(String args[]) throws IOException {

        List<Stat> stats = new ArrayList<>();

        stats.add(makeStat(10000,5000, 2));
        stats.add(makeStat(30000,5000, 2));
        stats.add(makeStat(50000,5000, 2));
        stats.add(makeStat(70000,5000, 2));
        stats.add(makeStat(90000,5000, 2));
        stats.add(makeStat(110000,5000, 2));
        stats.add(makeStat(130000,5000, 2));
        stats.add(makeStat(150000,5000, 2));
        stats.add(makeStat(170000,5000, 2));
        stats.add(makeStat(190000,5000, 2));

        Stat.save("resource/stat.json", stats);
    }

    static Stat makeStat(int nbLine, int nbRandom, int degree) throws IOException {

        BTreePlus<String,Integer> tree = new BTreePlus<>(degree);
        List<String> guid = new ArrayList<>();
        List<String> randomGuid = new ArrayList<>();
        FileReader reader = new FileReader("resource/myFile0.csv");

        readData((data) -> {
            String[] str = data.split(",");
            tree.insert(str[1], Integer.parseInt(str[0]));
            guid.add(str[1]);
        }, reader, nbLine);

        Random rand = new Random();
        for (int i = 0; i < nbRandom; i++) {
            int randomIndex = rand.nextInt(guid.size());
            randomGuid.add(guid.get(randomIndex));
            guid.remove(randomIndex);
        }

        long start = 0, finish = 0;

        HashMap<String, Integer> resultTree = new HashMap<>();
        List<Long> timesTree = new ArrayList<>();

        for (String id : randomGuid) {
            start = System.currentTimeMillis();
            resultTree.put(id,tree.search(id));
            finish = System.currentTimeMillis();
            timesTree.add(finish - start);
        }

        HashMap<String, Integer> resultLinear = new HashMap<>();
        List<Long> timesLinear = new ArrayList<>();

        for (String id : randomGuid) {
            start = System.currentTimeMillis();
            resultLinear.put(id,tree.linearSearch(id));
            finish = System.currentTimeMillis();
            timesLinear.add(finish - start);
        }

        HashMap<String, Integer> result = new HashMap<>();
        List<Long> times = new ArrayList<>();

        for (String id : randomGuid) {
            start = System.currentTimeMillis();
            searchFileData(
                    line ->  id.equals(line[1]),
                    line -> result.put(id, Integer.parseInt(line[0])),
                    ",",
                    nbLine
            );
            finish = System.currentTimeMillis();
            times.add(finish - start);
        }

        Stat s = new Stat();

        s.nbLine = nbLine;
        s.nbSearch = nbRandom;
        s.degree = degree;

        s.minTree = timesTree.stream().min(Long::compareTo).get();
        s.maxTree = timesTree.stream().max(Long::compareTo).get();
        s.sumTree = timesTree.stream().reduce(0L, Long::sum);
        s.meanTree = s.sumTree / timesTree.size();

        s.minLinear = timesLinear.stream().min(Long::compareTo).get();
        s.maxLinear = timesLinear.stream().max(Long::compareTo).get();
        s.sumLinear = timesLinear.stream().reduce(0L, Long::sum);
        s.meanLinear = s.sumLinear / timesLinear.size();

        s.minFile = times.stream().min(Long::compareTo).get();
        s.maxFile = times.stream().max(Long::compareTo).get();
        s.sumFile = times.stream().reduce(0L, Long::sum);
        s.meanFile = s.sumFile / times.size();

        return s;
    }

    static void readData(Consumer<String> callback, FileReader fileReader, int nbLine) throws IOException {
        BufferedReader reader;
        try {
            reader = new BufferedReader(fileReader);
            String line = reader.readLine();
            int i = 0;
            while (line != null && i <= nbLine) {
                callback.accept(line);
                line = reader.readLine();
                i++;
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    static void searchFileData(Predicate<String[]> condition, Consumer<String[]> callback, String separator, int nbLine) throws IOException {
        BufferedReader reader;
        try {
            reader = new BufferedReader(new FileReader("resource/myFile0.csv"));
            String line = reader.readLine();
            int i = 0;
            while (line != null && i <= nbLine) {
                String[] str = line.split(separator);
                if(condition.test(str)){
                    callback.accept(str);
                    break;
                }
                line = reader.readLine();
                i++;
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    static String selectLineFile(int index){
        String line;
        try (Stream<String> lines = Files.lines(Paths.get("resource/myFile0.csv"))) {
            line = lines.skip(index-1).findFirst().get();
            System.out.println(line);
            return line;
        }
        catch(IOException e){
            System.out.println(e);
        }
        return null;
    }

}
