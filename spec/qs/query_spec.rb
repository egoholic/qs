RSpec.describe Qs::Query do
  let(:name)             { :find_by_title }
  let(:params_validator) { Qs.params_validator(title: {type: String, length_in: 3..64}) }
  let(:resource)         { Qs.resource :pg }
  let(:resources)        { TypedMap.new(ktype: Symbol, vtype: Qs::Resource) }

  let :executable do
    ->(resources, params) do
      [
        {title: "Task 1", description: "Description for task 1."},
        {title: "Task 2", description: "Description for task 2."}
      ].find { |t| t[:title] == params[:title] }
    end
  end

  describe "class" do
    subject { described_class }

    describe ".new" do
      context "when good args" do
        it "returns query" do
          expect(subject.new name, params_validator, executable).to be_instance_of described_class
        end
      end 

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.new }.to                                               raise_error(ArgumentError).with_message("wrong number of arguments (0 for 3)")
          expect { subject.new nil }.to                                           raise_error(ArgumentError).with_message("wrong number of arguments (1 for 3)")
          expect { subject.new nil, nil }.to                                      raise_error(ArgumentError).with_message("wrong number of arguments (2 for 3)")
          expect { subject.new nil, nil, nil }.to                                 raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
          expect { subject.new "find_by_title", nil, nil }.to                     raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
          expect { subject.new :find_by_title, nil, nil }.to                      raise_error(ArgumentError).with_message("'params_validator' should be an instance of ParamsValidator")
          expect { subject.new :find_by_title, true, nil }.to                     raise_error(ArgumentError).with_message("'params_validator' should be an instance of ParamsValidator")
          expect { subject.new :find_by_title, {}, nil }.to                       raise_error(ArgumentError).with_message("'params_validator' should be an instance of ParamsValidator")
          expect { subject.new :find_by_title, params_validator, nil }.to         raise_error(ArgumentError).with_message("'executable' should be a lambda")
          expect { subject.new :find_by_title, params_validator, true }.to        raise_error(ArgumentError).with_message("'executable' should be a lambda")
          expect { subject.new :find_by_title, params_validator, Proc.new {} }.to raise_error(ArgumentError).with_message("'executable' should be a lambda")
          expect { subject.new :find_by_title, params_validator, ->() {} }.to     raise_error(ArgumentError).with_message("'executable' should receive 2 arguments")
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new name, params_validator, executable }

    describe "#name" do
      it "returns name" do
        expect(subject.name).to eq name
      end
    end

    describe "#exec" do
      context "when good args" do
        context "when valid params" do
          it "returns query result" do
            expect(subject.exec resources, title: "Task 1").to eq({title: "Task 1", description: "Description for task 1."})
            expect(subject.exec resources, title: "Task 2").to eq({title: "Task 2", description: "Description for task 2."})
          end
        end

        context "when invalid params" do
          it "raises InvalidParametersError" do
            expect { subject.exec(resources, bad: "Task 1") }.to raise_error(Qs::Query::InvalidParametersError).with_message("'params' are invalid")
          end
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.exec }.to                 raise_error(ArgumentError).with_message("wrong number of arguments (0 for 2)")
          expect { subject.exec nil }.to             raise_error(ArgumentError).with_message("wrong number of arguments (1 for 2)")
          expect { subject.exec nil, nil }.to        raise_error(ArgumentError).with_message("'resources' should be an instance of Typed Map")
          expect { subject.exec resources, nil }.to  raise_error(ArgumentError).with_message("'params' should be an instance of of Hash")
          expect { subject.exec resources, true }.to raise_error(ArgumentError).with_message("'params' should be an instance of of Hash")
          expect { subject.exec resources, [] }.to   raise_error(ArgumentError).with_message("'params' should be an instance of of Hash")
          expect { subject.exec nil, {} }.to         raise_error(ArgumentError).with_message("'resources' should be an instance of Typed Map")
          expect { subject.exec true, {} }.to        raise_error(ArgumentError).with_message("'resources' should be an instance of Typed Map")
          expect { subject.exec({}, {}) }.to         raise_error(ArgumentError).with_message("'resources' should be an instance of Typed Map")
        end
      end
    end
  end
end
