module LiquidStream
  class Stream

    class_attribute :temporary_streams

    def self.snapshot_streams!
      self.temporary_streams = self.liquid_streams
    end

    def self.restore_streams!
      self.liquid_streams = self.temporary_streams
    end

  end
end
