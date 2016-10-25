require_relative 'node'

class BinarySearchTree
  attr_accessor :anchor_node,
                :max_depth,
                :sorted_nodes,
                :number_of_movies_inserted,
                :size_of_tree,
                :nodes_at_depth,
                :leaf_nodes

  def height
    return max_depth + 1 unless anchor_node.nil?
    0
  end

  def insert(score, title)
    if anchor_node.nil?
      make_anchor_node(score, title)
      return anchor_node.depth
    end

    new_node = plinko_node_into_place(anchor_node, score, title)
    new_node.depth
  end

  def make_anchor_node(score, title)
    self.max_depth = 0
    self.anchor_node = Node.new(score, title, depth: 0)
  end

  def plinko_node_into_place(node, score, title)
    compare_scores = score <=> node.score

    case compare_scores
    when 1 
      insert_right(node, score, title)
    when -1
      insert_left(node, score, title)
    when 0
      node
    end
  end

  def insert_right(node, score, title)
    if node.right.nil?
      node.right = make_new_node(score, title, node.depth + 1)
    else
      plinko_node_into_place(node.right, score, title)
    end
  end

  def insert_left(node, score, title)
    if node.left.nil?
      node.left = make_new_node(score, title, node.depth + 1)
    else
      plinko_node_into_place(node.left, score, title)
    end
  end


  def make_new_node(score, title, depth)
    update_max_depth(depth) if depth > max_depth
    Node.new(score, title, depth: depth)
  end

  def update_max_depth(depth)
    self.max_depth = depth
  end

  def include?(score)
    node = find_by_score(score)
    !! node
  end

  def depth_of(score)
    node = find_by_score(score)
    node.depth
  end

  def find_by_score(score, node=anchor_node)
    compare_score = score <=> node.score
    
    case compare_score
    when 1
      find_by_score(score, node.right) unless node.right.nil?
    when -1
      find_by_score(score, node.left) unless node.left.nil?
    when 0
      node
    end
  end

  def max
    max_node = find_max
    max_node.as_hash
  end

  def min
    min_node = find_min
    min_node.as_hash
  end

  def find_max(node=anchor_node)
    return node if node.right.nil?
    find_max(node.right)
  end

  def find_min(node=anchor_node)
    return node if node.left.nil?
    find_min(node.left)
  end

  def sort
    if anchor_node.nil?
      []
    else
      self.sorted_nodes = []
      sorted_nodes << anchor_node
      collect_child_nodes(anchor_node, 0)
      format_contents
      return sorted_nodes
    end
  end

  def format_contents
    sorted_nodes.compact!
    sorted_nodes.map! do |node|
      node.as_hash
    end
  end

  def collect_child_nodes(node, index)
    insert_nodes = [
      node.left,
      node,
      node.right
    ]
    sorted_nodes[index] = insert_nodes
    compact_and_flatten
    if node.right
      collect_child_nodes(node.right, sorted_nodes.index(node.right))
    end
    if node.left
      collect_child_nodes(node.left, sorted_nodes.index(node.left))
    end

    return sorted_nodes
  end

  def compact_and_flatten
    sorted_nodes.compact!
    sorted_nodes.flatten!
  end

  def load(filename)
    path_to_file= '/Users/nick/turing/1module/projects/binary_search_tree/uploads/'
    file = "#{path_to_file}#{filename}"
    self.number_of_movies_inserted = 0
    begin
      load_contents(file)
    rescue Errno::EISDIR
      return "No filename given.  Expecting a command of the form: `binary_search_tree.load('filename-here')`"
    rescue Errno::ENOENT
      return "File not present.  Please check your filename, #{filename}."
    else
      number_of_movies_inserted
    end
  end

  def load_contents(file)
    File.readlines(file).each do |line|
      score = find_score(line)
      title = find_title(line)
      insert_new_movies(score, title)
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
      self.insert(score, title)
    end
  end

  def health(depth)
    return [] if anchor_node.nil?

    self.size_of_tree = count_child_nodes(anchor_node)
    self.nodes_at_depth = []

    nodes = find_by_depth(depth)
    present_nodes = []
    node_statistics(nodes, present_nodes)

    return sort_statistics(present_nodes)
  end

  def node_statistics(nodes, present_nodes)
    nodes.each do |node|
      size_of_branch = count_child_nodes(node)
      present_nodes << [
        node.score,
        count_child_nodes(node),
        ( 100 * size_of_branch / size_of_tree )
      ]
    end
    present_nodes
  end

  def sort_statistics(present_nodes)
    present_nodes.sort_by! do |node_results|
      node_results[1]
    end
  end

  def find_by_depth(depth, node=anchor_node)
    if node.depth < depth
      find_by_depth(depth, node.right) if node.right
      find_by_depth(depth, node.left) if node.left
    elsif node.depth == depth
      nodes_at_depth << node
    end
    nodes_at_depth
  end

  def count_child_nodes(node)
    self.sorted_nodes = []
    sorted_nodes << node
    child_nodes = collect_child_nodes(node, 0)
    child_nodes.compact.length
  end

  def leaves
    self.leaf_nodes = []
    if anchor_node
      all_the_leaves = find_leaves
      all_the_leaves.length
    else
      0
    end
  end

  def find_leaves(node=anchor_node)
    if node.left.nil? && node.right.nil?
      leaf_nodes << node
    else
      find_leaves(node.left) if node.left
      find_leaves(node.right) if node.right
    end
  end

  def delete(score)
    if score == anchor_node.score
      nodes = save_the_children(anchor_node)
      self.anchor_node = nil
      insert_children(nodes) if nodes
      return score
    end
    node = find_by_score(score)
    if node
      remove_child(node)
      return score
    end
  end

  def remove_child(node, parent_node=anchor_node)
    if parent_node.right == node
      nodes = save_the_children(node)
      remove_right_child(parent_node)
      insert_children(nodes) if nodes
    elsif parent_node.left == node
      nodes = save_the_children(node)
      remove_left_child(parent_node)
      insert_children(nodes) if nodes
    else 
      remove_child(node, parent_node.right) if parent_node.right
      remove_child(node, parent_node.left) if parent_node.left
    end
  end

  def save_the_children(node)
    self.sorted_nodes = []
    nodes = collect_child_nodes(node, 0)
    nodes.compact!
    nodes.reject! { |n| n.score == node.score }
    return nodes
  end

  def insert_children(nodes)
    nodes.shuffle!.shuffle!
    nodes.each do |node|
      self.insert(node.score, node.title)
    end
  end

  def remove_right_child(node)
    node.right = nil
  end

  def remove_left_child(node)
    node.left = nil
  end

end
