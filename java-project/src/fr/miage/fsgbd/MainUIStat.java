package fr.miage.fsgbd;

import fr.miage.fsgbd.bplustree.BPlusTree;
import fr.miage.fsgbd.uistat.Stat;
import fr.miage.fsgbd.uistat.StatTableModel;
import fr.miage.fsgbd.uistat.UIStat;

import javax.swing.*;
import javax.swing.tree.DefaultTreeModel;
import java.awt.event.ActionEvent;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import java.util.function.Consumer;

public class MainUIStat {

    static class UIService{

        private final UIStat ui;

        private int nbLine;
        private int nbSearch;
        private int nbDegree;
        private int progress;

        private ArrayList<String> filesLine;
        private ArrayList<String[]> filesLineSplit;

        BPlusTree<String,Integer> tree;

        private StatTableModel model;

        public UIService(UIStat ui){
            this.ui = ui;
            init();
        }

        private void init(){

            ui.initComponents();

            updateEnableInput(false);

            ui.tree.setModel(new DefaultTreeModel(null));
            ui.tree.updateUI();

            ui.frame1.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            ui.frame1.setVisible(true);

            readFile();
            this.nbLine = filesLine.size();
            this.nbSearch = (this.nbLine * 5) / 100;
            this.nbDegree = 2;

            initTree();
            updateInput();
            actions();
            updateEnableInput(true);
        }

        private void updateEnableInput(boolean b){
            ui.start.setEnabled(b);
            ui.nbLigne.setEnabled(b);
            ui.nbSearch.setEnabled(b);
            ui.degreeTree.setEnabled(b);
        }

        private void initTree(){
            this.tree = new BPlusTree<>(this.nbDegree);
            for(int i = 0; i < this.nbLine; i++){
                String[] str = filesLineSplit.get(i);
                tree.insert(str[1], Integer.parseInt(str[0]));
            }
            ui.tree.setModel(new DefaultTreeModel(tree.bArbreToJTree()));
            ui.tree.updateUI();
        }

        private void readFile() {
            this.filesLine = new ArrayList<>();
            this.filesLineSplit = new ArrayList<>();
            try {
                FileReader reader = new FileReader("resource/myFile0.csv");
                readAllData(str -> {
                    filesLine.add(str);
                    filesLineSplit.add(str.split(","));
                    ui.textFile.append(str);
                    ui.textFile.append("\n");
                }, reader);

            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
        }

        private void readAllData(Consumer<String> callback, FileReader fileReader) {
            BufferedReader reader;
            try {
                reader = new BufferedReader(fileReader);
                String line = reader.readLine();

                while (line != null) {
                    callback.accept(line);
                    line = reader.readLine();
                }
                reader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        private void updateInput(){
            ui.nbLigne.setText(String.valueOf(this.nbLine));
            ui.nbSearch.setText(String.valueOf(this.nbSearch));
            ui.degreeTree.setText(String.valueOf(this.nbDegree));
        }

        private void actions(){
            ui.nbLigne.addActionListener(this::actionNbLine);
            ui.nbSearch.addActionListener(this::actionNbSearch);
            ui.degreeTree.addActionListener(this::actionDegreeTree);
            ui.start.addActionListener(this::actionStart);
        }

        private void actionStart(ActionEvent actionEvent) {
            updateEnableInput(false);
            ui.progressBar.setValue(0);
            ui.textLogIndex.setText("");
            ui.textLogLinear.setText("");
            ui.textTime.setText("");
            new Thread(taskSearch()).start();
        }

        private void actionDegreeTree(ActionEvent actionEvent) {
            nbDegree = Integer.parseInt(ui.degreeTree.getText());
            initTree();
        }

        private void actionNbSearch(ActionEvent actionEvent) {
            int max = this.filesLine.size();

            try{
                int inputSearch = Integer.parseInt(ui.nbSearch.getText());
                this.nbSearch = Math.min(inputSearch, max);

                if(this.nbSearch > this.nbLine)
                    this.nbSearch = this.nbLine;

                ui.nbSearch.setText(String.valueOf(this.nbSearch));

            } catch(Exception e){
                ui.nbLigne.setText(String.valueOf(max));
                this.nbLine = max;
            }
        }

        private void actionNbLine(ActionEvent event) {
            int max = this.filesLine.size();
            try{
                int inputLine = Integer.parseInt(ui.nbLigne.getText());
                this.nbLine = Math.min(inputLine, max);
                ui.nbLigne.setText(String.valueOf(this.nbLine));
            } catch(Exception e){
                ui.nbLigne.setText(String.valueOf(max));
                this.nbLine = max;
            }
            initTree();
        }

        private Runnable taskSearch(){
            return () -> {

                BPlusTree<String,Integer> treeThread = new BPlusTree<>(this.nbDegree);
                List<String> guid = new ArrayList<>();
                List<String> randomGuid = new ArrayList<>();

                int nbProgressBar = this.nbSearch * 2;
                int currentProgressBar = 0;

                for(int i = 0; i < this.nbLine; i++){
                    String[] data = filesLineSplit.get(i);
                    guid.add(data[1]);
                    tree.insert(data[1], Integer.parseInt(data[0]));
                }

                Random rand = new Random();
                for (int i = 0; i < this.nbSearch; i++) {
                    int randomIndex = rand.nextInt(guid.size());
                    randomGuid.add(guid.get(randomIndex));
                    guid.remove(randomIndex);
                }

                long start = 0, finish = 0;

                HashMap<String, Integer> resultTree = new HashMap<>();
                java.util.List<Long> timesTree = new ArrayList<>();

                for (String id : randomGuid) {
                    start = System.currentTimeMillis();
                    resultTree.put(id,tree.search(id));
                    finish = System.currentTimeMillis();
                    timesTree.add(finish - start);
                    currentProgressBar++;
                    updateProgressBarThread(currentProgressBar, nbProgressBar);
                }

                StringBuilder builder = new StringBuilder();
                resultTree.forEach((key, value) -> {
                    builder.append("key=").append(key).append(",value=").append(value).append("\n");
                });
                execUpdateUI(() -> ui.textLogIndex.append(builder.toString()));

                HashMap<String, Integer> resultLinear = new HashMap<>();
                java.util.List<Long> timesLinear = new ArrayList<>();

                for (String id : randomGuid) {
                    start = System.currentTimeMillis();
                    resultLinear.put(id,tree.linearSearch(id));
                    finish = System.currentTimeMillis();
                    timesLinear.add(finish - start);
                    currentProgressBar++;
                    updateProgressBarThread(currentProgressBar, nbProgressBar);
                }

                StringBuilder builderLinear = new StringBuilder();
                resultLinear.forEach((key, value) -> {
                    builderLinear.append("key=").append(key).append(",value=").append(value).append("\n");
                });
                execUpdateUI(() -> ui.textLogLinear.append(builderLinear.toString()));

                Stat s = new Stat();

                s.nbLine = this.nbLine;
                s.nbSearch = this.nbSearch;
                s.degree = this.nbDegree;

                s.minTree = timesTree.stream().min(Long::compareTo).get();
                s.maxTree = timesTree.stream().max(Long::compareTo).get();
                s.sumTree = timesTree.stream().reduce(0L, Long::sum);
                s.meanTree = s.sumTree / timesTree.size();

                s.minLinear = timesLinear.stream().min(Long::compareTo).get();
                s.maxLinear = timesLinear.stream().max(Long::compareTo).get();
                s.sumLinear = timesLinear.stream().reduce(0L, Long::sum);
                s.meanLinear = s.sumLinear / timesLinear.size();

                execUpdateUI(() -> {
                    ui.textTime.setText(s.toString());
                    updateEnableInput(true);
                });

            };
        }

        private void updateProgressBarThread(int current, int max){
            int c= progressBarCalcul(current, max);
            execUpdateUI(() -> ui.progressBar.setValue(c));
        }

        private int progressBarCalcul(int current, int max){
            return (current*100)/max;
        }

        private void execUpdateUI(Runnable r){
            SwingUtilities.invokeLater(r);
        }

    }

    static UIService manager;

    public static void main(String[] args) {

        UIStat ui = new UIStat();
        manager = new UIService(ui);

    }



}
