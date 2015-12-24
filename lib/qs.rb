require "qs/version"

module Qs
  require "qs/typed_map"
  require "qs/querier"
  require "qs/resource"
  require "qs/domain"
  require "qs/params_validator"
  require "qs/query"

  class << self
    def querier(*args)
      Querier.new *args
    end

    def resource(*args)
      Resource.new *args
    end

    def domain(*args)
      Domain.new *args
    end

    def query(*args)
      Query.new *args
    end

    def params_validator(*args)
      ParamsValidator.new *args
    end
  end
end
