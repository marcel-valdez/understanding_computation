module Expressions
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
        
        def reduce(environment)
            if left.reducible?
                Add.new(left.reduce(environment), right)            
            elsif right.reducible?
                Add.new(left, right.reduce(environment))
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
        def reduce(environment)
            if left.reducible?
                Multiply.new(left.reduce(environment), right)
            elsif right.reducible?
                Multiply.new(left, right.reduce(environment))
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
        
        def reduce(environment)
            if left.reducible?
                LessThan.new(left.reduce(environment), right)
            elsif right.reducible?
                LessThan.new(left, right.reduce(environment))
            else
                Boolean.new(left.value < right.value)
            end
        end
    end
    
    class Variable < Struct.new(:name)
        def to_s; name.to_s end
        def inspect; "<#{self}>" end
        def reducible?; true end
        
        # environment contains the values for each variable name
        def reduce(environment)
            environment[name]
        end
    end
    
    class DoNothing
        def to_s; 'do-nothing' end
        def inspect; "<#{self}>" end
        def reducible?; false end
           
        def ==(other_statement)
            other_statement.instance_of? DoNothing
        end    
    end
    
    class Assign < Struct.new(:name, :expression)
        def to_s; "#{name} = #{expression}" end
        def inspect; "<#{self}>" end
        def reducible?; true end
        
        def reduce(env)
            if expression.reducible?
                return Assign.new(name, expression.reduce(env)), env
            else
            return DoNothing.new, env.merge({ name => expression })
            end
        end
    end
    
    class While < Struct.new(:condition, :body)
        def to_s
            "while (#{condition}) { #{body} }"
        end
        
        def inspect; "<#{self}>" end
        
        def reducible?; true end
            
        def reduce(env)
            return If.new(condition, Sequence.new(body, self), DoNothing.new), env
        end
    end
    
    class If < Struct.new(:condition, :consequence, :alternative)
        def to_s
            "if (#{condition}) { #{consequence} } else { #{alternative} }"
        end
        
        def inspect; "<#{self}>" end
        def reducible?; true end
        
        def reduce(env)
            if condition.reducible?
                return If.new(condition.reduce(env), consequence, alternative), env
            else
                case condition
                when Boolean.new(true)
                    return consequence, env
                when Boolean.new(false)
                    return alternative, env
                end
            end
        end
    end
    
    class Sequence < Struct.new(:first, :second)
        def to_s
            "#{first}; #{second}"
        end
        
        def inspect; "<#{self}>" end
            
        def reducible?; true end
        
        def reduce(env)
            case first
            when DoNothing.new
                return second, env
            else
                reduced_first, reduced_env = first.reduce(env)
                return Sequence.new(reduced_first, second), reduced_env
            end
        end
    end
    
    class Machine < Struct.new(:expression, :environment)
        # perform a step in expression reduction
        def step
            self.expression, self.environment = expression.reduce(environment)
        end
        
        def run
            while expression.reducible?
                puts "#{expression} -- #{environment}"
                step
            end
            
            puts "#{expression} -- #{environment}"
            return expression, environment
        end
    end
end