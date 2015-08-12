class Struct
  def self.build(hash)
    struct = new
    hash.each do |key, value|
      setter_sym = "#{key.to_s}=".to_sym
      struct.send(setter_sym, value)
    end

    struct
  end
end