RSpec.describe Qs::ParamsValidator::ParamValidator do
  describe "class" do
    subject { described_class }

    describe ".new" do
      context "when good args" do
        it "returns param validator" do
          expect(subject.new required: false, type: String, length: 64).to be_instance_of described_class
        end
      end

      context "when bad args" do
        it "raises ArgumentError" do
          expect { subject.new }.to           raise_error(ArgumentError).with_message("wrong number of arguments (0 for 1)")
          expect { subject.new nil }.to       raise_error(ArgumentError).with_message("'param_definition' should be an instance of Hash")
          expect { subject.new true }.to      raise_error(ArgumentError).with_message("'param_definition' should be an instance of Hash")
          expect { subject.new [1, 2, 3] }.to raise_error(ArgumentError).with_message("'param_definition' should be an instance of Hash")
        end
      end
    end
  end

  describe "instance" do
    subject { described_class.new param_definition }

    describe "#valid?" do
      context "when parameter is not required" do
        let(:param_definition) { {required: false} }

        context "when parameter is present" do
          it "returns true" do
            expect(subject.valid?(1)).to be true
          end
        end

        context "when parameter isn't present" do
          it "returns true" do
            expect(subject.valid?(nil)).to be true
          end
        end
      end

      context "when parameter is required" do
        let(:param_definition) { {required: true} }

        context "when parameter is present" do
          it "returns true" do
            expect(subject.valid? 1).to be true
          end
        end

        context "when parameter isn't present" do
          it "returns false" do
            expect(subject.valid? nil).to be false
          end
        end
      end

      context "when parameter is required implicitly" do
        let(:param_definition) { {} }

        context "when parameter is present" do
          it "returns true" do
            expect(subject.valid? 1).to be true
          end
        end

        context "when parameter isn't present" do
          it "returns false" do
            expect(subject.valid? nil).to be false
          end
        end
      end

      context "when parameter is strongly typed" do
        let(:param_definition) { {type: Fixnum} }

        context "when correct type" do
          it "returns true" do
            expect(subject.valid? 1).to be true
          end
        end

        context "when incorrect type" do
          it "returns false" do
            expect(subject.valid? nil).to be false
            expect(subject.valid? 1.0).to be false
          end
        end
      end

      context "when parameter has min limit" do
        let(:param_definition) { {type: Fixnum, min: 3} }

        context "when greater than or equal to limit" do
          it "returns true" do
            expect(subject.valid? 5).to be true
            expect(subject.valid? 3).to be true
            expect(subject.valid? 999999999).to be true
          end
        end

        context "when less than limit" do
          it "returns false" do
            expect(subject.valid? 2).to be false
            expect(subject.valid? 0).to be false
            expect(subject.valid? -999999999).to be false
          end
        end
      end

      context "when parameter has max limit" do
        let(:param_definition) { {type: String, max: "f"} }

        context "when less than or equal to limit" do
          it "returns true" do
            expect(subject.valid? "a").to be true
            expect(subject.valid? "ee").to be true
            expect(subject.valid? "f").to be true
          end
        end

        context "when greater then limit" do
          it "returns false" do
            expect(subject.valid? "fa").to be false
            expect(subject.valid? "g").to be false
            expect(subject.valid? "z").to be false
          end
        end
      end

      context "when parameter should be present in" do
        context "when limitation given as an array" do
          let(:param_definition) { {presents_in: [1, 99, 100500]} }

          context "when limitation includes parameter" do
            it "returns true" do
              expect(subject.valid? 1).to be true
              expect(subject.valid? 99).to be true
              expect(subject.valid? 100500).to be true
            end
          end

          context "when limitation doesn't include parameter" do
            it "returns false" do
              expect(subject.valid? 2).to be false
              expect(subject.valid? 100).to be false
              expect(subject.valid? 100499).to be false
            end
          end
        end

        context "when limitation given as a range" do
          let(:param_definition) { {presents_in: 5..7} }

          context "when limitation includes parameter" do
            it "returns true" do
              expect(subject.valid? 5).to be true
              expect(subject.valid? 6).to be true
              expect(subject.valid? 7).to be true
            end
          end

          context "when limitation doesn't include parameter" do
            it "returns false" do
              expect(subject.valid? 4).to be false
              expect(subject.valid? 8).to be false
            end
          end
        end
      end

      context "when parameter should have exact length" do
        let(:param_definition) { {type: String, length: 5} }

        context "when has equal length" do
          it "returns true" do
            expect(subject.valid? "aaaaa").to be true
            expect(subject.valid? "zzzzz").to be true
          end
        end

        context "when has greater or less length" do
          it "returns false" do
            expect(subject.valid? "").to be false
            expect(subject.valid? "a").to be false
            expect(subject.valid? "aa").to be false
            expect(subject.valid? "aaa").to be false
            expect(subject.valid? "aaaa").to be false
            expect(subject.valid? "aaaaaa").to be false
          end
        end
      end

      context "when parameter has min length limitation" do
        let(:param_definition) { {type: String, min_length: 3} }

        context "when parameter has length greater than or equal to limitation" do
          it "returns true" do
            expect(subject.valid? "aaa").to be true
            expect(subject.valid? "aaaa").to be true
            expect(subject.valid? "abcdefgh1234567890").to be true
          end
        end

        context "when parameter has length less than limitation" do
          it "returns false" do
            expect(subject.valid? "aa").to be false
            expect(subject.valid? "a").to be false
            expect(subject.valid? "").to be false
          end
        end
      end

      context "when parameter has max length limitation" do
        let(:param_definition) { {type: Array, max_length: 3} }
        context "when parameter has length less than or equal to limitation" do
          it "returns true" do
            expect(subject.valid? [1, 2, 3]).to be true
            expect(subject.valid? [1, 2]).to be true
            expect(subject.valid? [1]).to be true
            expect(subject.valid? []).to be true
          end
        end

        context "when parameter has length greater than limitation" do
          it "returns false" do
            expect(subject.valid? [1, 2, 3, 4]).to be false
            expect(subject.valid? (0..20).to_a).to be false
          end
        end
      end

      context "when parameter has length inclusion limitation" do
        context "when limitation given as an array" do
          let(:param_definition) { {type: Array, length_in: [0, 3, 5]} }

          context "when parameter length presents in the array" do
            it "returns true" do
              expect(subject.valid? []).to be true
              expect(subject.valid? [1, 2, 3]).to be true
              expect(subject.valid? [1, 2, 3, 4, 5]).to be true
            end
          end

          context "when parameter length does not present in array" do
            it "returns false" do
              expect(subject.valid? [1]).to be false
              expect(subject.valid? [1, 2]).to be false
              expect(subject.valid? [1, 2, 3, 4]).to be false
              expect(subject.valid? [1, 2, 3, 4, 5, 6]).to be false
            end
          end
        end

        context "when limitation given as a range" do
          let(:param_definition) { {type: Array, length_in: (1..3)} }

          context "when parameter length presents in the range" do
            it "returns true" do
              expect(subject.valid? [1]).to be true
              expect(subject.valid? [1, 2]).to be true
              expect(subject.valid? [1, 2, 3]).to be true
            end
          end

          context "when parameter length does not present in range" do
            it "returns false" do
              expect(subject.valid? []).to be false
              expect(subject.valid? [1, 2, 3, 4]).to be false
              expect(subject.valid? [1, 2, 3, 4, 5, 6]).to be false
            end
          end
        end
      end

      context "when parameter has regex limitation" do
        let(:param_definition) { {type: String, matches: /\AJam/} }

        context "when parameter matches regex" do
          it "returns true" do
            expect(subject.valid? "Jam").to be true
            expect(subject.valid? "James Dean").to be true
          end
        end

        context "when parameter doesn't match regex" do
          it "returns false" do
            expect(subject.valid? "").to be false
            expect(subject.valid? " Jam").to be false
            expect(subject.valid? "John Wayne").to be false
          end
        end
      end
    end
  end
end
