require_relative '../test_helper.rb'
require_relative '../../lib/big_step_machine/expressions.rb'

describe ValueExpression do
    it 'should evaluate to itself' do
        # arrange
        value = Object.new        
        value.extend(ValueExpression)
        # act
        result = value.evaluate({})
        # assert
        result.must_equal value
    end
    
    it 'should return valid ruby code on to_ruby' do
        # arrange
        obj = Object.new
        def obj.value; 0 end        
        obj.extend(ValueExpression)
        # act
        result = obj.to_ruby
        # assert
        result.must_equal "-> e { 0 }"
    end
end

describe Variable do
    it 'should get value from environment' do
        # arrange
        env = { name: 'value' }        
        # act
        result = Variable.new(:name).evaluate(env)
        # assert
        result.must_equal 'value'
    end
    
    it 'should give valid ruby code on to_ruby' do 
        # arrange
        env = { name: 1 }
        target = Variable.new(:name)
        # act
        result = target.to_ruby
        # assert
        result.must_equal '-> e { e[:name] }'
    end
end

describe BinaryExpression do
    it 'should evaluate recursively' do
        # arrange
        left = make_evaluatable(0)
        right = make_evaluatable(0)
        
        obj = { left: left, right: right }
        obj.extend BinaryExpression
        def obj.construct(value); value end
        def obj.operate(left, right); [left, right] end            
        def obj.left; self[:left] end
        def obj.right; self[:right] end
        
        # act
        result = obj.evaluate({})
        # assert
        left[:evaluated].must_equal true
        right[:evaluated].must_equal true        
    end
    
    it 'should evaluate to correct ruby code' do
        # arrange
        left = Object.new
        def left.to_ruby; "left" end
        right = Object.new
        def right.to_ruby; "right" end
        mock = { left: left, right: right }
        def mock.sign; "sign" end
        def mock.left; self[:left] end
        def mock.right; self[:right] end
        mock.extend(BinaryExpression)
        # act
        result = mock.to_ruby
        # assert
        result.must_equal "-> e { (left).call(e) sign (right).call(e) }"
    end
end

describe Add do
    it 'should add two Number objects' do
        # arrange
        left_num = Number.new(1)
        right_num = Number.new(3)
        # act
        result = Add.new(left_num, right_num).evaluate({})
        # assert
        result.must_be_instance_of Number
        result.must_equal Number.new(4)
    end
end


describe Multiply do
    it 'should Multiply two Number objects' do
        # arrange
        left_num = Number.new(2)
        right_num = Number.new(3)
        # act
        result = Multiply.new(left_num, right_num).evaluate({})
        # assert
        result.must_be_instance_of Number
        result.must_equal Number.new(6)
    end
end


describe LessThan do
    it 'should compare LessThan two Number objects' do        
        [
            [ Number.new(2), Number.new(3), true ],
            [ Number.new(3), Number.new(2), false ],
            [ Number.new(3), Number.new(3), false ]
        ].each { |left_num, right_num, bool_result|
            # arrange              
            # act
            result = LessThan.new(left_num, right_num).evaluate({})
            # assert
            result.must_be_instance_of Boolean
            result.must_equal Boolean.new(bool_result)
        }
    end
end

describe Assign do
    it 'should change the environment' do
        # arrange
        name = :x
        expression = Number.new(0)
        # act
        new_env = Assign.new(name, expression).evaluate({x: 1})
        # assert
        new_env[:x].must_equal Number.new(0)
    end
end

describe If do
    it 'should evaluate the condition' do
        # arrange
        condition = make_evaluatable(Boolean.new(false))
        # act
        If.new(condition, nil, nil).evaluate({})
        # assert
        condition[:evaluated].must_equal true
    end
    
    it 'should evaluate the consequence' do
        # arrange
        condition = make_evaluatable(nil)
        def condition.evaluate(env); Boolean.new(true); end
        consequence = make_evaluatable(nil)
        # act
        result = If.new(condition, consequence, nil).evaluate({})
        # assert
        result.must_equal consequence
        consequence[:evaluated].must_equal true
    end
    
    it 'should evaluate the alternative' do
        # arrange
        condition = make_evaluatable(nil)
        def condition.evaluate(env); Boolean.new(false); end
        alternative = make_evaluatable(nil)
        # act
        result = If.new(condition, nil, alternative).evaluate({})
        # assert
        result.must_equal alternative
        alternative[:evaluated].must_equal true
    end
end

describe Sequence do
    module Concatenated
        def evaluate(env)
            env[:count] += 1
            env
        end
    end
    
    it 'should concatenate expressions' do
        # arrange
        first = Object.new
        second = Object.new
        first.extend(Concatenated)
        second.extend(Concatenated)
        env = { count: 0 }
        # act
        result = Sequence.new(first, second).evaluate(env)
        # assert
        result.must_be_same_as env
        result[:count].must_equal 2
    end
end

describe While do
    it 'should execute while loop' do
        # arrange
        x_variable = Variable.new(:x)
        condition = LessThan.new(x_variable, Number.new(10))
        assignment = Assign.new(:x, Add.new(x_variable, Number.new(1)))
        while_loop = While.new(condition, assignment)
        # act
        env = while_loop.evaluate({x: Number.new(0)})
        # assert
        env[:x].must_equal Number.new(10)
    end
    
    it 'should give evaluatable ruby code' do
        # arrange
        x_variable = Variable.new(:x)
        condition = LessThan.new(x_variable, Number.new(10))
        assignment = Assign.new(:x, Add.new(x_variable, Number.new(1)))
        while_loop = While.new(condition, assignment)
        # act
        ruby_code = while_loop.to_ruby
        puts ruby_code
        env = eval(ruby_code).call({x: 1})
        # assert
        env[:x].must_equal 10
    end
end