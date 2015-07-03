require_relative '../test_helper.rb'
require_relative '../../lib/nfa/nfa_rulebook.rb'
require_relative '../../lib/dfa/fa_rule.rb'

describe NFARulebook do
  let(:rule_book) do
    rules = [
      FARule.new(1, 'a', 2), FARule.new(1, 'b', 1), FARule.new(1, 'a', 3),
      FARule.new(2, 'a', 2), FARule.new(2, 'b', 3), 
      FARule.new(3, 'a', 3), FARule.new(3, 'b', 3), FARule.new(3, 'c', 4)
    ]
    next rule_book = NFARulebook.new(rules)
  end
  
  it 'does not accept invalid state transitions' do
    check_valid_transitions(transitions: 'bc', should_be_valid: false)
    check_valid_transitions(transitions: 'bbc', should_be_valid: false)
  end
  
  it 'accepts valid state transitions' do
    check_valid_transitions(transitions: 'aa', should_be_valid: true)
    check_valid_transitions(transitions: 'aac', should_be_valid: true)
  end
  
  def check_valid_transitions(testcase)
    target = NFADesign.new(1, Set[1, 2, 3, 4], rule_book)
    # act
    actual = target.accepts?(testcase[:transitions])
    # assert
    actual.must_equal testcase[:should_be_valid]
  end
  
  it 'gets the correct rules given a state and char' do
    # arrange
    expected = [ FARule.new(1, 'a', 2), FARule.new(1, 'a', 3) ]
    # act
    actual = rule_book.rules_for(1, 'a')
    # assert
    actual.must_equal expected
  end
  
  it 'should follow all rules for a char' do
    # arrange
    expected = [ 2, 3 ]
    # act
    actual = rule_book.follow_rules_for(1, 'a')
    # assert
    actual.must_equal expected
  end
  
  it 'should procede corresponding states' do
    # arrange
    expected = [2, 3].to_set
    # act
    actual = rule_book.next_states([1, 2], 'a')
    # assert
    actual.must_equal expected
  end
  
  it 'should merge repeated states' do
    # arrange
    expected = [3].to_set
    # act
    actual = rule_book.next_states([2, 3], 'b')
    # assert
    actual.must_equal expected
  end
end