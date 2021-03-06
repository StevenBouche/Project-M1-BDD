package fr.miage.fsgbd.bplustree;

import javax.swing.tree.DefaultMutableTreeNode;
import java.util.AbstractMap;
import java.util.Map.Entry;
import java.util.ArrayList;

public class BTreePlus<K extends Comparable<K>, T> implements java.io.Serializable {

	public Node<K,T> root;
	public int degree;

	public BTreePlus(int d){
		this.degree = d;
	}

	public T search(K key) {
		// Return if empty tree or key
		if(key == null || root == null) {
			return null;
		}
		// Look for leaf node that key is pointing to
		LeafNode<K,T> leaf = (LeafNode<K,T>)treeSearch(root, key);
					
		// Look for value in the leaf
		for(int i=0; i<leaf.keys.size(); i++) {
			if(key.compareTo(leaf.keys.get(i)) == 0) {
				return leaf.values.get(i);
			}
		}
					
		return null;
	}

	public T linearSearch(K key) {
		// Return if empty tree or key
		if(key == null || root == null) {
			return null;
		}

		// Look for leaf node as root
		LeafNode<K,T> leaf = searchFirstLeafNode(root);

		while(leaf != null){
			// Look for value in the leaf
			for(int i=0; i<leaf.keys.size(); i++) {
				if(key.compareTo(leaf.keys.get(i)) == 0) {
					return leaf.values.get(i);
				}
			}
			leaf = leaf.nextLeaf;
		}
		return null;
	}

	private LeafNode<K,T> searchFirstLeafNode(Node<K,T> node){
		if(node.isLeafNode)
			return (LeafNode<K,T>)node;
		return searchFirstLeafNode(((InternalNode<K,T>)node).children.get(0));
	}
	
	private Node<K,T> treeSearch(Node<K,T> node, K key) {
		if(node.isLeafNode) {
			return node;
		} 
		// The node is index node
		else {
			InternalNode<K,T> index = (InternalNode<K,T>)node;
			
			// K < K1, return treeSearch(P0, K)
			if(key.compareTo(index.keys.get(0)) < 0) {
				return treeSearch((Node<K,T>)index.children.get(0), key);
			}
			// K >= Km, return treeSearch(Pm, K), m = #entries
			else if(key.compareTo(index.keys.get(node.keys.size()-1)) >= 0) {
				return treeSearch((Node<K,T>)index.children.get(index.children.size()-1), key);
			}
			// Find i such that Ki <= K < K(i+1), return treeSearch(Pi,K)
			else {
				// Linear searching
				for(int i=0; i<index.keys.size()-1; i++) {
					if(key.compareTo(index.keys.get(i)) >= 0 && key.compareTo(index.keys.get(i+1)) < 0) {
						return treeSearch((Node<K,T>)index.children.get(i+1), key);
					}
				}
 			}
			return null;
		}
	}



	public void insert(K key, T value) {
		LeafNode<K,T> newLeaf = new LeafNode<K,T>(key, value, degree);
		Entry<K, Node<K,T>> entry = new AbstractMap.SimpleEntry<K, Node<K,T>>(key, newLeaf);
		
		// Insert entry into subtree with root node pointer
		if(root == null || root.keys.size() == 0) {
			root = entry.getValue();
		}
		
		// newChildEntry null initially, and null on return unless child is split
		Entry<K, Node<K,T>> newChildEntry = getChildEntry(root, entry, null);
		
		if(newChildEntry == null) {
			return;
		} else {
			InternalNode<K,T> newRoot = new InternalNode<K,T>(newChildEntry.getKey(), root, newChildEntry.getValue(), degree);
			root = newRoot;
			return;
		}
	}
	
	private Entry<K, Node<K,T>> getChildEntry(Node<K,T> node, Entry<K, Node<K,T>> entry, Entry<K, Node<K,T>> newChildEntry) {
		if(!node.isLeafNode) {
			// Choose subtree, find i such that Ki <= entry's key value < J(i+1)
			InternalNode<K,T> index = (InternalNode<K,T>) node;
			int i = 0;
			while(i < index.keys.size()) {
				if(entry.getKey().compareTo(index.keys.get(i)) < 0) {
					break;
				}
				i++;
			}
			// Recursively, insert entry
			newChildEntry = getChildEntry((Node<K,T>) index.children.get(i), entry, newChildEntry);
			
			// Usual case, didn't split child
			if(newChildEntry == null) {
				return null;
			} 
			// Split child case, must insert newChildEntry in node
			else {
				int j = 0;
				while (j < index.keys.size()) {
					if(newChildEntry.getKey().compareTo(index.keys.get(j)) < 0) {
						break;
					}
					j++;
				}
				
				index.insertSorted(newChildEntry, j);
				
				// Usual case, put newChildEntry on it, set newChildEntry to null, return
				if(!index.isOverflowed()) {
					return null;
				} 
				else{
					newChildEntry = splitIndexNode(index);
					
					// Root was just split
					if(index == root) {
						// Create new node and make tree's root-node pointer point to newRoot
						InternalNode<K,T> newRoot = new InternalNode<K,T>(newChildEntry.getKey(), root, newChildEntry.getValue(), degree);
						root = newRoot;
						return null;
					}
					return newChildEntry;
				}
			}
		}
		// Node pointer is a leaf node
		else {
			LeafNode<K,T> leaf = (LeafNode<K,T>)node;
			LeafNode<K,T> newLeaf = (LeafNode<K,T>)entry.getValue();
			
			leaf.insertSorted(entry.getKey(), newLeaf.values.get(0));
			
			// Usual case: leaf has space, put entry and set newChildEntry to null and return
			if(!leaf.isOverflowed()) {
				return null;
			}
			// Once in a while, the leaf is full
			else {
				newChildEntry = splitLeafNode(leaf);
				if(leaf == root) {
					InternalNode<K,T> newRoot = new InternalNode<K,T>(newChildEntry.getKey(), leaf, newChildEntry.getValue(), degree);
					root = newRoot;
					return null;
				}
				return newChildEntry;
			}
		}
	}

	public Entry<K, Node<K,T>> splitLeafNode(LeafNode<K,T> leaf) {
		ArrayList<K> newKeys = new ArrayList<K>();
		ArrayList<T> newValues = new ArrayList<T>();
		
		// The rest D entries move to brand new node
		for(int i = degree; i<=2* degree; i++) {
			newKeys.add(leaf.keys.get(i));
			newValues.add(leaf.values.get(i));
		}
		
		// First D entries stay
		for(int i = degree; i<=2* degree; i++) {
			leaf.keys.remove(leaf.keys.size()-1);
			leaf.values.remove(leaf.values.size()-1);
		}
		
		K splitKey = newKeys.get(0);
		LeafNode<K,T> rightNode = new LeafNode<K,T>(newKeys, newValues, degree);
		
		// Set sibling pointers
		LeafNode<K,T> tmp = leaf.nextLeaf;
		leaf.nextLeaf = rightNode;
		leaf.nextLeaf.previousLeaf = rightNode;
		rightNode.previousLeaf = leaf;
		rightNode.nextLeaf = tmp;
        
		Entry<K, Node<K,T>> newChildEntry = new AbstractMap.SimpleEntry<K, Node<K,T>>(splitKey, rightNode);
		
		return newChildEntry;
	}

	public Entry<K, Node<K,T>> splitIndexNode(InternalNode<K,T> index) {
		ArrayList<K> newKeys = new ArrayList<K>();
		ArrayList<Node<K,T>> newChildren = new ArrayList<Node<K,T>>();
		
		// Note difference with splitting leaf page, 2D+1 key values and 2D+2 node pointers
		K splitKey = index.keys.get(degree);
		index.keys.remove(degree);
		
		// First D key values and D+1 node pointers stay
		// Last D keys and D+1 pointers move to new node
		newChildren.add(index.children.get(degree +1));
		index.children.remove(degree +1);
		
		while(index.keys.size() > degree) {
			newKeys.add(index.keys.get(degree));
			index.keys.remove(degree);
			newChildren.add(index.children.get(degree +1));
			index.children.remove(degree +1);
		}

		InternalNode<K,T> rightNode = new InternalNode<K,T>(newKeys, newChildren, degree);
		Entry<K, Node<K,T>> newChildEntry = new AbstractMap.SimpleEntry<K, Node<K,T>>(splitKey, rightNode);

		return newChildEntry;
	}

	public void delete(K key) {
		if(key == null || root == null) {
			return;
		}

		// Check if entry key exist in the leaf node
		LeafNode<K,T> leaf = (LeafNode<K,T>)treeSearch(root, key);
		if(leaf == null) {
			return;
		}
		
		// Delete entry from subtree with root node pointer
		Entry<K, Node<K,T>> entry = new AbstractMap.SimpleEntry<K, Node<K,T>>(key, leaf);
		
		// oldChildEntry null initially, and null upon return unless child deleted
		Entry<K, Node<K,T>> oldChildEntry = deleteChildEntry(root, root, entry, null);
		
		// Readjust the root, no child is deleted
		if(oldChildEntry == null) {
			if(root.keys.size() == 0) {
				if(!root.isLeafNode) {
					root = ((InternalNode<K,T>) root).children.get(0);
				}
			}
			return;
		}
		// Child is deleted
		else {
			// Find empty node
			int i = 0;
			K oldKey = oldChildEntry.getKey();
			while(i < root.keys.size()) {
				if(oldKey.compareTo(root.keys.get(i)) == 0) {
					break;
				}
				i++;
			}
			// Return if empty node already discarded
			if(i == root.keys.size()) {
				return;
			}
			// Discard empty node
			root.keys.remove(i);
			((InternalNode<K,T>)root).children.remove(i+1);
			return;
		}
	}
	
	private Entry<K, Node<K,T>> deleteChildEntry(Node<K,T> parentNode, Node<K,T> node, 
			Entry<K, Node<K,T>> entry, Entry<K, Node<K,T>> oldChildEntry) {
		if(!node.isLeafNode) {
			// Choose subtree, find i such that Ki <= entry's key value < K(i+1)
			InternalNode<K,T> index = (InternalNode<K,T>)node;
			int i = 0;
			K entryKey = entry.getKey();
			while(i < index.keys.size()) {
				if(entryKey.compareTo(index.keys.get(i)) < 0) {
					break;
				}
				i++;
			}
			// Recursive delete
			oldChildEntry = deleteChildEntry(index, index.children.get(i), entry, oldChildEntry);
			
			// Usual case: child not deleted
			if(oldChildEntry == null) {
				return null;
			}
			// Discarded child node case
			else {
				int j = 0;
				K oldKey = oldChildEntry.getKey();
				while(j < index.keys.size()) {
					if(oldKey.compareTo(index.keys.get(j)) == 0) {
						break;
					}
					j++;
				}
				// Remove oldChildEntry from node
				index.keys.remove(j);
				index.children.remove(j+1);
				
				// Check for underflow, return null if empty
				if(!index.isUnderflowed() || index.keys.size() == 0) {
					// Node has entries to spare, delete doesn't go further
					return null; 
				}
				else {
					// Return if root
					if(index == root) {
						return oldChildEntry;
					}
					// Get sibling S using parent pointer
					int s = 0;
					K firstKey = index.keys.get(0);
					while(s < parentNode.keys.size()) {
						if(firstKey.compareTo(parentNode.keys.get(s)) < 0) {
							break;
						}
						s++;
					}
					// Handle index underflow
					int splitKeyPos;
					InternalNode<K,T> parent = (InternalNode<K,T>)parentNode;
					
					if(s > 0 && parent.children.get(s-1) != null) {
						splitKeyPos = handleIndexNodeUnderflow(
								(InternalNode<K,T>)parent.children.get(s-1), index, parent);
					} else {
						splitKeyPos = handleIndexNodeUnderflow(
								index, (InternalNode<K,T>)parent.children.get(s+1), parent);
					}
					// S has extra entries, set oldChildentry to null, return
					if(splitKeyPos == -1) {
						return null;
					}
					// Merge indexNode and S
					else {
						K parentKey = parentNode.keys.get(splitKeyPos);
						oldChildEntry = new AbstractMap.SimpleEntry<K, Node<K,T>>(parentKey, parentNode);
						return oldChildEntry;
					}
				}
			}
		}
		// The node is a leaf node
		else {
			LeafNode<K,T> leaf = (LeafNode<K,T>)node;
			// Look for value to delete
			for(int i=0; i<leaf.keys.size(); i++) {
				if(leaf.keys.get(i) == entry.getKey()) {
					leaf.keys.remove(i);
					leaf.values.remove(i);
					break;
				}
			}
			// Usual case: no underflow
			if(!leaf.isUnderflowed()) {
				return null;
			}
			// Once in a while, the leaf becomes underflow
			else {
				// Return if root
				if(leaf == root || leaf.keys.size() == 0) {
					return oldChildEntry;
				}
				// Handle leaf underflow
				int splitKeyPos;
				K firstKey = leaf.keys.get(0);
				K parentKey = parentNode.keys.get(0);
				
				if(leaf.previousLeaf != null && firstKey.compareTo(parentKey) >= 0) {
					splitKeyPos = handleLeafNodeUnderflow(leaf.previousLeaf, leaf, (InternalNode<K,T>)parentNode);
				} else {
					splitKeyPos = handleLeafNodeUnderflow(leaf, leaf.nextLeaf, (InternalNode<K,T>)parentNode);
				}
				// S has extra entries, set oldChildEntry to null, return
				if(splitKeyPos == -1) {
					return null;
				} 
				// Merge leaf and S
				else {
					parentKey = parentNode.keys.get(splitKeyPos);
					oldChildEntry = new AbstractMap.SimpleEntry<K, Node<K,T>>(parentKey, parentNode);
					return oldChildEntry;
				}	
			}
		}
	}

	public int handleLeafNodeUnderflow(LeafNode<K,T> left, LeafNode<K,T> right,
			InternalNode<K,T> parent) {
		// Find entry in parent for node on right
		int i = 0;
		K rKey = right.keys.get(0);
		while(i < parent.keys.size()) {
			if(rKey.compareTo(parent.keys.get(i)) < 0) {
				break;
			}
			i++;
		}	
		// Redistribute evenly between right and left nodes
		// If S has extra entries
		if(left.keys.size() + right.keys.size() >= 2* degree) {
			// Left node has more entries
			if(left.keys.size() > right.keys.size()) {
				while(left.keys.size() > degree) {
					right.keys.add(0, left.keys.get(left.keys.size()-1));
					right.values.add(0, left.values.get(left.keys.size()-1));
					left.keys.remove(left.keys.size()-1);
					left.values.remove(left.values.size()-1);
				}
			}
			// Right node has more entries
			else {
				while(left.keys.size() < degree) {
					left.keys.add(right.keys.get(0));
					left.values.add(right.values.get(0));
					right.keys.remove(0);
					right.values.remove(0);
				}
			}
			// Replace key value in parent entry by low-key in right node
			parent.keys.set(i-1, right.keys.get(0));
			
			return -1;
		}
		// No extra entries, return splitKeyPos
		else {
			// Move all entries from right to left node
			while(right.keys.size() > 0) {
				left.keys.add(right.keys.get(0));
				left.values.add(right.values.get(0));
				right.keys.remove(0);
				right.values.remove(0);
			}
			// Adjust sibling pointers
			if(right.nextLeaf != null) {
				right.nextLeaf.previousLeaf = left;
			}
			left.nextLeaf = right.nextLeaf;
			
			return i-1;
		}
	}

	public int handleIndexNodeUnderflow(InternalNode<K,T> leftIndex,
										InternalNode<K,T> rightIndex, InternalNode<K,T> parent) {
		// Find entry in parent for node on right
		int i = 0;
		K rKey = rightIndex.keys.get(0);
		while(i < parent.keys.size()) {
			if(rKey.compareTo(parent.keys.get(i)) < 0) {
				break;
			}
			i++;
		}
		// Redistribute evenly between node and S through parent
		// If S has extra entries
		if(leftIndex.keys.size() + rightIndex.keys.size() >= 2* degree) {
			// Left node has more entries
			if(leftIndex.keys.size() > rightIndex.keys.size()) {
				while(leftIndex.keys.size() > degree) {
					rightIndex.keys.add(0, parent.keys.get(i-1));
					rightIndex.children.add(leftIndex.children.get(leftIndex.children.size()-1));
					parent.keys.set(i-1, leftIndex.keys.get(leftIndex.keys.size()-1));
					leftIndex.keys.remove(leftIndex.keys.size()-1);
					leftIndex.children.remove(leftIndex.children.size()-1);
				}
			}
			// Right node has more entries
			else {
				while(leftIndex.keys.size() < degree) {
					leftIndex.keys.add(parent.keys.get(i-1));
					leftIndex.children.add(rightIndex.children.get(0));
					parent.keys.set(i-1, rightIndex.keys.get(0));
					rightIndex.keys.remove(0);
					rightIndex.children.remove(0);
				}
			}
			return -1;
		}
		// No extra entries, return spiltKeyPos
		else {
			leftIndex.keys.add(parent.keys.get(i-1));
			// Move all entries from right to left node
			while(rightIndex.keys.size() > 0) {
				leftIndex.keys.add(rightIndex.keys.get(0));
				leftIndex.children.add(rightIndex.children.get(0));
				rightIndex.keys.remove(0);
				rightIndex.children.remove(0);
			}
			leftIndex.children.add(rightIndex.children.get(0));
			rightIndex.children.remove(0);
			
			return i-1;
		}
	}

	public DefaultMutableTreeNode bArbreToJTree() {

		if(root == null){
			return new DefaultMutableTreeNode("", true);
		}
		else return bArbreToJTree(root);

	}

	private DefaultMutableTreeNode bArbreToJTree(Node<K,T> node) {

		StringBuilder txt = new StringBuilder();
		boolean internalInstance = node instanceof InternalNode;

		if(internalInstance){
			for (K key : ((InternalNode<K,T>)node).keys){
				txt.append("["+key.toString()+"]").append(" ");
			}
		} else {
			LeafNode<K,T> lNode = (LeafNode<K,T>) node;
			for(int i = 0; i < lNode.keys.size(); i++){
				String str = "[key="+lNode.keys.get(i)+",value="+lNode.values.get(i)+"]";
				txt.append(str).append(" ");
			}
		}

		DefaultMutableTreeNode racine2 = new DefaultMutableTreeNode(txt.toString(), true);

		if(internalInstance) {
			for (Node<K,T> fil : ((InternalNode<K,T>) node).children) {
				if (fil == null)
					break;
				else racine2.add(bArbreToJTree(fil));
			}
		}

		return racine2;
	}

}