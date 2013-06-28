require 'spec_helper'

describe LiquidStream::Stream do

  describe '.stream' do
    context 'streams to an enumerable' do
      it 'allows access to another stream, using stream name as default reader' do
        post_1 = Post.new(title: 'Post 1')
        post_2 = Post.new(title: 'Post 2')
        blog = Blog.new(title: 'Blog', posts: [post_1, post_2])
        blog_stream = BlogStream.new(blog)
        posts_stream = blog_stream.posts
        expect(posts_stream).to be_kind_of(LiquidStream::Streams)
        expect(posts_stream.size).to eq(2)
        expect(posts_stream.first).to be_kind_of(PostStream)
        expect(posts_stream.first.title).to eq('Post 1')
        expect(posts_stream.last).to be_kind_of(PostStream)
        expect(posts_stream.last.title).to eq('Post 2')
      end

      context 'no stream class for the enumerable exists' do
        it 'should raise LiquidStream::StreamNotDefined error' do
          PostStream.stream(:comments)
          post = Post.new(comments: [])
          post_stream = PostStream.new(post)
          expect {post_stream.comments}.
            to raise_error(LiquidStream::StreamNotDefined,
                           "`CommentsStream` is not defined")
        end
      end

      it 'should make the class respond to the method' do
        PostStream.stream(:comments)
        post = Post.new(comments: [])
        post_stream = PostStream.new(post)
        expect(post_stream).to respond_to(:comments)
      end

      it 'should have the stream name listed as an instance method' do
        PostStream.stream(:comments)
        PostStream.instance_methods.should include(:comments)
      end

      it 'should pass in any context' do
        post = Post.new(title: 'Post')
        blog = Blog.new(title: 'Blog', posts: [post])
        controller = double
        blog_stream = BlogStream.new(blog, controller: controller)
        posts_stream = blog_stream.posts
        expect(posts_stream.stream_context).to include(controller: controller)
      end
    end

    context 'streams to a non enumerable' do
      context 'a stream class exists for the object' do
        it 'should return the object instantiated in the stream' do
          blog = Blog.new(title: 'Blog')
          post = Post.new(title: 'Post', blog: blog)
          PostStream.stream(:blog)
          stream = PostStream.new(post)
          expect(stream.blog).to be_kind_of(BlogStream)
          expect(stream.blog.title).to eq('Blog')
        end
      end

      it 'should pass in any context' do
        blog = Blog.new(title: 'Blog')
        post = Post.new(title: 'Post', blog: blog)
        controller = double
        PostStream.stream(:blog)
        stream = PostStream.new(post, controller: controller)
        expect(stream.blog.stream_context).to eq(controller: controller)
      end

      context 'given a specific stream class to use' do
        it 'should instantiate the object in the stream class' do
          blog = Blog.new(title: 'Blog')
          post = Post.new(title: 'Post', blog: blog)
          PostStream.stream(:blog, as: 'PostStream')
          stream = PostStream.new(post)
          expect(stream.blog).to be_kind_of(PostStream)
          expect(stream.blog.title).to eq('Blog')
        end
      end

      context 'no stream class exists for the object' do
        it 'returns that object' do
          post = Post.new(title: 'PostMan')
          post_stream = PostStream.new(post)
          expect(post_stream.title).to eq('PostMan')
        end
      end
    end

    context 'given the stream class name' do
      it 'should use the given stream class' do
        comment = Comment.new(body: 'Hi')
        post = Post.new(title: 'Post', comments: [comment])
        PostStream.stream(:comments, as: 'BlogsStream')
        post_stream = PostStream.new(post)
        expect(post_stream.comments.first).to be_kind_of(BlogStream)
      end
    end
  end

end
