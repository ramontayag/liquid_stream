class PostsStream < LiquidStream::Streams

  stream :popular, with: 'PostsStream'

end
