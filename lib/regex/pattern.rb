require_relative '../nfa/nfa.rb'
require_relative '../dfa/fa_rule.rb'

module Pattern
  attr_reader :precedence
  
  def bracket(outer_precedence)
    if precedence < outer_precedence
      '(' + to_s + ')'
    else
      to_s
    end
  end
  
  def inspect
    "/#{self}/"
  end

  def matches?(string)
    to_nfa.accepts?(string)
  end
end

class Empty
  include Pattern
  
  def precedence
    3
  end
  
  def to_s
    ''
  end

  def to_nfa
    start_state = Object.new
    accept_states = [start_state]
    rulebook = NFARulebook.new([])

    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Literal < Struct.new(:character)
  include Pattern

  def precedence 
    1
  end

  def to_s
    character
  end

  def to_nfa
    start_state = Object.new
    define_to_s(start_state, 'start: ' + character)
    accept_state = Object.new
    define_to_s(accept_state, 'end: ' + character)

    rule = FARule.new(start_state, character, accept_state)
    rulebook = NFARulebook.new([rule])
    NFADesign.new(start_state, [accept_state], rulebook)
  end

  def define_to_s(obj, str_representation)
    def obj.str_representation(str_representation)
      @str_representation = str_representation
    end
    def obj.to_s
      @str_representation
    end

    obj.str_representation(str_representation)
  end
end

class Concatenate < Struct.new(:first, :second)
  include Pattern
  
  def precedence
    1
  end
  
  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join
  end

  def to_nfa
    first_nfa = first.to_nfa
    second_nfa = second.to_nfa

    start_state = first_nfa.start_state
    accept_states = second_nfa.accept_states

    pattern_rules = first_nfa.rulebook.rules + second_nfa.rulebook.rules
    concat_rules = first_nfa.accept_states.map { |state|
      FARule.new(state, nil, second_nfa.start_state)
    }

    rulebook = NFARulebook.new(pattern_rules + concat_rules)

    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Choose < Struct.new(:first, :second)
  include Pattern
  
  def precedence
    0
  end
  
  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join('|')
  end

  def to_nfa
    first_nfa = first.to_nfa
    second_nfa = second.to_nfa

    pattern_start_states = [ first_nfa.start_state, second_nfa.start_state ]
    accept_states = first_nfa.accept_states + second_nfa.accept_states
    pattern_rules = first_nfa.rulebook.rules + second_nfa.rulebook.rules

    start_state = Object.new
    free_move_rules = pattern_start_states.map { |pattern_start_state|
      FARule.new(start_state, nil, pattern_start_state)
    }

    rulebook = NFARulebook.new(free_move_rules + pattern_rules)
    NFADesign.new(start_state, accept_states, rulebook)
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern
  
  def precedence
    2
  end
  
  def to_s
    pattern.bracket(precedence) + '*'
  end

  def to_nfa
    pattern_nfa = pattern.to_nfa

    start_state = Object.new
    free_move_rule_before = FARule.new(
      start_state, nil, pattern_nfa.start_state
    )

    free_move_rules_after = pattern_nfa.accept_states.map { |accept_state|
      FARule.new(accept_state, nil, pattern_nfa.start_state)
    }

    rulebook = NFARulebook.new(
      pattern_nfa.rulebook.rules + 
      [ free_move_rule_before ] + 
      free_move_rules_after
    )

    NFADesign.new(
      start_state,
      [start_state, pattern_nfa.start_state] +
      pattern_nfa.accept_states,
      rulebook
    )
  end
end