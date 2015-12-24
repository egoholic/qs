RSpec.describe Qs::ParamsValidator do
  let :param_defs do
    {
      title: {
        type: String
      },

      published_after: {
        type: Time
      }
    }
  end

  describe "class" do
    subject { described_class }

    describe ".new" do
      context "when good args" do
        it "returns params validator" do
          expect(subject.new param_defs).to be_instance_of described_class
          expect(subject.new({})).to be_instance_of described_class
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.new }.to      raise_error(ArgumentError).with_message("wrong number of arguments (0 for 1)")
          expect { subject.new nil }.to  raise_error(ArgumentError).with_message("'param_defs' should be an instance of Hash")
          expect { subject.new true }.to raise_error(ArgumentError).with_message("'param_defs' should be an instance of Hash")
          expect { subject.new [] }.to   raise_error(ArgumentError).with_message("'param_defs' should be an instance of Hash")
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new param_defs }

    describe "#valid?" do
      context "when good args" do
        context "when valid params" do
          it "returns true" do
            expect(subject.valid? title: "Task 1", published_after: Time.now).to be true
          end
        end

        context "when invalid params" do
          it "returns false" do
            expect(subject.valid? title: nil, published_after: Time.now).to     be false
            expect(subject.valid? title: 1, published_after: Time.now).to       be false
            expect(subject.valid? title: :task_1, published_after: Time.now).to be false
            expect(subject.valid? title: "Task 1").to                           be false
            expect(subject.valid? title: "Task 1", published_after: nil).to     be false
            expect(subject.valid? title: "Task 1", published_after: true).to    be false
            expect(subject.valid? title: "Task 1", published_after: {}).to      be false
            expect(subject.valid? title: "Task 1", published_after: Time.now, published_before: Time.now).to be false
          end
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.valid? }.to           raise_error(ArgumentError).with_message("wrong number of arguments (0 for 1)")
          expect { subject.valid? nil }.to       raise_error(ArgumentError).with_message("'params' should be an instance of Hash")
          expect { subject.valid? true }.to      raise_error(ArgumentError).with_message("'params' should be an instance of Hash")
          expect { subject.valid? [1, 2, 3] }.to raise_error(ArgumentError).with_message("'params' should be an instance of Hash")
        end
      end
    end
  end
end
