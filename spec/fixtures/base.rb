class Base

  include ActiveModel::AttributeMethods
  include ActiveModel::Validations

  def initialize(attributes={})
    @attributes = attributes.stringify_keys
  end

  def attributes
    @attributes
  end

  private

  # can't seem to get the attributes to work properly... hack it
  def method_missing(method_name, *args, &block)
    if attributes.has_key?(method_name.to_s)
      self.class.send(:define_method, method_name, *args) do
        attributes[method_name.to_s]
      end
      send(method_name, *args)
    else
      super
    end
  end

end
