RSpec.describe Qs::Querier do
  let(:name)             { :main }
  let(:domain_name)      { :tasks }
  let(:query_name)       { :find_by_title }
  let(:params_validator) { Qs.params_validator(title: {type: String, length_in: 3..64}) }

  let :executable do
    ->(resources, params) do
      [
        {title: "Task 1", description: "Description for task 1."},
        {title: "Task 2", description: "Description for task 2."}
      ].find { |t| t[:title] == params[:title] }
    end
  end

  let(:query) { Qs.query query_name, params_validator, executable }
  let :domain do
    domain = Qs.domain domain_name
    domain.queries.add query.name, query
    domain
  end

  describe "class" do
    subject { described_class }

    describe ".new" do
      context "when good args" do
        it "returns querier" do
          expect(subject.new name).to be_instance_of described_class
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.new }.to        raise_error(ArgumentError).with_message("wrong number of arguments (0 for 1)")
          expect { subject.new nil }.to    raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
          expect { subject.new "main" }.to raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new name }

    describe "#name" do
      it "returns name" do
        expect(subject.name).to eq name
      end
    end

    describe "#domains" do
      it "returns typed map" do
        expect(subject.domains).to be_instance_of Qs::TypedMap
      end
    end

    describe "#exec" do
      before { subject.domains.add domain.name, domain }

      context "when good args" do
        it "returns result" do
          expect(subject.exec :tasks, :find_by_title, {title: "Task 1"}).to eq({title: "Task 1", description: "Description for task 1."})
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.exec }.to                               raise_error(ArgumentError).with_message("wrong number of arguments (0 for 3)")
          expect { subject.exec nil }.to                           raise_error(ArgumentError).with_message("wrong number of arguments (1 for 3)")
          expect { subject.exec nil, nil }.to                      raise_error(ArgumentError).with_message("wrong number of arguments (2 for 3)")
          expect { subject.exec nil, nil, nil }.to                 raise_error(ArgumentError).with_message("'domain_name' should be an instance of Symbol")
          expect { subject.exec true, nil, nil }.to                raise_error(ArgumentError).with_message("'domain_name' should be an instance of Symbol")
          expect { subject.exec "tasks", nil, nil }.to             raise_error(ArgumentError).with_message("'domain_name' should be an instance of Symbol")
          expect { subject.exec domain_name, nil, nil }.to         raise_error(ArgumentError).with_message("'query_name' should be an instance of Symbol")
          expect { subject.exec domain_name, true, nil }.to        raise_error(ArgumentError).with_message("'query_name' should be an instance of Symbol")
          expect { subject.exec domain_name, {}, nil }.to          raise_error(ArgumentError).with_message("'query_name' should be an instance of Symbol")
          expect { subject.exec domain_name, query_name, nil }.to  raise_error(ArgumentError).with_message("'query_params' should be an instance of Hash")
          expect { subject.exec domain_name, query_name, true }.to raise_error(ArgumentError).with_message("'query_params' should be an instance of Hash")
          expect { subject.exec domain_name, query_name, [] }.to   raise_error(ArgumentError).with_message("'query_params' should be an instance of Hash")
        end
      end
    end
  end
end
