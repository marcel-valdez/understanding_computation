gem 'minitest'
require 'minitest/autorun'

def make_reducible
    obj = { reduced: false }
    
    def obj.reducible?; not self[:reduced] end
        
    def obj.reduce(environment)
        self[:reduced] = true
        self
    end
    
    obj
end

def make_evaluatable(value = 0)
    obj = { evaluated: false, value: value }    
        
    def obj.evaluate(environment)
        self[:evaluated] = true
        self
    end
        
    def obj.value
        self[:value]
    end
    
    obj
end