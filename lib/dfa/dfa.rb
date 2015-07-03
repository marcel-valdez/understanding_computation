class DFA < Struct.new(:current_state, :accept_states, :rulebook)
    def accepting? 
        accept_states.include? current_state
    end
    
    def read_char(char)
        self.current_state = rulebook.next_state(current_state, char)
    end
    
    def read_string(string)
        string.chars.each { |char| read_char char }
    end
end

class DFADesign < Struct.new(:current_state, :accept_states, :rulebook)
    def to_dfa
        DFA.new(current_state, accept_states, rulebook)
    end
    
    def accepts?(string)
        to_dfa.tap { |dfa| dfa.read_string string }.accepting?
    end
end