require 'concurrent/map'

module ROXML
  module Utils
    module_function

    # The following taken from active_support/core_ext/object/blank:

    BLANK_RE = /\A[[:space:]]*\z/
    ENCODED_BLANKS = Concurrent::Map.new do |h, enc|
      h[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
    end

    # A string is blank if it's empty or contains whitespaces only:
    #
    #   ''.blank?       # => true
    #   '   '.blank?    # => true
    #   "\t\n\r".blank? # => true
    #   ' blah '.blank? # => false
    #
    # Unicode whitespace is supported:
    #
    #   "\u00a0".blank? # => true
    #
    # @return [true, false]
    def string_blank?(string)
      # The regexp that matches blank strings is expensive. For the case of empty
      # strings we can speed up this method (~3.5x) with an empty? call. The
      # penalty for the rest of strings is marginal.
      string.empty? ||
        begin
          BLANK_RE.match?(string)
        rescue Encoding::CompatibilityError
          ENCODED_BLANKS[string.encoding].match?(string)
        end
    end
  end
end
