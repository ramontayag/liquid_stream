# LiquidStream

This library does two things:

1) Allows **chaining** of Liquid objects with a clean DSL, which allows a more Ruby-like way to traverse Liquid objects. For example:

    {% for post in posts.published.popular do %}
      {{ post.name }}
    {% endfor %}

2) Mimic accepting of arguments on drops

    {{ image.resize_to["240x240#"].url }}
    {{ images["23"].url }}

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

### "Accepting" Arguments

Given:

    class ImageStream < LiquidStream::Stream
      stream :process, as: :image do |command|
        source.process command
      end

      stream :url
    end

    image = Image.find(2323)
    image_stream = ImageStream.new(image)

Then, in Liquid:

    {{image_stream.process["200x200"].process["grayscale"].url | image_tag}}

### Stream Context

LiquidStream has a notion of context too. To avoid confusion with Liquid's context, let's call it stream_context. The reason there's a stream context is so that if you have a need to share information within a chained stream, then you need to pass it as a hash. I found this useful when the I needed the streams to know about which controller it was being used:

    class PostsController < ApplicationController
      def show
        post = Post.find(params[:id])
        post_stream = PostStream.new(post, controller: self)
        Liquid::Template.parse("{{post.blog.children.first.url}}").render('posts' => post_stream)
      end
    end

    class PostStream < LiquidStream::Stream
      include Rails.application.helpers.url_helpers

      def url
        if controller.request.fullpath =~ /^preview/
          polymorphic_path :preview, source
        else
          polyorphic_path source
        end
      end

      private

      def controller
        stream_context[:controller]
      end

    end

It's a very specific use-case, but this allows you to render the links to other posts a different way if the person viewing is viewing the post from "/preview/posts/:id" compared to what is rendered when in "/posts/:id". If you find other uses please fork this repo and add it to this readme.

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
