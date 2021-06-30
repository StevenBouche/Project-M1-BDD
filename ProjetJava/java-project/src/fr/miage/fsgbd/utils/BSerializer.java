package fr.miage.fsgbd.utils;

import fr.miage.fsgbd.bplustree.BTreePlus;

import java.io.*;
	
	public class BSerializer<K extends Comparable<K>, T>
	{	   
	  public BSerializer (BTreePlus<K,T> arbre, String path)
	  {	    
	    try {
	      FileOutputStream fichier = new FileOutputStream(path);
	      ObjectOutputStream oos = new ObjectOutputStream(fichier);
	      oos.writeObject(arbre);
	      oos.flush();
	      oos.close();
	    }
	    catch (java.io.IOException e) {
	      e.printStackTrace();
	    }
	  }
	}