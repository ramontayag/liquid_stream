require 'spec_helper'

describe LiquidStream::Streams do

  describe '#first' do
    context 'given the stream method data' do
      it 'should return an stream derived from the given stream method' do
        comments = ['a', 'b']
        streams = described_class.new(comments, method: :posts)
        post_stream = double
        PostStream.stub(:new).with('a') { post_stream }
        expect(streams.first).to eq(post_stream)
      end
    end
  end

  describe '#last' do
    context 'given the stream method data' do
      it 'should return an stream derived from the given stream method' do
        comments = ['a', 'b']
        streams = described_class.new(comments, method: :posts)
        post_stream = double
        PostStream.stub(:new).with('b') { post_stream }
        expect(streams.last).to eq(post_stream)
      end
    end
  end

  describe '#count' do
    it 'should return the count' do
      posts = ['a', 'b']
      streams = described_class.new(posts)
      expect(streams.count).to eq(2)
    end
  end

  describe 'when streaming a scope' do
    it 'should return the stream collection of that scope' do
      blogs = ['a', 'b']
      awesome_blogs = ['b']
      blogs.stub(:awesome) { awesome_blogs }
      streams = BlogsStream.new(blogs)
      expect(streams.awesome.size).to eq(1)
      expect(streams.awesome.first).to be_kind_of(BlogStream)
    end
  end

  describe '#to_a' do
    it 'should return an array of stream objects' do
      blogs = ['a', 'b']
      streams = BlogsStream.new(blogs)
      array = streams.to_a
      expect(array).to be_kind_of(Array)
      expect(array.first).to be_kind_of(BlogStream)
    end
  end

  describe '#each' do
    it 'should allow looping through the elements of the stream' do
      blogs = ['a', 'b']
      streams = BlogsStream.new(blogs)
      streams.each do |stream|
        expect(stream).to be_kind_of(BlogStream)
      end
    end
  end


  describe '.stream' do
    context '`as` option is given' do
      context 'result is not an enumerable' do
        it 'should return the object instantiated in the stream class' do
          image = double
          Image.stub(:find).with('2') { image }
          controller = double
          images_stream = ImagesStream.new(nil, controller: controller)
          expect(images_stream['2']).to be_kind_of(ImageStream)
          expect(images_stream['2'].source).to eq(image)
          expect(images_stream['2'].stream_context).to include(controller: controller)
        end
      end
    end
  end

end
