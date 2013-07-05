class ImagesStream < LiquidStream::Stream

  stream :find_image, matching: /\d+/, as: :image do |id|
    Image.find(id)
  end

end
