gem 'minitest', '~> 5.9'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/node'
require_relative '../lib/binary_search_tree'

require 'pry'

class BinarySearchTreeTest < Minitest::Test

  def setup
    @tree = BinarySearchTree.new
    @tree.insert(50, "Anchor")
  end

  def test_anchor_node_is_the_first_entry
    assert @tree.anchor_node
    assert_equal 0, @tree.anchor_node.depth
    assert_equal 1, @tree.height
    assert_equal 50, @tree.anchor_node.score
    assert_equal "Anchor", @tree.anchor_node.title
  end

  def test_it_sorts_a_higher_score_to_the_right
    @tree.insert(70, "To the Right")
    assert_equal "To the Right", @tree.anchor_node.right.title
    assert_equal 1, @tree.anchor_node.right.depth
  end

  def test_it_sorts_a_lower_score_to_the_left
    @tree.insert(10, "To the Left")
    assert_equal "To the Left", @tree.anchor_node.left.title
    assert_equal 1, @tree.anchor_node.left.depth
  end

  def test_it_inserts_two_higher_scores_on_the_right
    @tree.insert(70, "To the Right")
    @tree.insert(90, "To the Right Right")
    assert_equal "To the Right", @tree.anchor_node.right.title
    assert_equal "To the Right Right", @tree.anchor_node.right.right.title
    assert_equal 2, @tree.anchor_node.right.right.depth
    assert_equal 2, @tree.max_depth
  end

  def test_it_inserts_two_lower_scores_on_the_left
    @tree.insert(30, "To the Left")
    @tree.insert(10, "To the Left Left")
    assert_equal "To the Left", @tree.anchor_node.left.title
    assert_equal "To the Left Left", @tree.anchor_node.left.left.title
    assert_equal 2, @tree.anchor_node.left.left.depth
  end

  def test_it_passes_given_example_for_insert
    given_tree = BinarySearchTree.new
    assert_equal 0, given_tree.insert(61, "Bill & Ted's Excellent Adventure")
    assert_equal 1, given_tree.insert(16, "Johnny English")
    assert_equal 1, given_tree.insert(92, "Sharknado 3")
    assert_equal 2, given_tree.insert(50, "Hannibal Buress: Animal Furnace")
  end

  def test_it_passes_given_example_for_include?
    given_tree = BinarySearchTree.new
    assert_equal 0, given_tree.insert(61, "Bill & Ted's Excellent Adventure")
    assert_equal 1, given_tree.insert(16, "Johnny English")
    assert_equal 1, given_tree.insert(92, "Sharknado 3")
    assert_equal 2, given_tree.insert(50, "Hannibal Buress: Animal Furnace")
    assert given_tree.include?(16)
    refute given_tree.include?(72)
  end

  def test_it_passes_given_example_for_depth_of
    given_tree = BinarySearchTree.new
    assert_equal 0, given_tree.insert(61, "Bill & Ted's Excellent Adventure")
    assert_equal 1, given_tree.insert(16, "Johnny English")
    assert_equal 1, given_tree.insert(92, "Sharknado 3")
    assert_equal 2, given_tree.insert(50, "Hannibal Buress: Animal Furnace")
    assert_equal 1, given_tree.depth_of(92)
    assert_equal 2, given_tree.depth_of(50)
  end

  def test_it_passes_given_example_for_max_and_min
    given_tree = BinarySearchTree.new
    assert_equal 0, given_tree.insert(61, "Bill & Ted's Excellent Adventure")
    assert_equal 1, given_tree.insert(16, "Johnny English")
    assert_equal 1, given_tree.insert(92, "Sharknado 3")
    assert_equal 2, given_tree.insert(50, "Hannibal Buress: Animal Furnace")
    assert_equal({ "Sharknado 3" => 92 }, given_tree.max)
    assert_equal({ "Johnny English" => 16 }, given_tree.min)
  end

  def test_it_passes_given_example_for_sort
    given_tree = BinarySearchTree.new
    assert_equal 0, given_tree.insert(61, "Bill & Ted's Excellent Adventure")
    assert_equal 1, given_tree.insert(16, "Johnny English")
    assert_equal 1, given_tree.insert(92, "Sharknado 3")
    assert_equal 2, given_tree.insert(50, "Hannibal Buress: Animal Furnace")
    assert_equal [
      {"Johnny English"=>16},
      {"Hannibal Buress: Animal Furnace"=>50},
      {"Bill & Ted's Excellent Adventure"=>61},
      {"Sharknado 3"=>92}
    ], given_tree.sort
  end

  def test_it_does_not_insert_new_nodes_for_scores_which_alredy_exist
    @tree.insert(70, "To the Right")
    assert_equal "To the Right", @tree.anchor_node.right.title
    @tree.insert(70, "Duplicate Score")
    assert_equal "To the Right", @tree.anchor_node.right.title
    refute_equal "Duplicate Score", @tree.anchor_node.right.title
  end

  def test_it_inserts_higher_and_lower_scores_properly
    @tree.insert(90, "To the Right")
    @tree.insert(80, "To the Right, then Left")
    assert_equal "To the Right", @tree.anchor_node.right.title
    assert_equal "To the Right, then Left", @tree.anchor_node.right.left.title
    assert_equal 2, @tree.anchor_node.right.left.depth
  end

  def test_the_binary_tree_can_sort_and_accommodate_many_movies
    scores = (1..1000).to_a.shuffle!
    scores.each do |score|
      @tree.insert(score, "Just a Random Title")
    end
    assert @tree.max_depth > 15
    assert @tree.include?(300)
    assert @tree.include?(899)
    refute @tree.include?(1001)
    assert_equal 1000, @tree.sort.length
  end

  def test_it_returns_true_if_searching_for_a_movie_score_which_is_included_in_tree
    assert @tree.include?(50)
  end

  def test_it_returns_false_if_searching_for_a_movie_score_which_is_not_included_in_tree
    refute @tree.include?(1000)
  end

  def test_it_finds_sorted_movies_at_any_depth_in_tree_based_on_the_movie_score
    scores = (0..95).step(5).to_a
    scores.each do |score|
      @tree.insert(score, "Just a Title")
    end
    assert_equal true, @tree.include?(20)
    assert_equal true, @tree.include?(95)
    refute @tree.include?(21)
    refute @tree.include?(96)
  end

  def test_it_finds_the_depth_of_the_given_movie
    assert_equal 0, @tree.anchor_node.depth
    @tree.insert(14, "Depth of One")
    @tree.insert(44, "Depth of Two")
    assert_equal 1, @tree.depth_of(14)
    assert_equal 2, @tree.depth_of(44)
  end

  def test_it_finds_the_movie_with_the_highest_score
    scores = (5..95).step(5).to_a.shuffle!
    scores.each do |score|
      @tree.insert(score, "Just a Title")
    end
    assert_equal({ "Just a Title" => 95 }, @tree.max)
  end

  def test_it_finds_the_movie_with_the_lowest_score
    scores = (5..95).step(5).to_a.shuffle!
    scores.each do |score|
      @tree.insert(score, "Just a Title")
    end
    assert_equal({ "Just a Title" => 5 }, @tree.min)
  end

  def test_it_returns_an_empty_array_when_sorting_an_empty_tree
    empty_tree = BinarySearchTree.new
    assert empty_tree
    assert_equal [], empty_tree.sort
  end

  def test_it_sorts_a_tree_with_one_element
    assert_equal 0, @tree.max_depth
    assert_equal [{ "Anchor" => 50 }], @tree.sort
  end

  def test_it_sorts_a_tree_with_two_elements
    @tree.insert(90, "A Second Movie")
    assert_equal 1, @tree.max_depth
    sorted_array = [
      { "Anchor" => 50 },
      { "A Second Movie" => 90 }
    ]
    assert_equal sorted_array, @tree.sort
  end

  def test_it_sorts_a_tree_with_10_elements
    scores = (11..99).step(11).to_a.shuffle!
    scores.each do |score|
      @tree.insert(score, "Test Title")
    end
    sorted_array = [
      { "Test Title" => 11 },
      { "Test Title" => 22 },
      { "Test Title" => 33 },
      { "Test Title" => 44 },
      { "Anchor" => 50 },
      { "Test Title" => 55 },
      { "Test Title" => 66 },
      { "Test Title" => 77 },
      { "Test Title" => 88 },
      { "Test Title" => 99 }
    ]
    assert_equal sorted_array, @tree.sort
  end

  def test_it_shows_an_error_message_when_file_does_not_exist
    filename = 'asdf.txt'
    bad_filename_error_message = "File not present.  Please check your filename, #{filename}."
    assert_equal bad_filename_error_message, @tree.load(filename)
  end

  def test_it_shows_an_error_message_when_filename_is_blank
    no_filename_error_message = "No filename given.  Expecting a command of the form: `binary_search_tree.load('filename-here')`"
    assert_equal no_filename_error_message, @tree.load('')
  end

  def test_it_loads_zero_movies_when_a_file_has_no_movies_in_it
    assert_equal 0, @tree.load('empty_file.txt')
  end

  def test_it_loads_movies_from_a_well_formatted_file
    assert_equal 98, @tree.load('movies.txt')
  end

  def test_it_does_not_insert_a_loaded_movie_to_tree_when_score_already_exists
    @tree.insert(75, 'French Dirty')
    assert @tree.include?(75)
    assert_equal 2, @tree.sort.length
    assert_equal 97, @tree.load('movies.txt')
    assert_equal 99, @tree.sort.length
  end

  def test_it_returns_the_health_of_a_tree_with_zero_movies
    blank_tree = BinarySearchTree.new
    assert_equal [], blank_tree.health(0)
  end

  def test_it_returns_the_health_of_a_tree_with_one_movie
    assert_equal [[50, 1, 100]], @tree.health(0)
  end

  def test_it_returns_the_health_of_a_tree_with_three_movies
    @tree.insert(70, "Cat in the Hat")
    @tree.insert(30, "Modest Mouse")
    assert_equal [[50, 3, 100]], @tree.health(0)
    assert_equal [[70, 1, 33], [30, 1, 33]], @tree.health(1)
  end

  def test_it_passes_given_example_for_health
    healthy_tree = BinarySearchTree.new
    healthy_tree.insert(98, "Animals United")
    healthy_tree.insert(58, "Armageddon")
    healthy_tree.insert(36, "Bill & Ted's Bogus Journey")
    healthy_tree.insert(93, "Bill & Ted's Excellent Adventure")
    healthy_tree.insert(86, "Charlie's Angels")
    healthy_tree.insert(38, "Charlie's Country")
    healthy_tree.insert(69, "Collateral Damage")
    assert_equal [[98, 7, 100]], healthy_tree.health(0)
    assert_equal [[58, 6, 85]], healthy_tree.health(1)
    assert_equal [[36, 2, 28], [93, 3, 42]], healthy_tree.health(2)
  end

  def test_an_empty_tree_returns_a_height_of_zero
    empty_tree = BinarySearchTree.new
    assert_equal 0, empty_tree.height
  end

  def test_a_tree_with_only_an_anchor_node_returns_a_height_of_one
    assert_equal 1, @tree.height
  end

  def test_it_passes_given_example_for_height
    tall_tree = BinarySearchTree.new
    tall_tree.insert(61, "Bill & Ted's Excellent Adventure")
    tall_tree.insert(16, "Johnny English")
    tall_tree.insert(92, "Sharknado 3")
    tall_tree.insert(50, "Hannibal Buress: Animal Furnace")
    assert_equal 3, tall_tree.height
  end

  def test_it_can_have_deep_trees
    high_movie_scores = (51..151).to_a
    high_movie_scores.each do |score|
      @tree.insert(score, "Fast and Furious #{score}")
    end
    assert_equal 102, @tree.height
    assert_equal({ "Fast and Furious 151" => 151 }, @tree.max)
  end

  def test_a_tree_with_no_movies_has_zero_leaves
    empty_tree = BinarySearchTree.new
    assert_equal 0, empty_tree.leaves
  end

  def test_a_tree_with_one_movie_has_one_leaf
    assert_equal 1, @tree.leaves
  end

  def test_a_tree_with_two_movies_has_two_leaves
    @tree.insert(100, "Second node")
    assert_equal 1, @tree.leaves
  end

  def test_a_tree_with_only_right_nodes_has_only_one_leaf
    @tree.insert(60, "To the right only")
    @tree.insert(70, "To the right only")
    @tree.insert(80, "To the right only")
    @tree.insert(90, "To the right only")
    assert_equal 1, @tree.leaves
  end

  def test_a_tree_with_one_node_on_either_side_of_the_anchor_has_two_leaves
    @tree.insert(10, "To the Left")
    @tree.insert(100, "To the Right")
    assert_equal 2, @tree.leaves
  end

  def test_it_passes_given_example_for_counting_leaves
    tall_tree = BinarySearchTree.new
    tall_tree.insert(61, "Bill & Ted's Excellent Adventure")
    tall_tree.insert(16, "Johnny English")
    tall_tree.insert(92, "Sharknado 3")
    tall_tree.insert(50, "Hannibal Buress: Animal Furnace")
    assert_equal 2, tall_tree.leaves
  end

  def test_attempting_to_delete_a_node_which_is_not_in_the_tree_returns_nil
    assert_nil @tree.delete(1000)
  end

  def test_deleting_a_node_returns_the_score_for_the_deleted_node
    @tree.insert(100, "I'm a leaf!")
    assert @tree.include?(100)
    assert_equal 100, @tree.delete(100)
    refute @tree.include?(100)
  end

  def test_deleting_a_leaf_removes_that_node_only
    @tree.insert(100, "I'm a leaf!")
    assert @tree.include?(100)
    assert_equal 100, @tree.delete(100)
    refute @tree.include?(100)
    assert @tree.include?(50)
  end

  def test_deleting_a_deeper_leaf_node_returns_the_score_of_the_deleted_leaf
    @tree.insert(70, "To the Right")
    @tree.insert(90, "To the Right Right")
    @tree.insert(110, "To the Right Right Right")
    assert_equal 110, @tree.delete(110)
    refute @tree.include?(110)
  end

  def test_deleting_a_node_with_one_child_leaf_sorts_that_child_into_the_tree
    @tree.insert(70, "To the Right")
    @tree.insert(90, "To the Right Right")
    assert @tree.include?(50)
    assert @tree.include?(70)
    assert @tree.include?(90)
    assert 3, @tree.height
    assert 0, @tree.depth_of(50)
    assert 1, @tree.depth_of(70)
    assert 2, @tree.depth_of(90)
    assert_equal 70, @tree.delete(70)
    assert @tree.include?(90)
    assert 2, @tree.height
    assert 1, @tree.depth_of(90)
  end

  def test_deleting_a_node_in_a_larger_tree_repopulates_tree_with_children_of_deleted_node
    @tree.insert(98, "Animals United")
    @tree.insert(58, "Armageddon")
    @tree.insert(36, "Bill & Ted's Bogus Journey")
    @tree.insert(93, "Bill & Ted's Excellent Adventure")
    @tree.insert(86, "Charlie's Angels")
    @tree.insert(38, "Charlie's Country")
    @tree.insert(69, "Collateral Damage")
    assert_equal 50, @tree.anchor_node.score
    refute_equal 98, @tree.anchor_node.score
    assert_equal 98, @tree.delete(98)
    assert @tree.include?(58)
    assert @tree.include?(93)
    assert @tree.include?(86)
    assert @tree.include?(69)
  end

  def test_deleting_the_anchor_node_sorts_the_entire_tree_again
    @tree.insert(98, "Animals United")
    @tree.insert(58, "Armageddon")
    @tree.insert(36, "Bill & Ted's Bogus Journey")
    @tree.insert(93, "Bill & Ted's Excellent Adventure")
    @tree.insert(86, "Charlie's Angels")
    @tree.insert(69, "Collateral Damage")
    assert_equal 50, @tree.anchor_node.score
    assert_equal 50, @tree.delete(50)
    refute @tree.include?(50)
    assert @tree.include?(98)
    assert @tree.include?(58)
    assert @tree.include?(36)
    assert @tree.include?(93)
    assert @tree.include?(86)
    assert @tree.include?(69)
  end
end
