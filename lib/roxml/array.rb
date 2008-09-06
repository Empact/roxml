class Array
  def to_h
    returning({}) do |result|
      each do |(k, v)|
        result[k] = v
      end
    end
  end
end