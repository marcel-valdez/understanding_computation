module BinaryOperationExpression
    def to_s; "#{left} #{sign} #{right}" end
    
    def inspect; "<#{self}>" end
        
    def reducible?; true end
end

module ValueExpression
    def to_s; value.to_s end
    
    def inspect; "<#{self}>" end
    
    def reducible?; false end
end

class Number < Struct.new(:value)
    include ValueExpression
end

class Add < Struct.new(:left, :right)
    include BinaryOperationExpression
    
    def sign; '+'; end    
    
    def reduce
        if left.reducible?
            Add.new(left.reduce, right)            
        elsif right.reducible?
            Add.new(left, right.reduce)
        else
            Number.new(left.value + right.value)
        end
    end
end

class Multiply < Struct.new(:left, :right)        
    include BinaryOperationExpression
    
    def sign; '*' end
    
    #  Reduce always builds a new expression rather than modifying an existing
    #  one.
    def reduce
        if left.reducible?
            Multiply.new(left.reduce, right)            
        elsif right.reducible?
            Multiply.new(left, right.reduce)
        else
            Number.new(left.value * right.value)
        end
    end
end

class Boolean < Struct.new(:value)
    include ValueExpression
end

class LessThan < Struct.new(:left, :right)
    include BinaryOperationExpression
    
    def sign; '<' end
    
    def reduce
        if left.reducible?
            LessThan.new(left.reduce, right)
        elsif right.reducible?
            LessThan.new(left, right.reduce)
        else
            Boolean.new(left.value < right.value)
        end
    end
end

class Machine < Struct.new(:expression)
    # perform a step in expression reduction
    def step
        self.expression = expression.reduce
    end
    
    def run
        while expression.reducible?
            puts expression
            step
        end
        
        return expression
    end
end