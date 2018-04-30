class Object
  def to_data
    ParsedData.new self, :hash
  end
end
