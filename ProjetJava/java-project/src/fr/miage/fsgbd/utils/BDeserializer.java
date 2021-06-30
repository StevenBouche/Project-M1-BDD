package fr.miage.fsgbd.utils;

import fr.miage.fsgbd.bplustree.BTreePlus;

import java.io.*;

public class BDeserializer<K extends Comparable<K>, T>
{	
	  public BTreePlus<K,T> getArbre(String path)
	  {
	  	BTreePlus<K,T> arbre = null;
	    try {
	      
	      FileInputStream fichier = new FileInputStream(path);
	      ObjectInputStream ois = new ObjectInputStream(fichier);
	      arbre = (BTreePlus<K,T>) ois.readObject();
	      
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

