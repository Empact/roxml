class Array
  # Translates an array into a hash, where each element of the array is
  # an array with 2 elements:
  #
  #   >> [[:key, :value], [1, 2], ['key', 'value']].to_h
  #   => {:key => :value, 1 => 2, 'key' => 'value}
  #
  def to_h
    returning({}) do |result|
      each do |(k, v)|
        result[k] = v
      end
    end
  end
end