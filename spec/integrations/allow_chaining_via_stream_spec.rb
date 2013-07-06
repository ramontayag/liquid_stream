require 'spec_helper'

describe LiquidStream do

  it 'should allow chaining via the stream method' do
    post_1 = Post.new(title: 'First')
    post_2 = Post.new(title: 'Second')
    post_3 = Post.new(title: 'Third')

    blog = Blog.new(title: 'First blog')
    posts = [post_1, post_2, post_3]
    blog.stub(:posts) { posts }
    popular_posts = [post_1, post_2]
    posts.stub(:popular) { popular_posts }

    blog_stream = BlogStream.new(blog)

    template = <<-WUT
      {{blog.posts.popular.size}}
      <ul>
        {% for post in blog.posts.popular %}
        <li>{{post.title}}</li>
        {% endfor %}
      </ul>
    WUT
    html = Liquid::Template.parse(template).render('blog' => blog_stream)
    doc = Capybara.string(html)
    li_els = doc.all('ul li')
    expect(li_els.size).to eq(2)
    expect(li_els.first.text).to eq('First')
    expect(li_els.last.text).to eq('Second')
  end

  it 'should mimic accepting of arguments' do
    template = <<-WUT
      {{image["240x330#"]}}
      {{image["250x350"]}}
      {{image.colorize["yellow"]}}
      {{blog.format["text"]}}
    WUT

    image = double
    image.stub(:resize).with("240x330#") { "http://image.com/240x330.jpg" }
    image.stub(:resize).with("250x350") { "http://image.com/250x350.jpg" }
    image.stub(:colorize).with("yellow") { "http://image.com/yellow_colorized.jpg" }
    blog = double
    blog.stub(:format).with("text") { "some text" }

    image_stream = ImageStream.new(image)
    blog_stream  = BlogStream.new(blog)
    result = Liquid::Template.parse(template).
                              render('image' => image_stream, 'blog' => blog_stream)
    expect(result).to include("http://image.com/240x330.jpg")
    expect(result).to include("http://image.com/250x350.jpg")
    expect(result).to include("http://image.com/yellow_colorized.jpg")
    expect(result).to include("some text")
  end

end
