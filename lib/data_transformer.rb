require "data_transformer/version"

module DataTransformer
  class <<self
    attr_accessor :tracing # enable debug tracing

    # Transform Object to Hash according to rules.
    # Rules is an array of elements of following type
    # :foo                       => {foo: x.foo}
    # {foo: :bar}                => {foo: x.bar}
    # {foo: [:bar]}              => {foo: x.map(&:bar)}
    # {foo: [:bar :baz]}         => {foo: x.bar.baz}
    # {foo: [:bar [:baz]]}       => {foo: x.bar.map(&:baz)}
    # {foo: [:bar [:baz :quux]]} => {foo: x.bar.map{|y| y.baz.quux}}
    def one(obj, rules)
      rules.reduce({}) do |results,rule|
        case rule
        when Symbol
          results.merge(rule => apply_rule(obj, rule))
        when Hash
          ((key, value),) = rule.to_a
          results.merge(key => apply_rule(obj, value))
        else
          raise ArgumentError,
            'Only Symbol and Hash (with Symbols or Arrays) are supported as toplevel rules.'
        end
      end
    end

    # Transforms collection of objects according to rules. See rule
    # examples in docs for DataTransformer#one
    def all(collection, rules)
      collection.map{|x| one(x, rules)}
    end

    def apply_rule(obj, rule)
      apply_rules obj, Array(rule)
    end

    def apply_rules(object, rules)
      rules.reduce(object) do |obj, rule|
        p [obj, rule] if tracing
        case rule
        when Array
          obj.map{|x| apply_rules(x, rule)}
        when Symbol
          obj.send(rule)
        when Proc
          rule.(obj)
        when Hash
          rule.reduce({}) do |result, (k,v)|
            result.merge({k => apply_rule(obj, v)})
          end
        else
          raise ArgumentError, 'Only Symbol, Proc and Array or Hash of above are supported.'
        end
      end
    end
  end
end
