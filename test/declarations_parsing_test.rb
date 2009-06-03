class DeclarationsParsingTest < Test::Unit::TestCase
  
  def test_declaration_parsing_extension
    style = Stylish.generate do
      body :test => "myvalue"
    end
    
    assert_equal("body {testing:myvalue;}", style.to_s)
  end
  
  class TestDeclarationsParser < Stylish::Extensions::DeclarationsParser
    parses :test
    
    def parse(state)
      return state unless state.nil?
      Stylish::Declaration.new("testing", @value)
    end
  end
end
