package fr.miage.fsgbd;

import fr.miage.fsgbd.bplustree.BPlusTree;

import java.io.*;

public class BDeserializer<K extends Comparable<K>, T>
{	
	  public BPlusTree<K,T> getArbre(String path)
	  {
	  	BPlusTree<K,T> arbre = null;
	    try {
	      
	      FileInputStream fichier = new FileInputStream(path);
	      ObjectInputStream ois = new ObjectInputStream(fichier);
	      arbre = (BPlusTree<K,T>) ois.readObject();
	      
	    } 
	    catch (java.io.IOException e) {
	      e.printStackTrace();
	    }
	    catch (ClassNotFoundException e) {
	      e.printStackTrace();
	    }
	    return arbre;
	   }
	
}

