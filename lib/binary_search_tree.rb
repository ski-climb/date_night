require_relative 'node'

class BinarySearchTree
  attr_accessor :anchor_node,
                :current_node,
                :max_depth,
                :sorted_array,
                :number_of_movies_inserted

  def initialize
    @anchor_node = nil
    @current_node = nil
    @max_depth = 0
    @sorted_array = []
    @number_of_movies_inserted = 0
  end

  def insert(score:, title:)
    if anchor_node.nil?
      make_anchor_node(score, title)
      return anchor_node.depth
    end

    new_node = plinko_node_into_place(anchor_node, score, title)
    new_node.depth
  end

  def make_anchor_node(score, title)
    self.anchor_node = Node.new(score: score, title: title, depth: 0)
  end

  def plinko_node_into_place(node, score, title)
    compare_scores = score <=> node.score

    case compare_scores
    when 1 
      if node.right.nil?
        node.right = make_new_node(score, title, node.depth + 1)
      else
        plinko_node_into_place(node.right, score, title)
      end
    when -1
      if node.left.nil?
        node.left = make_new_node(score, title, node.depth + 1)
      else
        plinko_node_into_place(node.left, score, title)
      end
    when 0
      node
    end
  end

  def make_new_node(score, title, depth)
    if depth > max_depth
      self.max_depth = depth
    end
    Node.new(score: score, title: title, depth: depth)
  end

  def include?(score)
    node = find_node_by_score(anchor_node, score)
    !! node
  end

  def depth_of(score)
    node = find_node_by_score(anchor_node, score)
    node.depth
  end

  def find_node_by_score(node, score)
    compare_score = score <=> node.score
    
    case compare_score
    when 1
      if node.right.nil?
        false
      else
        find_node_by_score(node.right, score)
      end
    when -1
      if node.left.nil?
        false
      else
        find_node_by_score(node.left, score)
      end
    when 0
      node
    end
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
    insert_nodes = [
      node.left,
      node,
      node.right
    ]
    sorted_array[index] = insert_nodes
    compact_and_flatten
    if node.right
      add_child_nodes_to_array(node.right, sorted_array.index(node.right))
    end
    if node.left
      add_child_nodes_to_array(node.left, sorted_array.index(node.left))
    end

    return sorted_array
  end

  def compact_and_flatten
    sorted_array.compact!
    sorted_array.flatten!
  end

  def load(filename)
    path_to_file= '/Users/nick/turing/1module/projects/binary_search_tree/uploads/'
    file = "#{path_to_file}#{filename}"
    self.number_of_movies_inserted = 0
    begin
      File.readlines(file).each do |line|
        score = find_score(line)
        title = find_title(line)
        insert_new_movies(score, title)
      end
    rescue Errno::EISDIR
      return "No filename given.  Expecting a command of the form: `binary_search_tree.load('filename-here')`"
    rescue Errno::ENOENT
      return "File not present.  Please check your filename, #{filename}."
    else
      number_of_movies_inserted
    end
  end

  def find_score(line)
    line.scan(/\A(\d+)/).flatten.first.to_i
  end

  def find_title(line)
    line.scan(/,(.*)/).flatten.first.strip
  end

  def insert_new_movies(score, title)
    unless self.include?(score)
      self.number_of_movies_inserted += 1
      self.insert(score: score, title: title)
    end
  end

  def health(depth)

    # return [[score, 1 + number_of_child_nodes, percent_under_this_node]]
  end

end
