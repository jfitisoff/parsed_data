require 'rspec'
require 'pry'
require 'parsed_data'
require 'active_support/all'

describe 'parsed data' do
  let!(:hsh) do
    {
      a: [1, 2, {b: [3, {c: 4}], c: 5}],
      d: 6,
      e: {
        c: 7,
        f: 8,
        g: {h: 9, i: 10}
      },
      c: 11
    }
  end

  context "#to_data" do
    it "parses an XML string" do
      expect(hsh.to_xml.to_data).to be_a ParsedData
    end

    it "parses a JSON string" do
      expect([hsh].to_json.to_data).to be_a ParsedData
    end

    it "parses a Hash" do
      expect(hsh.to_data).to be_a ParsedData
    end

    it "parses an Array" do
      expect([hsh].to_data).to be_a ParsedData
    end
  end

  context ".read" do
    expect(ParsedData.read('./data/xml.xml')).to be_present
  end

  context "getting data" do
    it "doesn't dig down into the data structure if there's a higher level match" do
      expect(hsh.to_data.c).to eq(11)
    end

    it "digs into the data structure until it finds a match" do
      expect(hsh.to_data.d).to eq(6)
    end

    it "supports chaining data methods" do
      expect(hsh.to_data.e.i).to eq(10)
    end

    it "finds a matching key in an Array" do
      expect(hsh.to_data.b.c).to eq(4)
    end

    it "returns nil when no match is found for a key" do
      expect(hsh.to_data.fff).to be_nil
    end
  end

  context "setting data" do
    let!(:data) { hsh.to_data }

    it "preferentially sets the top-level value before digging" do
      data.c = 777
      expect(data.c).to eq(777)
    end

    it "digs into the structure to find a matching key to set" do
      data.d = 999
      expect(data.d).to eq(999)
    end

    it "sets a new value at the entry point if it can't recursively find a matching key" do
      data.foo = 1266
      expect(data['foo']).to eq(1266)
    end
  end
end
