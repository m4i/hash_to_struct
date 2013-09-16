require 'hash_to_struct/version'

module HashToStruct
  @@struct_class_cache = {}

  # @param options [Hash]
  # @return [Struct]
  def to_struct(options = {})
    object_to_struct(self, options)
  end

  # @param options [Hash]
  # @return [OpenStruct]
  def to_open_struct(options = {})
    require 'ostruct'
    object_to_struct(self, options.merge(:open_struct => true))
  end

  private

  # @param object [Object]
  # @param options [Hash]
  # @return [Object]
  def object_to_struct(object, options)
    case object
    when ::Hash
      hash = {}

      object.each do |key, value|
        hash[key.to_s] = options[:recursively] ?
          object_to_struct(value, options) : value
      end

      if options[:open_struct]
        ::OpenStruct.new(hash)

      else
        keys   = hash.keys.sort
        values = keys.map {|key| hash[key] }
        klass  = @@struct_class_cache[keys] ||= keys.empty? ?
          ::Struct.new('EmptyForHashToStruct') :
          ::Struct.new(*keys.map(&:to_sym))
        klass.new(*values)
      end

    when ::Array
      object.map do |value|
        object_to_struct(value, options)
      end

    else
      object

    end.tap do |object|
      object.freeze if options[:freeze]
    end
  end
end


class Hash
  include HashToStruct
end
