%w(active_support deprecation array string).each do |file|
  require File.join(File.dirname(__FILE__), 'extensions', file)
end