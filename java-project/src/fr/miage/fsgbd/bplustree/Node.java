package fr.miage.fsgbd.bplustree;

import java.util.ArrayList;

public class Node<K extends Comparable<K>, T> implements java.io.Serializable {

	protected boolean isLeafNode;
	protected ArrayList<K> keys;
	protected int m;

	public Node(int m){
		this.m = m;
	}

	public boolean isOverflowed() {
		return keys.size() > 2 * m;
	}

	public boolean isUnderflowed() {
		return keys.size() < m;
	}

}
