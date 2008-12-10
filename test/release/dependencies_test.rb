require 'test/unit'

class TestDependencies < Test::Unit::TestCase
  def assert_dependency_included(*args)
    # assert methods are removed
    args.each do |type, method, source|
      type.send(:remove_method, method) if type.instance_methods.include?(method.to_s)
      assert !type.instance_methods.include?(method.to_s)
    end

    load File.join(File.dirname(__FILE__), '../../lib/roxml.rb')

    # assert_instance_methods returned to their rightful positions
    args.each do |type, method, source|
      assert type.instance_methods.include?(method.to_s)
    end

    #assert ROXML has what it needs
    assert_nothing_raised do
      Class.new do
        include ROXML

        xml_reader :deps
      end
    end
  end

  def test_symbol_to_proc_is_added_by_roxml
    assert_dependency_included([Symbol, :to_proc, 'active_support/core_ext/symbol.rb'],
                               [Enumerable, :one?, 'extensions/enumerable.rb'])
  end
end