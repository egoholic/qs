module Qs
  class Domain
    attr_reader :name, :queries, :resources

    def initialize(name)
      raise ArgumentError, "'name' should be an instance of Symbol" unless name.instance_of?(Symbol)

      @name      = name
      @queries   = TypedMap.new(ktype: Symbol, vtype: Query)
      @resources = TypedMap.new(ktype: Symbol, vtype: Resource)
    end

    def exec(query_name, params)
      queries[query_name].exec(resources, params)
    end
  end
end
