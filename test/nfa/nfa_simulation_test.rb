require_relative '../test_helper.rb'
require_relative '../../lib/nfa/nfa_simulation.rb'
require_relative '../../lib/nfa/nfa.rb'
require_relative '../../lib/dfa/fa_rule.rb'

describe NFARulebook do

  let(:rules) do
    array = [
      FARule.new(1, 'a', 2), FARule.new(1, 'b', 1), FARule.new(1, 'a', 3),
      FARule.new(2, 'a', 2), FARule.new(2, 'b', 3), FARule.new(2, 'b', 4),
      FARule.new(3, 'a', 3), FARule.new(3, 'b', 3), FARule.new(3, 'c', 4),
      FARule.new(4, nil, 2)
    ]
    next rules = array
  end

  let(:simulation) do
    rulebook = NFARulebook.new(rules)
    nfa_design = NFADesign.new(1, [4], rulebook)
    next simulation = NFASimulation.new(nfa_design)
  end

  it 'can produce an equivalent dfa' do
    # given
    nfa_design = NFADesign.new(1, [4], NFARulebook.new(rules))
    # when
    dfa_design = simulation.to_dfa_design
    # then
    [
      "a", "b", "c",
      "aa", "ab", "ac", "ba", "bb", "bc", "ca", "cb", "cc",
      "abc", "bac", "bca", "acb", "cab", "cba"
    ].each { |input|
      (nfa_design.accepts? input).must_equal dfa_design.accepts? input
    }
  end
  
  it 'can simulate the next state' do
    # given
    initial_state = Set[1]
    # when
    next_states = simulation.next_state(initial_state, 'a')
    # then
    next_states.must_equal Set[2, 3]
  end

  it 'can simulate the next state when it is not the start state' do
    # given
    initial_state = Set[2]
    # when
    next_states = simulation.next_state(initial_state, 'b')
    # then
    next_states.must_equal Set[3, 4, 2]
  end

  it 'can simulate the next state for multiple initial states' do
    # given
    initial_states = Set[1, 2]
    # when
    next_states = simulation.next_state(initial_states, 'b')
    # then
    next_states.must_equal Set[1, 3, 4, 2]
  end

  it 'can get us the alphabet of an NFA design' do
    # given 
    # when
    alphabet = simulation.alphabet
    # then
    alphabet.must_equal Set['a', 'b', 'c']
  end

  it 'can get us the rules for a given state' do
    # given
    state = Set[1, 2]
    # when
    rules = simulation.rules_for(state)
    # then
    rules.must_equal [
      FARule.new(state, 'a', Set[2, 3]),
      FARule.new(state, 'b', Set[1, 3, 4, 2]),
      FARule.new(state, 'c', Set[])
    ]
  end

  it 'can discover states and rules' do
    # given
    rules = [
      FARule.new(1, 'a', 2), FARule.new(1, 'a', 1),
      FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
      FARule.new(3, 'a', 3), FARule.new(3, 'b', 3)
    ]

    expected_states = Set[1, Set[1, 2], Set[3], Set[]]
    expected_rules = Set[
      FARule.new(Set[], 'a', Set[]),
      FARule.new(Set[], 'b', Set[]),

      FARule.new(Set[1], 'a', Set[1, 2]), 
      FARule.new(Set[1], 'b', Set[]),

      FARule.new(Set[1, 2], 'a', Set[1, 2]),
      FARule.new(Set[1, 2], 'b', Set[3]),

      FARule.new(Set[3], 'a', Set[3]),
      FARule.new(Set[3], 'b', Set[3])
    ]

    nfa_design = NFADesign.new(1, [3], NFARulebook.new(rules))
    simulation = NFASimulation.new(nfa_design)
    initial_state = Set[1]
    # when
    actual_states, actual_rules = simulation.discover_rules_and_states(initial_state)
    # then
    actual_states.must_equal expected_states
    actual_rules.must_equal expected_rules
  end
end