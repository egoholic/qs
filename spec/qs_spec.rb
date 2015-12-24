RSpec.describe Qs do
  let(:querier_name)     { :main }
  let(:resource_name)    { :pg }
  let(:query_name)       { :all }
  let(:domain_name)      { :tasks }
  let(:params_validator) { described_class.params_validator({}) }

  describe "class" do
    subject { described_class }

    describe ".querier" do
      it "returns querier" do
        expect(subject.querier querier_name ).to be_instance_of described_class::Querier
      end
    end

    describe ".resource" do
      it "returns resource" do
        r = subject.resource resource_name, {}, ->(connection_params) { }
        expect(r).to be_instance_of described_class::Resource
      end
    end

    describe ".query" do
      it "returns query" do
        q = subject.query query_name, params_validator, ->(resources, params) { }
        expect(q).to be_instance_of described_class::Query
      end
    end

    describe ".domain" do
      it "returns domain" do
        expect(subject.domain domain_name)
      end
    end

    describe ".param_validator" do
      it "returns params validator" do
        expect(subject.params_validator({})).to be_instance_of described_class::ParamsValidator
      end
    end
  end
end
