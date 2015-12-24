module Qs
  class Resource
    attr_reader :name

    def initialize(name, connection_params, executable, options = {})
      raise ArgumentError, "'name' should be an instance of Symbol"            unless name.instance_of?(Symbol)
      raise ArgumentError, "'connection_params' should be an instance of Hash" unless connection_params.instance_of?(Hash)
      raise ArgumentError, "'executable' should be a lambda"                   unless executable.instance_of?(Proc) && executable.lambda?
      raise ArgumentError, "'options' should be an instance of Hash"           unless options.instance_of? Hash

      @name              = name
      @connection_params = connection_params
      @executable        = executable
      @options           = options
    end

    def connection
      @executable.call @connection_params
    end
  end
end
