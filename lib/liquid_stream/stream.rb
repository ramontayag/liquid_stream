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
          streams_class_name = if options.has_key?(:with)
                                options[:with]
                              else
                                Utils.streams_class_name_from(method_name)
                              end

          # FailsIfStreamNotDefined
          unless Object.const_defined?(streams_class_name)
            fail StreamNotDefined, "`#{streams_class_name}` is not defined"
          end

          # BuildsStreamClass
          streams_class = streams_class_name.constantize

          # CreatesStreams
          # NOTE: kinda ugly though that we have to pass the method like this.
          new_context = stream_context.merge(method: options[:with] || method_name)
          streams_class.new(method_result, new_context)
        else
          stream_class_name = Utils.stream_class_name_from(method_name)

          if Object.const_defined?(stream_class_name)
            stream_class = stream_class_name.constantize
            stream_class.new(method_result, stream_context)
          else
            method_result
          end
        end
      end
    end

  end
end
