require 'set'

class NFARulebook < Struct.new(:rules)
  # Gets the next states given a current set of states and character.
  def next_states(states, char)
    next_states = follow_rules(states, char)
  end

  def follow_free_moves(states)
    more_states = next_states(states, nil)
    if more_states.subset? (states)
      states
    else
      follow_free_moves(states + more_states)
    end
  end

  def follow_rules(states, char)
    states.flat_map { |state| 
      follow_rules_for(state, char) 
    }.to_set
  end
  
  # Consumes char and produces all valid states.
  # What about free moves? We need to consume free moves
  def follow_rules_for(state, char)
    rules_for(state, char).map(&:follow)
  end
  
  # Gets all rules that respond to a char in a given state.
  def rules_for(state, char)
    rules.select { |rule| rule.applies_to?(state, char) }
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
  def accepting?
    (current_states & accept_states).any?
  end
  
  def read_char(char)
    self.current_states = rulebook.next_states(current_states, char)
  end
  
  def read_string(string)
    string.chars.each { |char| read_char(char) }
  end

  def current_states
    rulebook.follow_free_moves(super)
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
  def accepts?(input)
    to_nfa.tap { |nfa| nfa.read_string input }.accepting?
  end
  
  def to_nfa(current_states = Set[start_state])
    NFA.new(current_states, accept_states, rulebook)
  end
end