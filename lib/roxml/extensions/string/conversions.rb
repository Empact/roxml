class String
  def between(separator, &block)
    split(separator).collect(&block).join(separator)
  end
end