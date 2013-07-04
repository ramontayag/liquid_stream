class ImagesStream < LiquidStream::Stream

  stream :find_image, through: :find_image, matching: /\d+/, as: :image

  def find_image(id)
    Image.find(id)
  end

end
