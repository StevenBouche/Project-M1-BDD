/*
 * Created by JFormDesigner on Wed Jun 30 17:13:18 CEST 2021
 */

package fr.miage.fsgbd.uistat;

import java.awt.*;
import javax.swing.*;

/**
 * @author unknown
 */
public class UIStat  {

    public void initComponents() {
        // JFormDesigner - Component initialization - DO NOT MODIFY  //GEN-BEGIN:initComponents
        // Generated using JFormDesigner Evaluation license - unknown
        frame1 = new JFrame();
        scrollPane2 = new JScrollPane();
        tree = new JTree();
        scrollPane3 = new JScrollPane();
        textFile = new JTextArea();
        scrollPane4 = new JScrollPane();
        textTime = new JTextArea();
        scrollPane5 = new JScrollPane();
        textLogIndex = new JTextArea();
        nbLigne = new JTextField();
        label1 = new JLabel();
        label2 = new JLabel();
        nbSearch = new JTextField();
        label3 = new JLabel();
        degreeTree = new JTextField();
        progressBar = new JProgressBar();
        start = new JButton();
        scrollPane6 = new JScrollPane();
        textLogLinear = new JTextArea();
        label4 = new JLabel();
        label5 = new JLabel();
        label6 = new JLabel();
        label7 = new JLabel();
        label8 = new JLabel();

        //======== frame1 ========
        {
            frame1.setResizable(false);
            var frame1ContentPane = frame1.getContentPane();
            frame1ContentPane.setLayout(null);

            //======== scrollPane2 ========
            {
                scrollPane2.setViewportView(tree);
            }
            frame1ContentPane.add(scrollPane2);
            scrollPane2.setBounds(15, 440, 625, 290);

            //======== scrollPane3 ========
            {

                //---- textFile ----
                textFile.setEditable(false);
                scrollPane3.setViewportView(textFile);
            }
            frame1ContentPane.add(scrollPane3);
            scrollPane3.setBounds(665, 440, 625, 290);

            //======== scrollPane4 ========
            {
                scrollPane4.setViewportView(textTime);
            }
            frame1ContentPane.add(scrollPane4);
            scrollPane4.setBounds(15, 145, 625, 245);

            //======== scrollPane5 ========
            {

                //---- textLogIndex ----
                textLogIndex.setEditable(false);
                scrollPane5.setViewportView(textLogIndex);
            }
            frame1ContentPane.add(scrollPane5);
            scrollPane5.setBounds(665, 147, 305, 243);
            frame1ContentPane.add(nbLigne);
            nbLigne.setBounds(260, 15, 160, 30);

            //---- label1 ----
            label1.setText("Nombre de lignes :");
            frame1ContentPane.add(label1);
            label1.setBounds(140, 10, 110, 40);

            //---- label2 ----
            label2.setText("Nombre de recherche :");
            frame1ContentPane.add(label2);
            label2.setBounds(455, 10, 145, 40);
            frame1ContentPane.add(nbSearch);
            nbSearch.setBounds(600, 15, 160, 30);

            //---- label3 ----
            label3.setText("degree arbre : ");
            frame1ContentPane.add(label3);
            label3.setBounds(790, 10, 83, 40);
            frame1ContentPane.add(degreeTree);
            degreeTree.setBounds(890, 15, 160, 30);
            frame1ContentPane.add(progressBar);
            progressBar.setBounds(95, 55, 1130, 35);

            //---- start ----
            start.setText("Start");
            frame1ContentPane.add(start);
            start.setBounds(1095, 15, 120, start.getPreferredSize().height);

            //======== scrollPane6 ========
            {

                //---- textLogLinear ----
                textLogLinear.setEditable(false);
                scrollPane6.setViewportView(textLogLinear);
            }
            frame1ContentPane.add(scrollPane6);
            scrollPane6.setBounds(990, 147, 295, 243);

            //---- label4 ----
            label4.setText("B+ tree visualisation");
            label4.setHorizontalAlignment(SwingConstants.CENTER);
            frame1ContentPane.add(label4);
            label4.setBounds(15, 400, 625, 35);

            //---- label5 ----
            label5.setText("Fichier visualisation");
            label5.setHorizontalAlignment(SwingConstants.CENTER);
            frame1ContentPane.add(label5);
            label5.setBounds(665, 400, 625, 35);

            //---- label6 ----
            label6.setText("Temps d'\u00e9xecution");
            label6.setHorizontalAlignment(SwingConstants.CENTER);
            frame1ContentPane.add(label6);
            label6.setBounds(15, 100, 625, 35);

            //---- label7 ----
            label7.setText("R\u00e9sultat recherche par index");
            label7.setHorizontalAlignment(SwingConstants.CENTER);
            frame1ContentPane.add(label7);
            label7.setBounds(665, 100, 305, 35);

            //---- label8 ----
            label8.setText("R\u00e9sultat recherche lin\u00e9aire");
            label8.setHorizontalAlignment(SwingConstants.CENTER);
            frame1ContentPane.add(label8);
            label8.setBounds(990, 100, 305, 35);

            frame1ContentPane.setPreferredSize(new Dimension(1310, 780));
            frame1.pack();
            frame1.setLocationRelativeTo(frame1.getOwner());
        }
        // JFormDesigner - End of component initialization  //GEN-END:initComponents
    }

    // JFormDesigner - Variables declaration - DO NOT MODIFY  //GEN-BEGIN:variables
    // Generated using JFormDesigner Evaluation license - unknown
    public JFrame frame1;
    private JScrollPane scrollPane2;
    public JTree tree;
    private JScrollPane scrollPane3;
    public JTextArea textFile;
    private JScrollPane scrollPane4;
    public JTextArea textTime;
    private JScrollPane scrollPane5;
    public JTextArea textLogIndex;
    public JTextField nbLigne;
    private JLabel label1;
    private JLabel label2;
    public JTextField nbSearch;
    private JLabel label3;
    public JTextField degreeTree;
    public JProgressBar progressBar;
    public JButton start;
    private JScrollPane scrollPane6;
    public JTextArea textLogLinear;
    private JLabel label4;
    private JLabel label5;
    private JLabel label6;
    private JLabel label7;
    private JLabel label8;
    // JFormDesigner - End of variables declaration  //GEN-END:variables
}
