require 'spec_helper'
require 'hash_to_struct'

describe Hash do
  context 'when empty' do
    describe '#to_struct' do
      it { expect(subject.to_struct).to be_a_kind_of(Struct) }
    end

    describe '#to_open_struct' do
      it { expect(subject.to_open_struct).to be_an_instance_of(OpenStruct) }
    end
  end

  context 'when not empty' do
    let(:hash) {{
      :foo => { :bar => :baz },
      :qux => [:quux, { :corge => :grault }],
    }}

    subject { hash }

    describe '#to_struct' do
      context 'without options' do
        let(:struct) { hash.to_struct }

        subject { struct }
        it { expect(subject).to be_a_kind_of(Struct) }

        describe '.foo' do
          subject { struct.foo }
          it { expect(subject).to be_an_instance_of(Hash) }
        end

        describe '.qux.last' do
          subject { struct.qux.last }
          it { expect(subject).to be_an_instance_of(Hash) }
        end

        describe '.xyzzy' do
          it { expect { subject.xyzzy }.to raise_error(NoMethodError) }
        end

        describe '.foo=' do
          it { expect { subject.foo = 1 }.not_to raise_error }
        end

        describe '.xyzzy=' do
          it { expect { subject.xyzzy = 1 }.to raise_error(NoMethodError) }
        end
      end

      context 'with recursively' do
        let(:struct) { hash.to_struct(:recursively => true) }

        subject { struct }
        it { expect(subject).to be_a_kind_of(Struct) }

        describe '.foo' do
          subject { struct.foo }
          it { expect(subject).to be_a_kind_of(Struct) }
        end

        describe '.qux.last' do
          subject { struct.qux.last }
          it { expect(subject).to be_a_kind_of(Struct) }
        end
      end

      context 'with freeze' do
        let(:struct) { hash.to_struct(:freeze => true) }

        subject { struct }

        describe '.foo=' do
          error_class = RUBY_VERSION >= '1.9' ? RuntimeError : TypeError
          it { expect { subject.foo = 1 }.to raise_error(error_class) }
        end
      end
    end

    describe '#to_open_struct' do
      context 'without options' do
        let(:struct) { hash.to_open_struct }

        subject { struct }
        it { expect(subject).to be_an_instance_of(OpenStruct) }

        describe '.foo' do
          subject { struct.foo }
          it { expect(subject).to be_an_instance_of(Hash) }
        end

        describe '.qux.last' do
          subject { struct.qux.last }
          it { expect(subject).to be_an_instance_of(Hash) }
        end

        describe '.xyzzy' do
          subject { struct.xyzzy }
          it { expect(subject).to be_nil }
        end

        describe '.foo=' do
          it { expect { subject.foo = 1 }.not_to raise_error }
        end

        describe '.xyzzy=' do
          it { expect { subject.xyzzy = 1 }.not_to raise_error }
        end
      end

      context 'with recursively' do
        let(:struct) { hash.to_open_struct(:recursively => true) }

        subject { struct }
        it { expect(subject).to be_an_instance_of(OpenStruct) }

        describe '.foo' do
          subject { struct.foo }
          it { expect(subject).to be_an_instance_of(OpenStruct) }
        end

        describe '.qux.last' do
          subject { struct.qux.last }
          it { expect(subject).to be_an_instance_of(OpenStruct) }
        end
      end

      context 'with freeze' do
        let(:struct) { hash.to_open_struct(:freeze => true) }

        subject { struct }

        describe '.foo=' do
          it { expect { subject.foo = 1 }.to raise_error(TypeError) }
        end

        describe '.xyzzy=' do
          it { expect { subject.xyzzy = 1 }.to raise_error(TypeError) }
        end
      end
    end
  end
end
