module Qs
  class Query
    attr_reader :name

    class InvalidParametersError < StandardError
    end

    def initialize(name, params_validator, executable)
      raise ArgumentError, "'name' should be an instance of Symbol"                      unless name.instance_of?(Symbol)
      raise ArgumentError, "'params_validator' should be an instance of ParamsValidator" unless params_validator.instance_of?(ParamsValidator)
      raise ArgumentError, "'executable' should be a lambda"                             unless executable.instance_of?(Proc) && executable.lambda?
      raise ArgumentError, "'executable' should receive 2 arguments"                     unless executable.arity == 2

      @name             = name
      @executable       = executable
      @params_validator = params_validator
    end

    def exec(resources, params)
      raise ArgumentError, "'resources' should be an instance of Typed Map"   unless resources.instance_of? TypedMap
      raise ArgumentError, "'params' should be an instance of of Hash"        unless params.instance_of? Hash
      raise InvalidParametersError, "'params' are invalid"                    unless @params_validator.valid? params

      @executable.call resources, params
    end
  end
end
