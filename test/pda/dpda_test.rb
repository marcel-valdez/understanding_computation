require_relative '../test_helper.rb'
require_relative '../../lib/pda/dpda.rb'

describe Stack do
  it 'can push and pop' do
    # given
    target = Stack.new []
    # when
    pushed = target.push 1
    popped = target.pop

    # then
    pushed.must_equal Stack.new [1]
    popped.must_equal Stack.new []
  end

  it 'can get the top element' do
    # given
    target = Stack.new([1]).push(2).push(3)
    # when
    top_element_3 = target.top
    top_element_2 = target.pop.top
    top_element_1 = target.pop.pop.top
    # then
    top_element_3.must_equal 3
    top_element_2.must_equal 2
    top_element_1.must_equal 1
  end

  it 'can give the string representation' do
    # given
    target = Stack.new [1]
    # when
    actual = target.inspect
    # then
    actual.must_equal "#<Stack (1)>"
  end
end

describe PDARule do
  let(:rule) do
    target = PDARule.build({
      state: 1,
      character: '(',
      next_state: 2,
      pop_character: '$',
      push_character: ['b', '$']
    })
    next rule = target
  end

  it 'only applies when it should' do
    # given
    configuration = PDAConfiguration.build({
      state: 1,
      stack: Stack.new(['$'])
    })
    # when
    actual = rule.applies_to?(configuration, '(')
    # then
    actual.must_equal true
  end

  it 'does not apply when it does not matches state' do
    # given
    configuration = PDAConfiguration.build({
      state: 2,
      stack: Stack.new(['$'])
    })
    # when
    actual = rule.applies_to?(configuration, '(')
    # then
    actual.must_equal false
  end

  it 'does not apply when it does not matches the character' do
    # given
    configuration = PDAConfiguration.build({
      state: 2,
      stack: Stack.new(['$', '0'])
    })
    # when
    actual = rule.applies_to?(configuration, '(')
    # then
    actual.must_equal false
  end
end