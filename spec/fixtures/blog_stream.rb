class BlogStream < LiquidStream::Stream

  stream :title
  stream :posts
  stream :blog_posts, as: 'PostsStream'

  # allows stream.format["text"]
  stream :format do |arg|
    source.format arg
  end
end
