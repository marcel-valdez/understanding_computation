class FARule < Struct.new(:state, :character, :next_state)
  def applies_to?(state, character)
    self.state == state and self.character == character
  end
  
  def follow
    next_state
  end
  
  def inspect
    "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
  end
  
  def ==(other)
    self.state == other.state and self.character == other.character and
    self.next_state == other.next_state
  end
  
  def hash
    self.state.hash ^ self.character.hash ^ self.next_state.hash
  end
end