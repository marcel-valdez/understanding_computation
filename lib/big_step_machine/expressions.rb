RubyVM::InstructionSequence.compile_option = {
    tailcall_optimization: true,
    trace_instruction: false
}

module ValueExpression
    def to_s; value.to_s end    
    def inspect; "<#{self}>" end
    def to_ruby
        "-> e { #{value.inspect} }"
    end
        
    def evaluate(env)
        self
    end
end

module BinaryExpression
    def to_s; "#{left} #{sign} #{right}" end
    
    def inspect; "<#{self}>" end        

    def evaluate(env)
        construct(
            operate(
                left.evaluate(env).value,
                right.evaluate(env).value))
    end
    
    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) #{sign} (#{right.to_ruby}).call(e) }"
    end
end

module NumericResult
    def construct(value)
        Number.new(value)
    end
end

module BooleanResult
    def construct(value)
        Boolean.new(value)
    end
end

class Number < Struct.new(:value)
    include ValueExpression
end

class Boolean < Struct.new(:value)
    include ValueExpression
end


class Add < Struct.new(:left, :right)
    include BinaryExpression
    include NumericResult
    
    def sign; '+' end
    
    def operate(left_value, right_value)
        left_value + right_value
    end
end

class Multiply < Struct.new(:left, :right)
    include BinaryExpression
    include NumericResult
    
    def sign; '*' end
    
    def operate(left_value, right_value)
        left_value * right_value
    end
end


class LessThan < Struct.new(:left, :right)
    include BinaryExpression
    include BooleanResult
    
    def sign; '<' end
    
    def operate(left_value, right_value)
        left_value < right_value
    end
end

class Variable < Struct.new(:name)
    def to_s; name.to_s end
    def inspect; "<#{self}>" end        
    def evaluate(env); env[name] end
    def to_ruby
        "-> e { e[#{name.inspect}] }"
    end
end

class Assign < Struct.new(:name, :expression)
    def to_s; "#{name} = #{expression}" end
    def inspect; "<#{self}>" end
        
    def evaluate(env)
        env.merge({ name => expression.evaluate(env)})
    end
    
    def to_ruby
        "-> e { e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e) }) }"
    end
end

class DoNothing
    def to_s; 'do-nothing' end
    def inspect; "<#{self}>" end        
    def evaluate(env); env end
    def to_ruby; '-> e { e }' end
end

class If < Struct.new(:condition, :consequence, :alternative)
    def to_s
        "if (#{condition}) { #{consequence} } else { #{alternative} }"
    end
    
    def inspect; "<#{self}>" end
        
    def evaluate(env)
        case condition.evaluate(env)                
        when Boolean.new(true)
            consequence.evaluate(env)
        when Boolean.new(false)
            alternative.evaluate(env)            
        end
    end
    
    def to_ruby
        "-> { if (#{condition.to_ruby}).call(e)" +
        " then (#{consequence.to_ruby}).call(e)" +
        " else (#{alternative.to_ruby}).call(e)" +
        " end }"
    end
end
    
class Sequence < Struct.new(:first, :second)
    def to_s; "#{first}; #{second}" end    
    def inspect; "<#{self}>" end
    
    def evaluate(env)
        second.evaluate(first.evaluate(env))
    end
    
    def to_ruby
        "-> e { (#{second.to_ruby}).call((#{first.to_ruby}).call(e)) }"
    end
end

class While < Struct.new(:condition, :body)
    def to_s
        "while (#{condition}) { #{body} }"
    end
    
    def inspect; "<#{self}>" end
        
    def evaluate(env)
        case condition.evaluate(env)
        when Boolean.new(true)
        # continue doing computation (recursive)
            evaluate(body.evaluate(env))
        when Boolean.new(false)
        # stop computation
            env
        end
    end
    
    def to_ruby
        "-> e {" +
        " while (#{condition.to_ruby}).call(e);" +
        " e = (#{body.to_ruby}).call(e);" +
        " end;" +
        " e" +
        "}"
    end
end