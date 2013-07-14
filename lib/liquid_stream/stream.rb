module LiquidStream
  class Stream < Liquid::Drop

    attr_reader :source, :stream_context

    def initialize(source=nil, stream_context={})
      @source = source
      @stream_context = stream_context
    end

    class_attribute :liquid_streams

    def self.stream(method_name, options={}, &block)
      self.liquid_streams ||= {}
      self.liquid_streams[method_name] = {options: options, block: block}

      # DefinesStreamMethod
      if block_given?
        if options.has_key?(:matching)
          self.define_method_with_block method_name, block
        else
          self.delegate_method_with_block_to_new_stream_instance method_name, block
        end
      else
        self.send(:define_method, method_name) do |*args|
          method_result = source.send(method_name)
          options = self.class.liquid_streams[method_name][:options]

          if method_result.respond_to?(:each)
            # BuildsStreamClassName
            streams_class_name = Utils.
              streams_class_name_from(options[:as] || method_name)

            # FailsIfStreamNotDefined
            unless Object.const_defined?(streams_class_name)
              fail StreamNotDefined, "`#{streams_class_name}` is not defined"
            end

            # BuildsStreamClass
            streams_class = streams_class_name.constantize

            # CreatesStreams
            streams_class.new(method_result, stream_context)
          else
            stream_class_name = Utils.
              stream_class_name_from(options[:as] || method_name)

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

    def before_method(method_name)
      stream_name = matching_stream_names_for(method_name).first
      if stream_name
        options = self.liquid_streams[stream_name][:options]
        result = send(stream_name, method_name)

        if options[:as]
          if result.respond_to?(:each)
            # TODO: implement this IF we need to
            # streams_class_name = Util.stream_class_name_from(options[:as])
            # streams_class = streams_class_name.constantize
          else
            stream_class_name = Utils.stream_class_name_from(options[:as])
            stream_class = stream_class_name.constantize
            stream_class.new(result, stream_context)
          end
        else
          result
        end
      end
    end

    private

    def self.define_method_with_block method_name, block
      self.send :define_method, method_name do |method_arg|
        self.instance_exec(method_arg, &block)
      end
    end

    def self.delegate_method_with_block_to_new_stream_instance method_name, block
      self.send :define_method, method_name do |*method_args|
        class_name = generate_stream_class_name method_name
        stream_klass = find_or_create_stream_class class_name

        stream_instance = stream_klass.new(source, stream_context)

        stream_klass.send :define_method, :before_method do |before_method_arg|
          stream_instance.instance_exec(before_method_arg, &block)
        end
        stream_instance
      end
    end

    def matching_stream_names_for(method_name)
      self.class.liquid_streams.select do |stream_name, data|
        match_regex = data[:options][:matching]
        (match_regex && method_name =~ match_regex) || match_regex.nil?
      end.keys
    end

    def find_or_create_stream_class class_name
      klass = if Object.const_defined?(class_name)
                class_name.constantize
              else
                Object.const_set(class_name, Class.new(LiquidStream::Stream))
              end
      klass
    end

    def generate_stream_class_name method_name
      new_class_name = self.class.to_s.
                       gsub("Stream", "#{method_name.to_s.classify}Stream").
                       strip
      new_class_name
    end
  end
end
