module LiquidStream
  class Utils

    def self.stream_class_name_from(name)
      "#{class_prefix_from(name).singularize}Stream"
    end

    def self.stream_class_from(name)
      stream_class_name_from(name).constantize
    end

    def self.streams_class_name_from(name)
      "#{class_prefix_from(name).pluralize}Stream"
    end

    private

    def self.class_prefix_from(name)
      name = name.to_s if name.respond_to?(:to_s)
      name =~ /^(\w+)Stream$/ ? $1 : name.classify
    end

  end
end
