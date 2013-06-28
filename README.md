# LiquidStream

Allows chaining of Liquid objects with a clean DSL, which allows a more Ruby-like way to traverse Liquid objects. For example:

    {% for post in posts.published.popular do %}
      {{ post.name }}
    {% endfor %}

[See why](https://github.com/Shopify/liquid/issues/29).

## Installation

Add this line to your application's Gemfile:

    gem 'liquid_stream'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liquid_stream

## Usage

Create a stream that represents one post:

    class PostStream < LiquidStream::Stream
      stream :name
    end

Create a stream collection that represents a collection of posts:

    class PostsStream < LiquidStream::Streams
      stream :published
      stream :popular
    end

    posts = user.posts
    posts_stream = PostsStream.new(posts)

    Liquid::Template.parse("liquid here").render('posts' => posts_stream)

## Stream is a Liquid::Drop

A stream is a drop - with extra stuff added on to it.

## Stream carefully

You may not want to expose something that will make it easy for a user to break your system. For example, let's say you have 2 million posts, then you won't want to expose all of those posts through a stream:

    posts = Post.scoped # ActiveRecord's scoped returns a lazily executed Arel. If you call #all on this, you'll get 2 million records
    posts_stream = PostsStream.new(posts)
    posts_stream.to_a # boom!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
