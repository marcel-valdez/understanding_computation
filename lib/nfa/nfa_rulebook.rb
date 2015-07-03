require 'set'

class NFARulebook < Struct.new(:rules)
  # Gets the next states given a current set of states and character.
  def next_states(states, char)
    states.flat_map { |state| follow_rules_for(state, char) }.to_set
  end
  
  # Consumes char and produces all valid states.
  def follow_rules_for(state, char)
    rules_for(state, char).map(&:follow)
  end
  
  # Gets all rules that respond to a char in a given state.
  def rules_for(state, char)
    rules.select { |rule| rule.applies_to?(state, char) }
  end
end

class NFA < Struct.new(:current_states, :accept_states, :rule_book)
  def accepting?
    (current_states & accept_states).any?
  end
  
  def read_char(char)
    self.current_states = rule_book.next_states(current_states, char)
  end
  
  def read_string(string)
    string.chars.each { |char| read_char(char) }
  end
end

class NFADesign < Struct.new(:start_state, :accept_states, :rule_book)
  def accepts?(input)
    to_nfa.tap { |nfa| nfa.read_string input }.accepting?
  end
  
  def to_nfa
    NFA.new(Set[start_state], accept_states, rule_book)
  end
end