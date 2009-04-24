require 'test/unit'

class CommentTest < Test::Unit::TestCase
  
  def setup
    @comment = Stylish::Comment.new("Classy comments block",
      "Comments can now be added through Stylish,",
      "allowing generated stylesheets to be marked",
      "up with explanations, examples and various",
      "pieces of helpful metadata.",
      {:author => "Mr Example <mr@example.org>"},
      "Order does matter for adding comments, but",
      "lines of text and metadata hashes will be",
      "separated out automatically.")
  end
  
  def test_headers
    assert_equal("Classy comments block", @comment.header)
    assert_equal("Comments can now be added through Stylish,", @comment.lines[0])
    assert_equal("Testing header.", Stylish::Comment.new("Testing header.").header)
  end
  
  def test_metadata
    assert_instance_of(Hash, @comment.metadata)
    assert_equal(1, @comment.metadata.length)
    assert_equal("Mr Example <mr@example.org>", @comment.metadata[:author])
  end
  
  def test_lines
    assert_equal(7, @comment.lines.length)
    assert_equal("lines of text and metadata hashes will be", @comment.lines[5])
  end
  
  def test_nil_inputs
    comment = Stylish::Comment.new
    assert_nil(comment.header)
    assert_equal([], comment.lines)
    assert_equal({}, comment.metadata)
  end
  
  def test_header_to_string
    assert_equal(
"/**
 * Just a header.
 */",
    Stylish::Comment.new("Just a header.").to_s)
  end
  
  def test_lines_to_string
    assert_equal(
"/**
 * First line
 *
 * Second line,
 * third line.
 */",
    Stylish::Comment.new("First line", "Second line,", "third line.").to_s)
  end
  
  def test_metadata_to_string
    assert_equal(
"/**
 * @link http://example.org/
 */",
    Stylish::Comment.new({:link => "http://example.org/"}).to_s)
    
    assert_equal(
"/**
 * Header
 *
 * @link http://example.org/
 */",
    Stylish::Comment.new("Header", {:link => "http://example.org/"}).to_s)
  end
  
  def test_block_to_string
    assert_equal(
"/**
 * Classy comments block
 *
 * Comments can now be added through Stylish,
 * allowing generated stylesheets to be marked
 * up with explanations, examples and various
 * pieces of helpful metadata.
 * Order does matter for adding comments, but
 * lines of text and metadata hashes will be
 * separated out automatically.
 *
 * @author Mr Example <mr@example.org>
 */", @comment.to_s)
  end
end
