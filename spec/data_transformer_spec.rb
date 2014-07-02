require 'data_transformer'
require 'ostruct'
describe DataTransformer do
  let(:t) { subject }
  after  { t.tracing = false }
  let(:cat)    { OpenStruct.new(nya: 'purr') }
  let(:quux)   { OpenStruct.new(boo: 42, yarr: 'something', cat: cat) }
  let(:baz1)   { OpenStruct.new(quux: quux) }
  let(:baz)    { [baz1] }
  let(:bar1)   { OpenStruct.new(baz:  baz) }
  let(:bar)    { [bar1] }
  let(:complex){ [OpenStruct.new(bar: bar)] }

  describe '#all' do
    it 'maps array with #one for each object' do
      expect(DataTransformer).to receive(:one).with(bar1, :rules_go_here)
      DataTransformer.all(bar, :rules_go_here)
    end
  end

  describe '#one' do
    it 'should return hash with method call results' do
      expect( t.one quux, [:boo] )
        .to eq( {boo: 42} )
    end

    it 'should return hash with multiple method calls results' do
      expect( t.one quux, [:boo, :yarr] )
        .to eq( {boo: 42, yarr: 'something'} )
    end

    it 'should return hash with renamed method call results' do
      expect( t.one quux, [:boo, {bark: :yarr}] )
        .to eq( {boo: 42, bark: 'something'} )
    end

    it 'should call method chain' do
      expect( t.one baz1, [{data: [:quux, :boo]}] )
        .to eq( {data: 42} )
    end

    it 'should map method over array' do
      expect( t.one baz, [{data: [[:quux]]}] )
        .to eq( {data: [quux]} )
    end

    it 'should map method chain over array' do
      expect( t.one baz, [{data: [[:quux, :boo]]}] )
        .to eq( {data: [42]} )
    end

    it 'should allow nested mapping and chaining' do
      expect( t.one complex, [
          {data: [
              [:bar,
                [:baz,
                  [:quux, :boo]]]]}])
        .to eq( {data: [[[42]]]} )
    end

    it 'should allow nested mapping and chaining with forking' do
      expect( t.one complex, [
          {data: [
              [:bar,
                [:baz,
                  [:quux, {
                      boo: :boo,
                      nya: [:cat, :nya]
                    }]]],
              :flatten]}])
        .to eq( {data: [{boo: 42, nya: 'purr'}]} )
    end

    it 'should allow inline lambdas as part of pipeline' do
      expect( t.one baz1, [{data: [:quux, :boo, ->(x){x+1}]}] )
        .to eq( {data: 43} )
    end
  end
end
