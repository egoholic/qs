module Qs
  class ParamsValidator
    class ParamValidator
      MATCHERS = {
        required: {
          matcher: ->(v, required) { !required || !v.nil? }
        },

        type: {
          matcher: -> (v, type) { v.instance_of? type }
        },

        min: {
          matcher: -> (v, min) { v >= min }
        },

        max: {
          matcher: -> (v, max) { v <= max }
        },

        presents_in: {
          matcher: -> (v, list) { list.include? v }
        },

        length: {
          matcher: -> (v, len) { v.length == len }
        },

        min_length: {
          matcher: -> (v, len) { v.length >= len }
        },

        max_length: {
          matcher: -> (v, len) { v.length <= len }
        },

        length_in: {
          matcher: -> (v, lenrange) { lenrange.include? v.length }
        },

        matches: {
          matcher: -> (v, regex) { !!(v =~ regex) }
        }
      }.freeze

      def initialize(param_definition)
        raise ArgumentError, "'param_definition' should be an instance of Hash" unless param_definition.instance_of? Hash

        @definition = param_definition
        @definition[:required] = true unless @definition.has_key?(:required)
      end

      def valid?(value)
        @definition.all? { |mname, limitation| matches?(mname, value, limitation) }
      end

      private

      def matches?(mname, value, limitation)
        matcher = matchers[mname][:matcher]
        matcher.call value, limitation
      end

      def matchers
        MATCHERS
      end
    end
  end
end
