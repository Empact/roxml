class LibraryWithFines

  include ROXML

  xml_name 'library'

  xml_accessor :name

  xml_accessor :fines,
               :as   => { :key => 'name', :value => 'desc' },
               :from => 'fine',
               :in   => 'policy/fines'
end