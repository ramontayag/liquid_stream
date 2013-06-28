require 'spec_helper'

describe LiquidStream::Utils do

  describe '.stream_class_name_from' do
    it 'should return the best-guess class name for the argument' do
      expect(described_class.stream_class_name_from(:posts)).to eq('PostStream')
      expect(described_class.stream_class_name_from(:post)).to eq('PostStream')
      expect(described_class.stream_class_name_from(:blogs)).to eq('BlogStream')
    end

    context 'name already contains Stream' do
      it 'should return the text as is' do
        expect(described_class.stream_class_name_from('PostsStream')).
          to eq('PostStream')
      end
    end

    context 'name is a collection stream class' do
      it 'should return the singular version string' do
        expect(described_class.stream_class_name_from(PostStream)).
          to eq('PostStream')
      end
    end
  end

  describe '.stream_class_from' do
    it 'should return the constantized class of the best-guess class name for the arg' do
      expect(described_class.stream_class_from(:posts)).to eq(PostStream)
      expect(described_class.stream_class_from(:blog)).to eq(BlogStream)
    end
  end

  describe '.streams_class_name_from' do
    it 'should return the pluralized best guess class name from the arg' do
      expect(described_class.streams_class_name_from(:post)).
        to eq('PostsStream')
      expect(described_class.streams_class_name_from('BlogStream')).
        to eq('BlogsStream')
    end
  end

end
