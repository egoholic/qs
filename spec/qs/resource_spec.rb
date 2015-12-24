RSpec.describe Qs::Resource do
  class Connection
    def initialize(_)
    end
  end

  let(:connection_params) { {user: "postgres", host: "localhost"} }
  let(:executable)        { ->(connection_params) { Connection.new(connection_params) } }

  describe "class" do
    subject { described_class }

    describe ".new" do
      context "when good args" do
        it "returns resource" do
          expect(subject.new :pg, connection_params, executable).to     be_instance_of described_class
          expect(subject.new :pg, connection_params, executable, {}).to be_instance_of described_class
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.new }.to                                         raise_error(ArgumentError).with_message("wrong number of arguments (0 for 3..4)")
          expect { subject.new :pg }.to                                     raise_error(ArgumentError).with_message("wrong number of arguments (1 for 3..4)")
          expect { subject.new :pg, connection_params }.to                  raise_error(ArgumentError).with_message("wrong number of arguments (2 for 3..4)")
          expect { subject.new nil, connection_params, executable }.to      raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
          expect { subject.new "pg", connection_params, executable }.to     raise_error(ArgumentError).with_message("'name' should be an instance of Symbol")
          expect { subject.new :pg, nil, executable }.to                    raise_error(ArgumentError).with_message("'connection_params' should be an instance of Hash")
          expect { subject.new :pg, [], executable }.to                     raise_error(ArgumentError).with_message("'connection_params' should be an instance of Hash")
          expect { subject.new :pg, connection_params, nil }.to             raise_error(ArgumentError).with_message("'executable' should be a lambda")
          expect { subject.new :pg, connection_params, "executable" }.to    raise_error(ArgumentError).with_message("'executable' should be a lambda")
          expect { subject.new :pg, connection_params, Proc.new {} }.to     raise_error(ArgumentError).with_message("'executable' should be a lambda")
          expect { subject.new :pg, connection_params, executable, nil }.to raise_error(ArgumentError).with_message("'options' should be an instance of Hash")
          expect { subject.new :pg, connection_params, executable, [] }.to  raise_error(ArgumentError).with_message("'options' should be an instance of Hash")
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new :pg, connection_params, executable }

    describe "#name" do
      it "returns name" do
        expect(subject.name).to eq :pg
      end
    end

    describe "#connection" do
      it "returns connection" do
        expect(subject.connection).to be_instance_of Connection
      end
    end
  end
end
