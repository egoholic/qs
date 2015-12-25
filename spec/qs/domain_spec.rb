RSpec.describe Qs::Domain do
  let(:domain_name) { :tasks }
  let :query do
    Qs.query :all, Qs.params_validator({}), ->(r, p) do
      [{title: "Task", description: "Task description."}]
    end
  end

  describe "class" do
    subject { described_class }

    describe ".new" do
      context "when good args" do
        it "returns domain" do
          expect(subject.new domain_name).to be_instance_of described_class
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.new }.to          raise_error(ArgumentError).with_message("wrong number of arguments (0 for 1)")
          expect { subject.new nil }.to      raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
          expect { subject.new "domain" }.to raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new domain_name }

    describe "#name" do
      it "returns name" do
        expect(subject.name).to eq domain_name
      end
    end

    describe "#queries" do
      it "returns typed map" do
        expect(subject.queries).to be_instance_of TypedMap
      end
    end

    describe "#resources" do
      it "returns typed map" do
        expect(subject.resources).to be_instance_of TypedMap
      end
    end

    describe "#exec" do
      context "when good args" do
        context "when query exists" do
          before { subject.queries.add(query.name, query) }

          it "executes query" do
            expect(subject.exec :all, {}).to eq [{title: "Task", description: "Task description."}]
          end
        end

        context "when query doesn't exist" do
          it "raises ArgumentError" do
            expect { subject.exec :find_by_title, {} }.to raise_error(ArgumentError).with_message("key 'find_by_title' not exists")
          end
        end
      end

      context "when bad args" do
        before { subject.queries.add(query.name, query) }

        it "raises ArgumentError" do
          expect { subject.exec }.to            raise_error(ArgumentError).with_message("wrong number of arguments (0 for 2)")
          expect { subject.exec nil }.to        raise_error(ArgumentError).with_message("wrong number of arguments (1 for 2)")
          expect { subject.exec nil, nil }.to   raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject.exec "all", nil }.to raise_error(ArgumentError).with_message("'k' should be an instance of Symbol")
          expect { subject.exec :all, nil }.to  raise_error(ArgumentError).with_message("'params' should be an instance of of Hash")
          expect { subject.exec :all, [] }.to   raise_error(ArgumentError).with_message("'params' should be an instance of of Hash")
        end
      end
    end
  end
end
