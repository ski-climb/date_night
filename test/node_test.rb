gem 'minitest', '~> 5.9'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/node'

class NodeTest < Minitest::Test

  def setup
    @node = Node.new(50, "Cat in the Hat", depth: 0)
  end

  def test_a_node_has_attributes
    assert_equal 50, @node.score
    assert_equal "Cat in the Hat", @node.title
    assert_equal 0, @node.depth
  end

  def test_a_node_responds_to_left_and_right
    assert_nil @node.left
    assert_nil @node.right
  end

  def test_a_node_returns_its_information_in_a_hash
    cat_in_the_hat = { "Cat in the Hat" => 50 }
    second_node = Node.new(100, "One Fish, Two Fish", depth: 1)
    one_fish = { "One Fish, Two Fish" => 100 }
    assert_equal cat_in_the_hat, @node.as_hash
    assert_equal one_fish, second_node.as_hash
  end


end
