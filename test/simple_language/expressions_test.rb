gem 'minitest'
require 'minitest/autorun'
require_relative '../../lib/simple_language/expressions.rb'

describe Machine do
    before do 
        @machine = Machine.new(nil, nil)
    end

    it 'should reduce an expression' do
        # arrange        
        obj = make_reducible     
        environment = nil
        # act
        environment = nil
        result, env = Machine.new(obj, nil).run
        # assert
        result[:reduced].must_equal true
    end
    
    it 'should not reduce a non-reducible expression' do
        # arrange        
        obj = {}   
        def obj.reducible?
            false
        end        
        # act
        environment = nil
        result, new_env = Machine.new(obj, environment).run
        # assert
        result.must_equal obj
    end
    
    it 'should calculate an actual expression' do
        # arrange
        expression = Add.new(
            Multiply.new(Number.new(1), Number.new(2)),
            Multiply.new(Number.new(3), Number.new(4)))
        # act
        environment = nil
        result, new_env = Machine.new(expression, environment).run
        # assert        
        result.must_equal Number.new(14)
    end
    
    it 'should return the value of a variable' do
        # arrange
        environment = { x: Number.new(3) }
        expression = Variable.new(:x)
        # act
        result, new_env = Machine.new(expression, environment).run
        # assert
        result.must_equal environment[:x]
    end
    
    it 'should reduce a statement' do
        # arrange
        statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
        env = { x: Number.new(2) }
        # act
        expression, new_env = Machine.new(statement, env).run
        # assert
        expression.must_equal DoNothing.new
        new_env[:x].must_equal Number.new(3)
    end
    
    it 'should evaluate conditionals' do
        # arrange
        conditional = If.new(Variable.new(:x), 
                        Assign.new(:y, Number.new(1)), 
                        DoNothing.new)
        env = { x: Boolean.new(false) }
        # act
        expr, new_env = Machine.new(conditional, env).run
        # assert
        expr.must_equal DoNothing.new
        new_env[:y].must_be_nil
    end
    
    it 'should perform while loops' do
        # arrange
        while_expr = While.new(
                LessThan.new(Variable.new(:x), Number.new(5)),
                Assign.new(:x, Multiply.new(
                                    Variable.new(:x), Number.new(3))))
        env = { x: Number.new(1) }
        machine = Machine.new(while_expr, env)
        # act
        expr, env = machine.run
        # assert
        env[:x].must_equal Number.new(9)
    end
end

describe Sequence do
    it 'should ignore the first DoNothing' do
        # arrange
        env = {}
        target = Sequence.new(DoNothing.new, "test")
        # act
        expr, new_env = target.reduce(env)
        # assert
        expr.must_equal "test"
        new_env.must_equal env
    end
    
    it 'should reduce the first expression' do
        # arrange
        env = {}
        expr = make_reducible
        target = Sequence.new(expr, nil)
        # act
        new_expr, new_env = target.reduce(env)
        # assert
        expr[:reduced].must_equal true
        new_expr.must_be_instance_of Sequence
    end
end

describe While do
    it 'should reduce to an If Expression' do
        # arrange
        condition = "condition"
        target = While.new(condition, nil)
        # act
        expr, env = target.reduce({})
        # assert
        env.must_equal({})
        expr.condition.must_equal condition
        expr.must_be_instance_of If
        expr.consequence.must_be_instance_of Sequence
        expr.alternative.must_be_instance_of DoNothing
    end
end

describe ValueExpression do
    it 'should not be reducible' do
        # arrange
        obj = Object.new
        obj.extend(ValueExpression)
        # act - assert
        obj.reducible?.must_equal false
    end
end

describe BinaryOperationExpression do
    it 'should be reducible' do
        # arrange
        obj = Object.new
        obj.extend(BinaryOperationExpression)
        # act - assert
        obj.reducible?.must_equal true
    end
end

describe Multiply do
    it 'should multiply two numbers' do
        # arrange
        two = Number.new(2)
        three = Number.new(3)
        # act
        environment = nil
        result = Multiply.new(two, three).reduce(environment)
        # assert
        result.value.must_equal 6
    end
    
    it 'should reduce expressions' do
        # arrange
        left = make_reducible        
        right = make_reducible
        
        target = Multiply.new(left, right)
        # act
        environment = nil
        target.reduce(environment).reduce(environment)
        # assert
        left[:reduced].must_equal true
        right[:reduced].must_equal true
    end    
end

describe LessThan do
    it 'should be reducible' do
        LessThan.new(nil, nil).reducible?.must_equal true
    end    
end

describe Assign do
    it 'should set values' do
        # arrange
        target = Assign.new(:x, Number.new(1))
        # act
        expression, environment = target.reduce({})
        # assert
        expression.must_equal DoNothing.new
        environment[:x].must_equal Number.new(1)
    end
    
    it 'should reduce expressions' do
        # arrange
        expression = make_reducible
        target = Assign.new(:x, expression)
        environment = {}
        # act
        expression, new_environment = target.reduce(environment)
        # assert
        expression.must_be_instance_of Assign
        new_environment.must_equal environment        
    end
end

describe If do
    it 'should reduce the condition' do
        # arrange
        reducible = make_reducible
        # act
        result, env = If.new(reducible, nil, nil).reduce({})
        # assert
        reducible[:reduced].must_equal true
    end
    
    it 'should go to consequence on Boolean true' do
        # arrange
        consequence = "test"
        # act
        result, env = If.new(Boolean.new(true), consequence, nil).reduce({})
        # assert
        result.must_equal "test"
    end
    
    it 'should return alternative on Boolean false' do
        # arrange
        alternative = "test"
        # act
        result, env = If.new(Boolean.new(false), nil, alternative).reduce({})
        # assert
        result.must_equal "test"        
    end
end

def make_reducible
    obj = { reduced: false }
    
    def obj.reducible?; not self[:reduced] end
        
    def obj.reduce(environment)
        self[:reduced] = true
        self
    end
    
    obj
end