class Array
  # Translates an array into a hash.  Where each element of the array is
  # an array with 2 elements, the key and value
  def to_h
    returning({}) do |result|
      each do |(k, v)|
        result[k] = v
      end
    end
  end
end