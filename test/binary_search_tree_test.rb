gem 'minitest', '~> 5.9'
require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/node'
require_relative '../lib/binary_search_tree'

require 'pry'

class BinarySearchTreeTest < Minitest::Test

  def setup
    @tree = BinarySearchTree.new
    refute @tree.anchor_node
    @tree.insert(score: 50, title: "Anchor")
  end

  def test_anchor_node_is_the_first_entry
    assert @tree.anchor_node
    assert_equal 0, @tree.anchor_node.depth
    assert_equal 50, @tree.anchor_node.score
    assert_equal "Anchor", @tree.anchor_node.title
  end

  def test_insert_higher_score_goes_on_the_right
    @tree.insert(score: 70, title: "To the Right")
    assert_equal "To the Right", @tree.anchor_node.right.title
    assert_equal 1, @tree.anchor_node.right.depth
  end

  def test_insert_lower_score_goes_on_the_left
    @tree.insert(score: 10, title: "To the Left")
    assert_equal "To the Left", @tree.anchor_node.left.title
    assert_equal 1, @tree.anchor_node.left.depth
  end

  def test_inserting_two_larger_values_each_go_on_the_right_respectively
    @tree.insert(score: 70, title: "To the Right")
    @tree.insert(score: 90, title: "To the Right Right")
    assert_equal "To the Right", @tree.anchor_node.right.title
    assert_equal "To the Right Right", @tree.anchor_node.right.right.title
    assert_equal 2, @tree.anchor_node.right.right.depth
    assert_equal 2, @tree.max_depth
  end

  def test_inserting_two_smaller_values_each_go_on_the_left_respectively
    @tree.insert(score: 30, title: "To the Left")
    @tree.insert(score: 10, title: "To the Left Left")
    assert_equal "To the Left", @tree.anchor_node.left.title
    assert_equal "To the Left Left", @tree.anchor_node.left.left.title
    assert_equal 2, @tree.anchor_node.left.left.depth
  end

  def test_ignore_inserts_for_scores_which_alredy_exist_as_a_node
    @tree.insert(score: 70, title: "To the Right")
    assert_equal "To the Right", @tree.anchor_node.right.title
    @tree.insert(score: 70, title: "Duplicate Score")
    assert_equal "To the Right", @tree.anchor_node.right.title
    refute_equal "Duplicate Score", @tree.anchor_node.right.title
  end

  def test_inserting_one_larger_and_then_one_smaller_than_big_but_less_than_anchor
    @tree.insert(score: 90, title: "To the Right")
    @tree.insert(score: 80, title: "To the Right, then Left")
    assert_equal "To the Right", @tree.anchor_node.right.title
    assert_equal "To the Right, then Left", @tree.anchor_node.right.left.title
    assert_equal 2, @tree.anchor_node.right.left.depth
  end

  def test_the_binary_tree_can_accommodate_lots_of_items
    scores = (1..100).to_a.shuffle!
    scores.each do |score|
      @tree.insert(score: score, title: "Just a Random Title")
    end
    assert @tree.max_depth > 6
  end

  def test_it_returns_true_if_searching_for_a_movie_which_is_included_in_tree
    assert @tree.include?(50)
  end

  def test_it_returns_false_if_searching_for_a_movie_which_is_not_included_in_tree
    refute @tree.include?(1000)
  end

  def test_it_determines_if_nodes_exist_in_the_tree
    scores = (0..95).step(5).to_a
    scores.each do |score|
      @tree.insert(score: score, title: "Just a Title")
    end
    assert_equal true, @tree.include?(20)
    assert_equal true, @tree.include?(95)
    refute @tree.include?(21)
    refute @tree.include?(96)
  end

  def test_it_finds_the_depth_of_the_given_node
    assert_equal 0, @tree.anchor_node.depth
    @tree.insert(score: 14, title: "Depth of One")
    @tree.insert(score: 44, title: "Depth of Two")
    assert_equal 1, @tree.depth_of(14)
    assert_equal 2, @tree.depth_of(44)
  end

  def test_it_finds_the_movie_with_the_highest_score
    scores = (5..95).step(5).to_a.shuffle!
    scores.each do |score|
      @tree.insert(score: score, title: "Just a Title")
    end
    assert_equal({ "Just a Title" => 95 }, @tree.max)
  end

  def test_it_finds_the_movie_with_the_lowest_score
    scores = (5..95).step(5).to_a.shuffle!
    scores.each do |score|
      @tree.insert(score: score, title: "Just a Title")
    end
    assert_equal({ "Just a Title" => 5 }, @tree.min)
  end

  def test_it_returns_an_empty_array_when_tree_is_empty
    @tree = BinarySearchTree.new
    assert @tree
    assert_equal [], @tree.sort
  end

  def test_it_sorts_a_tree_with_one_element
    assert_equal 0, @tree.max_depth
    assert_equal [{ "Anchor" => 50 }], @tree.sort
  end

  def test_it_sorts_a_tree_with_two_elements
    @tree.insert(score: 90, title: "A Second Movie")
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
      @tree.insert(score: score, title: "Test Title")
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

  def test_it_shows_an_error_message_when_no_file_is_present
    skip
    # and what about when no filename is given?
  end

  def test_it_loads_zero_movies_when_a_file_has_no_movies_in_it
    assert_equal 0, @tree.load('empty_file.txt')
  end

  def test_it_loads_movies_from_a_well_formatted_file
    assert_equal 98, @tree.load('movies.txt')
  end

  def test_it_does_not_add_movie_to_tree_when_score_already_exists
    @tree.insert(score: 75, title: 'French Dirty')
    assert @tree.include?(75)
    assert_equal 2, @tree.sort.length
    assert_equal 97, @tree.load('movies.txt')
    assert_equal 99, @tree.sort.length
  end

end
