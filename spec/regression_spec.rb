require 'spec_helper'

describe ROXML do
  describe 'frozen nils' do
    subject { nil }

    context 'before unmarshalling an XML document' do
      it { should_not be_frozen }
    end

    context 'after unmarshalling an XML document' do
      before do
        lib = Library.from_xml(fixture(:library))
      end

      it { should_not be_frozen }
    end
  end
end
