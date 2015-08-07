require_relative '../test_helper.rb'
require_relative '../../lib/dfa/dfa_rule_book.rb'
require_relative '../../lib/dfa/dfa.rb'

describe DFARuleBook do
    it 'can follow a rule' do
        # arrange
        initial_state = :state_one
        expected_state = :state_two
        rule = FARule.new(initial_state, 'a', expected_state)
        rulebook = DFARuleBook.new([rule])
        # act
        actual_state = rulebook.next_state(initial_state, 'a')
        # assert
        actual_state.must_equal expected_state
    end
    
    describe "integration tests" do
        let(:rulebook) do
            rules = [ FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
                      FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
                      FARule.new(3, 'a', 3), FARule.new(3, 'b', 3) ]
            next rulebook = DFARuleBook.new(rules)
        end
        
        it 'can run a program' do
            # arrange
            current_state = 1
            [['a', 2, 1], ['a', 2], ['b', 3], ['a', 3]].
                each {|char, expected_state|
                # act
                actual_state = rulebook.next_state current_state, char   
                # assert
                actual_state.must_equal expected_state
                
                current_state = actual_state
            }
        end
        
        it 'can be in non-accepting' do
            # arrange
            dfa = DFA.new(1, [2, 3], rulebook)
            # act
            actual = dfa.accepting?
            # assert
            actual.must_equal false
        end
        
        it 'can go to accepting' do
            # arrange
            dfa = DFA.new(1, [2, 3], rulebook)
            # act
            dfa.read_char 'a'
            # assert
            dfa.accepting?.must_equal true
        end
        
        it 'can follow a program' do
            # arrange
            dfa = DFA.new(1, [3], rulebook)
            # act
            dfa.read_string 'aaba'
            # assert
            dfa.accepting?.must_equal true
        end
        
        it 'matches its design' do
            # arrange
            dfa_design = DFADesign.new(1, [3], rulebook)
            dfa = DFA.new(1, [3], rulebook)
            dfa.read_string 'aaba'
            expected = dfa.accepting?
            # act
            actual = dfa_design.accepts?('aaba')
            # assert
            actual.must_equal expected
        end
    end
end