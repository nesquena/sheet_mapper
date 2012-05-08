class Hash
  # Return a new hash with all keys converted to strings.
  def stringify_keys
    dup.stringify_keys!
  end

  # Destructively convert all keys to strings.
  def stringify_keys!
    keys.each do |key|
      self[key.to_s] = delete(key)
    end
    self
  end

  # Return a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+.
  def symbolize_keys
    dup.symbolize_keys!
  end

  # Destructively convert all keys to symbols, as long as they respond
  # to +to_sym+.
  def symbolize_keys!
    keys.each do |key|
      self[(key.to_sym rescue key) || key] = delete(key)
    end
    self
  end

  alias_method :to_options,  :symbolize_keys
  alias_method :to_options!, :symbolize_keys!

  # Validate all keys in a hash match *valid keys, raising ArgumentError on a mismatch.
  # Note that keys are NOT treated indifferently, meaning if you use strings for keys but assert symbols
  # as keys, this will fail.
  #
  # ==== Examples
  #   { :name => "Rob", :years => "28" }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key(s): years"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys("name", "age") # => raises "ArgumentError: Unknown key(s): name, age"
  #   { :name => "Rob", :age => "28" }.assert_valid_keys(:name, :age) # => passes, raises nothing
  def assert_valid_keys(*valid_keys)
    unknown_keys = keys - [valid_keys].flatten
    raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
  end


  # Returns an <tt>ActiveSupport::HashWithIndifferentAccess</tt> out of its receiver:
  #
  #   {:a => 1}.with_indifferent_access["a"] # => 1
  #
  def with_indifferent_access
    ActiveSupport::HashWithIndifferentAccess.new_from_hash_copying_default(self)
  end

  # Called when object is nested under an object that receives
  # #with_indifferent_access. This method will be called on the current object
  # by the enclosing object and is aliased to #with_indifferent_access by
  # default. Subclasses of Hash may overwrite this method to return +self+ if
  # converting to an <tt>ActiveSupport::HashWithIndifferentAccess</tt> would not be
  # desirable.
  #
  #   b = {:b => 1}
  #   {:a => b}.with_indifferent_access["a"] # calls b.nested_under_indifferent_access
  #
  alias nested_under_indifferent_access with_indifferent_access
end


# This class has dubious semantics and we only have it so that
# people can write <tt>params[:key]</tt> instead of <tt>params['key']</tt>
# and they get the same value for both keys.

module ActiveSupport
  class HashWithIndifferentAccess < Hash

    # Always returns true, so that <tt>Array#extract_options!</tt> finds members of this class.
    def extractable_options?
      true
    end

    def with_indifferent_access
      dup
    end

    def nested_under_indifferent_access
      self
    end

    def initialize(constructor = {})
      if constructor.is_a?(Hash)
        super()
        update(constructor)
      else
        super(constructor)
      end
    end

    def default(key = nil)
      if key.is_a?(Symbol) && include?(key = key.to_s)
        self[key]
      else
        super
      end
    end

    def self.new_from_hash_copying_default(hash)
      new(hash).tap do |new_hash|
        new_hash.default = hash.default
      end
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    # Assigns a new value to the hash:
    #
    #   hash = HashWithIndifferentAccess.new
    #   hash[:key] = "value"
    #
    def []=(key, value)
      regular_writer(convert_key(key), convert_value(value))
    end

    alias_method :store, :[]=

    # Updates the instantized hash with values from the second:
    #
    #   hash_1 = HashWithIndifferentAccess.new
    #   hash_1[:key] = "value"
    #
    #   hash_2 = HashWithIndifferentAccess.new
    #   hash_2[:key] = "New Value!"
    #
    #   hash_1.update(hash_2) # => {"key"=>"New Value!"}
    #
    def update(other_hash)
      if other_hash.is_a? HashWithIndifferentAccess
        super(other_hash)
      else
        other_hash.each_pair { |key, value| regular_writer(convert_key(key), convert_value(value)) }
        self
      end
    end

    alias_method :merge!, :update

    # Checks the hash for a key matching the argument passed in:
    #
    #   hash = HashWithIndifferentAccess.new
    #   hash["key"] = "value"
    #   hash.key? :key  # => true
    #   hash.key? "key" # => true
    #
    def key?(key)
      super(convert_key(key))
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    # Fetches the value for the specified key, same as doing hash[key]
    def fetch(key, *extras)
      super(convert_key(key), *extras)
    end

    # Returns an array of the values at the specified indices:
    #
    #   hash = HashWithIndifferentAccess.new
    #   hash[:a] = "x"
    #   hash[:b] = "y"
    #   hash.values_at("a", "b") # => ["x", "y"]
    #
    def values_at(*indices)
      indices.collect {|key| self[convert_key(key)]}
    end

    # Returns an exact copy of the hash.
    def dup
      self.class.new(self).tap do |new_hash|
        new_hash.default = default
      end
    end

    # Merges the instantized and the specified hashes together, giving precedence to the values from the second hash.
    # Does not overwrite the existing hash.
    def merge(hash)
      self.dup.update(hash)
    end

    # Performs the opposite of merge, with the keys and values from the first hash taking precedence over the second.
    # This overloaded definition prevents returning a regular hash, if reverse_merge is called on a <tt>HashWithDifferentAccess</tt>.
    def reverse_merge(other_hash)
      super self.class.new_from_hash_copying_default(other_hash)
    end

    def reverse_merge!(other_hash)
      replace(reverse_merge( other_hash ))
    end

    # Removes a specified key from the hash.
    def delete(key)
      super(convert_key(key))
    end

    def stringify_keys!; self end
    def stringify_keys; dup end
    undef :symbolize_keys!
    def symbolize_keys; to_hash.symbolize_keys end
    def to_options!; self end

    # Convert to a Hash with String keys.
    def to_hash
      Hash.new(default).merge!(self)
    end

    protected
      def convert_key(key)
        key.kind_of?(Symbol) ? key.to_s : key
      end

      def convert_value(value)
        if value.is_a? Hash
          value.nested_under_indifferent_access
        elsif value.is_a?(Array)
          value.dup.replace(value.map { |e| convert_value(e) })
        else
          value
        end
      end
  end
end

HashWithIndifferentAccess = ActiveSupport::HashWithIndifferentAccess