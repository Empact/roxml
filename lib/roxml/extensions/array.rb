module Enumerable #:nodoc:all
  unless method_defined?(:one?)
    def one?
      size == 1
    end
  end
end
