require 'spec_helper'

describe ROXML do
  describe 'frozen nils' do
    subject { nil }

    # Prior to ruby-2.2, nil was not frozen. This test watches for
    # a regression in previous versions of roxml that caused nil to
    # become frozen.  FIXME: remove after ruby-2.1 support is removed.
    if RUBY_VERSION < "2.2"
      context 'before unmarshalling an XML document' do
        it { is_expected.to_not be_frozen }
      end

      context 'after unmarshalling an XML document' do
        before do
          lib = Library.from_xml(fixture(:library))
        end

        it { is_expected.to_not be_frozen }
      end
    end
  end
end
