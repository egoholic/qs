module Qs
  class ParamsValidator
    require "qs/params_validator/param_validator"

    def initialize(param_defs)
      raise ArgumentError, "'param_defs' should be an instance of Hash" unless param_defs.instance_of?(Hash)

      @validators = TypedMap.new ktype: Symbol, vtype: ParamValidator

      param_defs.each do |pname, pdef|
        validators.add pname, ParamValidator.new(pdef)
      end
    end

    def valid?(params)
      raise ArgumentError, "'params' should be an instance of Hash" unless params.instance_of?(Hash)

      vkeys = validators.keys
      pkeys = params.keys

      return false unless ((vkeys - pkeys) | (pkeys - vkeys)).empty?

      params.all? { |param_name, value| validators[param_name].valid? value }
    end

    private

    attr_reader :validators
  end
end
