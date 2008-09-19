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
                            :value => :content}
end

class DictionaryOfNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :name,
                            :value => :content}
end

class DictionaryOfGuardedNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => :name,
                            :value => :content}, :in => :definitions
end

class DictionaryOfNameClashes
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => 'name',
                            :value => 'content'}, :from => :definition
end

class DictionaryOfAttrNameClashes
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, {:key => {:attr => :name},
                            :value => 'content'}, :from => :definition
end