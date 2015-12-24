RSpec.describe Qs::TypedMap do
  describe "class" do
    subject { described_class }

    describe ".new" do
      context "when with good args" do
        it "returns typed map" do
          expect(subject.new ktype: Symbol, vtype: Symbol).to be_instance_of described_class
          expect(subject.new ktype: Bignum, vtype: String).to be_instance_of described_class
          expect(subject.new ktype: Hash, vtype: Array).to    be_instance_of described_class
        end
      end

      context "when with bad args" do
        it "raises ArgumentError" do
          expect { subject.new }.to                                raise_error(ArgumentError).with_message("missing keywords: ktype, vtype")
          expect { subject.new ktype: nil }.to                     raise_error(ArgumentError).with_message("missing keyword: vtype")
          expect { subject.new vtype: nil }.to                     raise_error(ArgumentError).with_message("missing keyword: ktype")
          expect { subject.new ktype: Symbol }.to                  raise_error(ArgumentError).with_message("missing keyword: vtype")
          expect { subject.new vtype: Symbol }.to                  raise_error(ArgumentError).with_message("missing keyword: ktype")
          expect { subject.new ktype: Symbol, vtype: nil }.to      raise_error(ArgumentError).with_message("'vtype' should be an instance of Class")
          expect { subject.new ktype: nil, vtype: Symbol }.to      raise_error(ArgumentError).with_message("'ktype' should be an instance of Class")
          expect { subject.new ktype: Symbol, vtype: nil }.to      raise_error(ArgumentError).with_message("'vtype' should be an instance of Class")
          expect { subject.new ktype: true, vtype: Symbol }.to     raise_error(ArgumentError).with_message("'ktype' should be an instance of Class")
          expect { subject.new ktype: Math, vtype: Enumerable }.to raise_error(ArgumentError).with_message("'ktype' should be an instance of Class")
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new ktype: Symbol, vtype: String }

    describe "#[]" do
      context "when good args" do
        context "when element by given key exists" do
          before { subject.add :key, "value" }

          it "returns the coresponding value" do
            expect(subject[:key]).to eq "value"
          end
        end

        context "when element by given key doesn't exist" do
          it "raises ArgumentError" do
            expect { subject[:bad_key] }.to raise_error(ArgumentError).with_message("key 'bad_key' not exists")
          end
        end
      end

      context "when bad args" do
        before { subject.add :key, "value" }

        it "returns ArgumentError" do
          expect { subject[] }.to      raise_error(ArgumentError).with_message("wrong number of arguments (0 for 1)")
          expect { subject[nil] }.to   raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject[true] }.to  raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject["key"] }.to raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
        end
      end
    end

    describe "#keys" do
      context "when empty" do
        it "returns an empty array" do
          expect(subject.keys).to eq []
        end
      end

      context "when has one key-value pair" do
        before { subject.add :key1, "value" }

        it "returns an array with key" do
          expect(subject.keys).to eq [:key1]
        end
      end

      context "when has many key-value pairs" do
        before do
          subject.add :key1, "value"
          subject.add :key2, "value"
        end

        it "returns an array with key" do
          expect(subject.keys).to eq [:key1, :key2]
        end
      end
    end

    describe "#add" do
      context "when good args" do
        context "when new key" do
          it "adds new key-value pair" do
            expect { subject.add :key, "value" }.to change { subject.has? :key }.from(false).to(true)
            expect(subject[:key]).to eq "value"
          end
        end

        context "when key already exists" do
          before { subject.add :key, "value" }

          it "raises ArgumentError" do
            expect { subject.add :key, "value" }.to raise_error(ArgumentError).with_message("key 'key' already exists")
          end
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.add }.to                raise_error(ArgumentError).with_message("wrong number of arguments (0 for 2)")
          expect { subject.add :key }.to           raise_error(ArgumentError).with_message("wrong number of arguments (1 for 2)")
          expect { subject.add nil, nil }.to       raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject.add nil, "value" }.to   raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject.add "key", "value" }.to raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject.add :key, nil }.to      raise_error(ArgumentError).with_message("'v' should be an instance of String")
          expect { subject.add :key, :value}.to    raise_error(ArgumentError).with_message("'v' should be an instance of String")
        end
      end
    end

    describe "#has?" do
      context "when good args" do
        context "when key exists" do
          before { subject.add :key, "value" }

          it "returns true" do
            expect(subject.has? :key).to be true
          end
        end

        context "when key doesn't exist" do
          it "returns false" do
            expect(subject.has? :key).to be false
          end
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.has? }.to       raise_error(ArgumentError).with_message("wrong number of arguments (0 for 1)")
          expect { subject.has? nil }.to   raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject.has? "key" }.to raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
        end
      end
    end
  end
end
