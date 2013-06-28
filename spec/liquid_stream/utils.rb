module LiquidStream
  class Utils

    def self.stream_class_name_from(name)
      object_class_name = name.to_s.singularize.classify
      class_prefix = if object_class_name =~ /(\w+)Stream/
                       $1.singularize
                     else
                       object_class_name
                     end
      "#{class_prefix}Stream"
    end

    def self.stream_class_from(name)
      stream_class_name_from(name).constantize
    end

  end
end
