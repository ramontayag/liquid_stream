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

end
