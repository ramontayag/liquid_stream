module LiquidStream
  class Streams < Stream

    delegate :count, :size, to: :source

    def initialize(source, stream_context={})
      @source = source
      @stream_context = stream_context
    end

    def first
      @first ||= singleton_class.new(@source.first)
    end

    def last
      @last ||= singleton_class.new(@source.last)
    end

    def to_a
      @source.map do |object|
        singleton_class.new(object)
      end
    end

    def each(&block)
      to_a.each(&block)
    end

    private

    def singleton_class
      @singleton_class ||= Utils.
        stream_class_from(@stream_context[:method] || self.class)
    end

  end
end
