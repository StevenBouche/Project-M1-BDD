package fr.miage.fsgbd.bplustree;

import java.util.ArrayList;
import java.util.List;
import java.util.Map.Entry;

public class IndexNode<K extends Comparable<K>, T> extends Node<K,T> implements java.io.Serializable {

	// m nodes
	protected ArrayList<Node<K,T>> children; // m+1 children

	public IndexNode(K key, Node<K,T> child0, Node<K,T> child1, int m) {
		super(m);
		isLeafNode = false;
		keys = new ArrayList<K>();
		keys.add(key);
		children = new ArrayList<Node<K,T>>();
		children.add(child0);
		children.add(child1);
	}

	public IndexNode(List<K> newKeys, List<Node<K,T>> newChildren, int m) {
		super(m);
		isLeafNode = false;
		keys = new ArrayList<K>(newKeys);
		children = new ArrayList<Node<K,T>>(newChildren);
	}

	/**
	 * insert the entry into this node at the specified index so that it still
	 * remains sorted
	 * 
	 * @param e
	 * @param index
	 */
	public void insertSorted(Entry<K, Node<K,T>> e, int index) {
		K key = e.getKey();
		Node<K,T> child = e.getValue();
		if (index >= keys.size()) {
			keys.add(key);
			children.add(child);
		} else {
			keys.add(index, key);
			children.add(index+1, child);
		}
	}

}
