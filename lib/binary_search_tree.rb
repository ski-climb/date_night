require_relative 'node'

class BinarySearchTree
  attr_accessor :anchor_node,
                :current_node,
                :max_depth,
                :sorted_array,
                :count

  def initialize
    @anchor_node = nil
    @current_node = nil
    @max_depth = 0
    @sorted_array = []
    @count = 0
  end

  def insert(score:, title:)

    unless anchor_node
      make_anchor_node(score, title)
      return anchor_node.depth
    end

    new_node = compare_to_node(anchor_node, score, title)

    new_node.depth
  end

  def compare_to_node(node, score, title)
    compare_scores = score <=> node.score

    case compare_scores
    when 1 
      if node.right.nil?
        node.right = make_new_node(score, title, node.depth + 1)
      else
        compare_to_node(node.right, score, title)
      end
    when -1
      if node.left.nil?
        node.left = make_new_node(score, title, node.depth + 1)
      else
        compare_to_node(node.left, score, title)
      end
    when 0
      node
    end
  end

  def make_anchor_node(score, title)
    self.anchor_node = Node.new(score: score, title: title, depth: 0)
  end

  def make_new_node(score, title, depth)
    if depth > max_depth
      self.max_depth = depth
    end
    Node.new(score: score, title: title, depth: depth)
  end

  def include?(score)
    if score > anchor_node.score
      if anchor_node.right
        !! find_node(anchor_node.right, score)
      else
        false
      end
    elsif score < anchor_node.score
      if anchor_node.left
        !! find_node(anchor_node.left, score)
      else
        false
      end
    else
      true
    end
  end

  def find_node(node, score)
    compare_score = score <=> node.score
    
    case compare_score
    when 1
      if node.right.nil?
        false
      else
        find_node(node.right, score)
      end
    when -1
      if node.left.nil?
        false
      else
        find_node(node.left, score)
      end
    when 0
      node
    end
  end

  def depth_of(score)
    node = find_node(anchor_node, score)
    node.depth
    # include?, insert, and depth_of should all share the common 'find' method
  end

  def max
    max_node = find_max(anchor_node)
    hash = { max_node.title => max_node.score }
  end

  def min
    min_node = find_min(anchor_node)
    hash = { min_node.title => min_node.score }
  end

  def find_max(node)
    if node.right.nil?
      return node
    else
      find_max(node.right)
    end
  end

  def find_min(node)
    if node.left.nil?
      return node
    else
      find_min(node.left)
    end
  end

  def sort
    if anchor_node.nil?
      []
    else
      self.sorted_array = []
      sorted_array << anchor_node
      add_child_nodes_to_array(anchor_node, 0)
      sorted_array.compact!
      sorted_array.map! do |node|
        node.as_hash
      end

      return sorted_array
    end
  end

  def add_child_nodes_to_array(node, index)
    inserted_nodes = [
      node.left,
      node,
      node.right
    ]
    sorted_array[index] = inserted_nodes
    compact_and_flatten
    unless node.right.nil?
      add_child_nodes_to_array(node.right, sorted_array.index(node.right))
    end
    unless node.left.nil?
      add_child_nodes_to_array(node.left, sorted_array.index(node.left))
    end

    return sorted_array
  end

  def compact_and_flatten
    sorted_array.compact!
    sorted_array.flatten!
  end

  def load(filename)
    path_to_filename = '/Users/nick/turing/1module/projects/binary_search_tree/uploads/'
    file = "#{path_to_filename}#{filename}"
    count = 0
    File.readlines(file).each do |line|
      score = line.scan(/\A(\d+)/).flatten.first.to_i
      title = line.scan(/,(.*)/).flatten.first.strip
      count += 1 if self.insert(score: score, title: title)
    end
    count
  end

  def health(depth)
    # should return an array (see assignment for this one)
  end

end
