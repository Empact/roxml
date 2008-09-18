require 'lib/roxml'

class DictionaryOfAttrs
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:attrs => [:dt, :dd]}, :in => :definitions
end

class DictionaryOfTexts
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :word,
                            :value => :meaning}
end

class DictionaryOfMixeds
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => {:attr => :word},
                            :value => :text_content}
end

class DictionaryOfNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :node_name,
                            :value => :text_content}
end

class DictionaryOfGuardedNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :node_name,
                            :value => :text_content}, :in => :definitions
end