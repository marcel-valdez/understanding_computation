gem 'minitest'
require 'minitest/autorun'
require_relative '../../lib/simple_language/expressions.rb'

describe Machine do
    before do 
        @machine = Machine.new
    end

    it 'should reduce an expression' do
        # arrange        
        obj = make_reducible     
        
        # act
        result = Machine.new(obj).run
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
        result = Machine.new(obj).run
        # assert
        result.must_equal obj
    end
    
    it 'should calculate an actual expression' do
        # arrange
        expression = Add.new(
            Multiply.new(Number.new(1), Number.new(2)),
            Multiply.new(Number.new(3), Number.new(4)))
        # act
        result = Machine.new(expression).run
        # assert
        result.reducible?.must_equal false
        result.class.must_equal Number
        result.value.must_equal 14
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
        result = Multiply.new(two, three).reduce
        # assert
        result.value.must_equal 6
    end
    
    it 'should reduce expressions' do
        # arrange
        left = make_reducible        
        right = make_reducible
        
        target = Multiply.new(left, right)
        # act
        target.reduce.reduce
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

def make_reducible
    obj = { reduced: false }
    
    def obj.reducible?; not self[:reduced] end
    def obj.reduce
        self[:reduced] = true
        self
    end
    
    obj
end