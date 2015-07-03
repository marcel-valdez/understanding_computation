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
end

class Empty
  include Pattern
  
  def initialize
    @precedence = 3
  end
  
  def to_s
    ''
  end
end

class Concatenate < Struct.new(:first, :second)
  include Pattern
  
  def initialize
    @precedence = 1
  end
  
  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join
  end
end

class Choose < Struct.new(:first, :second)
  include Pattern
  
  def initialize
    @precedence = 0
  end
  
  def to_s
    [first, second].map { |pattern| pattern.bracket(precedence) }.join('|')
  end
end

class Repeat < Struct.new(:pattern)
  include Pattern
  
  def initialize
    @precedence = 2  
  end
  
  def to_s
    pattern.bracket(precedence) + '*'
  end
end