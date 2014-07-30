class UnionEnumerator
  def self.each(*enumerators, &block)
    enumerators.each do |enumerator|
      enumerator.each do |object|
        yield(object)
      end
    end
  end
end
