# DataTransformer

Declarative transformations for objects and object collections

## Installation

Add this line to your application's Gemfile:

    gem 'data_transformer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install data_transformer

## Usage

    DataTransformer.one x, :foo                       # => {foo: x.foo}
    DataTransformer.one x, {foo: :bar}                # => {foo: x.bar}
    DataTransformer.one x, {foo: [:bar]}              # => {foo: x.map(&:bar)}
    DataTransformer.one x, {foo: [:bar :baz]}         # => {foo: x.bar.baz}
    DataTransformer.one x, {foo: [:bar [:baz]]}       # => {foo: x.bar.map(&:baz)}
    DataTransformer.one x, {foo: [:bar [:baz :quux]]} # => {foo: x.bar.map{|y| y.baz.quux}}

See /spec for more examples.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/data_transformer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
