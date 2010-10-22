require_relative "./../../lib/roxml"

class DictionaryOfAttrs
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, :as => {:key => '@dt',
                                   :value => '@dd'}, :in => :definitions
end

class DictionaryOfTexts
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, :as => {:key => :word,
                            :value => :meaning}
end

class DictionaryOfMixeds
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, :as => {:key => '@word',
                            :value => :content}
end

class DictionaryOfNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, :as => {:key => :name,
                            :value => :content}
end

class DictionaryOfGuardedNames
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, :as => {:key => :name,
                            :value => :content}, :in => :definitions
end

class DictionaryOfNameClashes
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, :as => {:key => 'name',
                            :value => 'content'}, :from => :definition
end

class DictionaryOfAttrNameClashes
  include ROXML

  xml_name :dictionary
  xml_reader :definitions, :as => {:key => '@name',
                            :value => 'content'}, :from => :definition
end