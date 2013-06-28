module LiquidStream
  class Stream < Liquid::Drop

    attr_reader :source, :stream_context

    def initialize(source, stream_context={})
      @source = source
      @stream_context = stream_context
    end

    class_attribute :liquid_streams
    self.liquid_streams = {}

    def self.stream(method_name, options={}, &block)
      self.liquid_streams[method_name] = {options: options, block: block}

      # DefinesStreamMethod
      self.send(:define_method, method_name) do
        method_result = source.send(method_name)
        options = self.class.liquid_streams[method_name][:options]

        if method_result.respond_to?(:each)
          # BuildsStreamClassName
          stream_class_name = if options.has_key?(:with)
                                options[:with]
                              else
                                Utils.stream_class_name_from(method_name)
                              end

          # FailsIfStreamNotDefined
          unless Object.const_defined?(stream_class_name)
            fail StreamNotDefined, "`#{stream_class_name}` is not defined"
          end

          Streams.new(method_result,
                      method: options[:with] || method_name)
          # # BuildsStreamClass
          # stream_class = stream_class_name.constantize

          # # CreatesStreams
          # method_result.map do |resource|
          #   # TODO should pass context
          #   stream_class.new(resource)
          # end
        else
          method_result
        end
      end
    end

  end
end
