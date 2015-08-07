require_relative '../test_helper.rb'
require_relative '../../lib/regex/pattern.rb'
require_relative '../../lib/regex/grammar.rb'

describe Pattern do  
  it 'produces the correct regex string given a composed rule object' do
    # arrange
    expected = "(ab|a)*"
    target = repeat(
      choose(
        concat(lit('a'), lit('b')),
        lit('a')
      )
    )
    # act
    actual = target.to_s
    # assert
    actual.must_equal expected
  end

  it 'can create an empty target' do
    # arrange
    empty = Empty.new()
    # act - assert
    target = empty
    target.matches?('').must_equal true
    target.matches?('a').must_equal false
    target.matches?('0').must_equal false
    target.matches?('#').must_equal false
  end

  it 'can create an literal target' do
    # arrange
    literal = lit('a')
    # act - assert
    target = literal
    target.matches?('a').must_equal true
    target.matches?('b').must_equal false
    target.matches?('aa').must_equal false
    target.matches?('').must_equal false
    target.matches?('0').must_equal false
    target.matches?('#').must_equal false
  end

  it 'can concatenate two literals' do
    # given
    literal_a = lit('a')
    literal_b = lit('b')
    # act
    concatenation = concat(literal_a, literal_b)
    # assert
    concatenation.matches?('a').must_equal false
    concatenation.matches?('b').must_equal false
    concatenation.matches?('aab').must_equal false
    concatenation.matches?('abb').must_equal false
    concatenation.matches?('').must_equal false
    concatenation.matches?('ab').must_equal true
  end

  it 'can concatenate concatenations' do
    # given
    literal_a = lit('a')
    literal_b = lit('b')
    literal_c = lit('c')
    inner_concat = concat(literal_b, literal_c)

    # act
    concatenation = concat(literal_a, inner_concat)
    # assert
    concatenation.matches?('a').must_equal false
    concatenation.matches?('bc').must_equal false
    concatenation.matches?('abc').must_equal true
    concatenation.matches?('abcc').must_equal false
  end

  it 'can choose between two literals' do
    # given
    literal_a = lit('a')
    literal_b = lit('b')
    # act
    concatenation = choose(literal_a, literal_b)
    # assert
    concatenation.matches?('a').must_equal true
    concatenation.matches?('b').must_equal true
    concatenation.matches?('aa').must_equal false
    concatenation.matches?('bb').must_equal false
    concatenation.matches?('').must_equal false
    concatenation.matches?('x').must_equal false
    concatenation.matches?('ab').must_equal false
  end

  it 'can choose between two composed options' do
    # given
    literal_a = lit('a')
    literal_b = lit('b')
    concatenation_ab = choose(literal_a, literal_b)
    literal_c = lit('c')
    literal_d = lit('d')
    concatenation_cd = choose(literal_c, literal_d)

    concatenation = choose(concatenation_ab, concatenation_cd)
    # act
    # assert
    concatenation.to_s.must_equal 'a|b|c|d'
    concatenation.matches?('a').must_equal true
    concatenation.matches?('b').must_equal true
    concatenation.matches?('c').must_equal true
    concatenation.matches?('d').must_equal true
    concatenation.matches?('aa').must_equal false
    concatenation.matches?('bb').must_equal false
    concatenation.matches?('ab').must_equal false
    concatenation.matches?('cc').must_equal false
    concatenation.matches?('dd').must_equal false
    concatenation.matches?('cd').must_equal false
  end

  it 'can configure a regex made up of cooncatenation and choose' do
    # arrange
    target = marcel()
    # act
    # assert
    target.to_s.must_equal '(M|m)arcel'
    target.matches?('marcel').must_equal true
    target.matches?('Marcel').must_equal true
    target.matches?('Pedro').must_equal false
    target.matches?('martin').must_equal false
  end

  it 'can configure a repeat pattern' do
    # arrange
    repeat_a = repeat(lit('a'))
    # act
    # assert
    repeat_a.to_s.must_equal '(a)*'
    repeat_a.matches?('').must_equal true
    repeat_a.matches?('a').must_equal true
    repeat_a.matches?('aa').must_equal true
    repeat_a.matches?('aaa').must_equal true

    repeat_a.matches?('b').must_equal false
    repeat_a.matches?('ba').must_equal false
    repeat_a.matches?('ab').must_equal false
    repeat_a.matches?('aba').must_equal false
    repeat_a.matches?('ababbbb').must_equal false
  end

  it 'can repeat a composed pattern' do
    # arrange
    pattern = repeat(choose(concat(str('ab')), concat(str('12'))))
    # act
    # assert
    pattern.to_s.must_equal '(ab|12)*'
    pattern.matches?('11').must_equal false
    pattern.matches?('aa').must_equal false
    pattern.matches?('ab').must_equal true
    pattern.matches?('12').must_equal true
    pattern.matches?('ab12').must_equal true
    pattern.matches?('ab12abab').must_equal true
    pattern.matches?('').must_equal true
  end

  it 'can parse a pattern' do
    # arrange
    regex = "(a|b)*"
    target = PatternParser.new
    # act
    parse_tree = target.parse(regex)
    pattern = parse_tree.to_ast

    # assert
    pattern.to_s.must_equal regex
  end

  def marcel
    m = choose(str('Mm'))
    arcel = concat(str('arcel'))
    concat(m, arcel)
  end

  def str(literals)
    literals.chars.map {|char| lit(char)}
  end

  def lit(char)
    return Literal.new(char)
  end

  def repeat(rule)
    Repeat.new(rule)
  end

  def concat(*rules)
    rules = rules[0] if rules[0].is_a? Array
    compose(rules) { |first, second| Concatenate.new(first, second) }
  end

  def choose(*rules)
    rules = rules[0] if rules[0].is_a? Array
    compose(rules) { |first, second| Choose.new(first, second) }
  end

  def compose(rules)
    rules.inject { |memo, rule| yield(memo, rule) }
  end
end