module Qs
  class Querier
    require "typed_map"

    attr_reader :name, :domains

    def initialize(name)
      raise ArgumentError, "'name' should be an instance of Symbol" unless name.instance_of?(Symbol)

      @name    = name
      @domains = TypedMap.new ktype: Symbol, vtype: Domain
    end

    def exec(domain_name, query_name, query_params)
      raise ArgumentError, "'domain_name' should be an instance of Symbol" unless domain_name.instance_of? Symbol
      raise ArgumentError, "'query_name' should be an instance of Symbol"  unless query_name.instance_of? Symbol
      raise ArgumentError, "'query_params' should be an instance of Hash"  unless query_params.instance_of? Hash

      domains[domain_name].exec(query_name, query_params)
    end
  end
end
