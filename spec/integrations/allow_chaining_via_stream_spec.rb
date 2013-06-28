require 'spec_helper'

describe LiquidStream do

  it 'should allow chaining via the stream method' do
    post_1 = Post.new(title: 'First')
    post_2 = Post.new(title: 'Second')

    blog = Blog.new(title: 'First blog',
                    posts: [post_1, post_2])

    blog_stream = BlogStream.new(blog)
    expect(blog_stream.posts.count).to eq(2)
    blog_stream.posts.each do |post_stream|
      expect(post_stream).to be_kind_of(PostStream)
    end
  end

end
