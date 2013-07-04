class ImageStream < LiquidStream::Stream

  # http://rubular.com/r/c8JxqJDytH
  # allows stream["230x330"]
  stream :image_resize, matching: /^\d+x\d+#?$/ do |size|
    source.resize(size)
  end

  # allows stream.colorize["red"]
  stream :colorize do |arg|
    source.colorize arg
  end

end
