require_relative 'nfa.rb'
require_relative '../dfa/dfa.rb'
require_relative '../dfa/dfa_rule_book.rb'

class NFARulebook
  def alphabet
    rules.map { |rule| rule.character }.delete_if {|char| char.nil?}.to_set
  end
end

class NFASimulation < Struct.new(:nfa_design)
  def next_state(state, character)
    nfa_design.to_nfa(state).tap { |nfa|
      nfa.read_char(character)
    }.current_states
  end

  def alphabet
    nfa_design.rulebook.alphabet
  end

  def rules_for(state)
    alphabet.map { |char|
      FARule.new(state, char, next_state(state, char))
    }
  end

  def discover_rules_and_states(states)
    rules = states.flat_map {|state| 
      if state.is_a? Set
        next rules_for(state)
      else
        next rules_for(Set[state])
      end
    }

    more_states = rules.map(&:follow).to_set

    if more_states.subset?(states)
      [states, rules.to_set]
    else
      discover_rules_and_states((states + more_states).to_set)
    end
  end

  def to_dfa_design
    start_state = nfa_design.to_nfa.current_states
    states, rules = discover_rules_and_states(Set[start_state])
    accept_states = states.select {|state| nfa_design.to_nfa(state).accepting?}

    DFADesign.new(start_state, accept_states, DFARuleBook.new(rules))
  end
end