module LiquidStream
  class Streams < Stream

    delegate :count, :size, to: :source

    class_attribute :default_source

    def initialize(source=nil, stream_context={})
      @source = source_from(source)
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

    def source_from(s)
      src = s
      src ||= if self.class.default_source.respond_to?(:call)
                self.class.default_source.call
              else
                self.class.default_source
              end
      src ||= []
      src
    end

  end
end
