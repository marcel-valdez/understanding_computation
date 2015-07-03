require_relative '../test_helper.rb'
require_relative '../../lib/regex/pattern.rb'

describe Pattern do
  # let(:target) do
  #   next target = NFARulebook.new(rules)
  # end
  
  it 'gets the correct rules given a state and char' do
    # arrange
    expected = [ FARule.new(1, 'a', 2), FARule.new(1, 'a', 3) ]
    # act
    actual = rule_book.rules_for(1, 'a')
    # assert
    actual.must_equal expected
  end
end