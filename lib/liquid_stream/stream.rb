module LiquidStream
  class Stream < Liquid::Drop

    attr_reader :source, :stream_context

    def initialize(source=nil, stream_context={})
      @source = source
      @stream_context = stream_context
    end

    class_attribute :liquid_streams
    self.liquid_streams = {}

    def self.stream(method_name, options={}, &block)
      self.liquid_streams[method_name] = {options: options, block: block}

      # DefinesStreamMethod
      if block_given?
        puts "Defining #{method_name} on #{self}"
        self.send :define_method, method_name do |method_arg|
          class_name = "Image#{method_name.to_s.classify}Stream"
          puts "called #{method_name} on #{class_name}"
          klass = Object.const_set(class_name, Class.new(LiquidStream::Stream))
          stream = klass.new(source, stream_context)
          klass.send :define_method, :before_method do |before_method_arg|
            puts "Executing #{before_method_arg} with #{block} in #{stream}"
            stream.instance_exec(before_method_arg, &block)
          end
          stream
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
      puts "IN BEFORE METHOD #{method_name}"
      stream_name = matching_stream_names_for(method_name).first
      puts "This is the stream name: #{stream_name} for #{method_name}"
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
          puts "Non enum for #{stream_name}"
          puts "Block is #{self.liquid_streams[stream_name][:block]}"
          if block = self.liquid_streams[stream_name][:block]
            puts "BLOCK GIVEN"
            # define a method that returns a temporary stream that can capture
            temp_class = <<-EOS
              class ImageColorizeStream
                stream :colorize, through: :colorize

                def colorize(color)
                  source.colorize(color)
                end
              end
            EOS
            eval(temp_class)
            stream_instance = ImageColorizeStream.new(source, stream_context)
            stream_instance.send(:colorize, method_name)
          else
            result
          end
        end
      end
    end

    private

    def matching_stream_names_for(method_name)
      self.class.liquid_streams.select do |stream_name, data|
        match_regex = data[:options][:matching]
        if data[:block]
          (match_regex && method_name =~ match_regex) || match_regex.nil?
        end
      end.keys
    end

  end
end
