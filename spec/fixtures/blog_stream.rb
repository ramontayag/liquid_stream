class BlogStream < LiquidStream::Stream

  stream :title
  stream :posts

  # allows stream.format["text"]
  stream :format do |arg|
    source.format arg
  end
end
