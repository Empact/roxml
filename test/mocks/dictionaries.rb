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
                            :value => :node_content}
end

class DictionaryOfNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :node_name,
                            :value => :node_content}
end

class DictionaryOfGuardedNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :node_name,
                            :value => :node_content}, :in => :definitions
end

class DictionaryOfNameClashes
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => 'node_name',
                            :value => 'node_content'}, :from => :definition
end

class DictionaryOfAttrNameClashes
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => {:attr => :node_name},
                            :value => 'node_content'}, :from => :definition
end