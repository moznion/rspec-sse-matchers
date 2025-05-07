# frozen_string_literal: true

class TestMatcher < RSpec::SSE::Matchers::BaseMatcher
  def match_condition
    extract_actual == @expected
  end

  def description
    "match exactly #{@expected.inspect}"
  end

  def extract_actual
    @extracted_values || []
  end

  attr_writer :extracted_values
end

RSpec.describe RSpec::SSE::Matchers::BaseMatcher do
  let(:test_expected) { [1, 2, 3] }

  subject(:matcher) { TestMatcher.new(test_expected) }

  let(:response_body) { "event: message\ndata: test\nid: 1\n\n" }
  let(:response) { MockResponse.new(response_body) }
  let(:parsed_events) { [{type: "message", data: "test", id: "1", retry: nil}] }

  before do
    allow(RSpec::SSE::Matchers::SseParser).to receive(:parse).with(response_body).and_return(parsed_events)
    matcher.extracted_values = test_expected
  end

  describe "#matches?" do
    it "returns true when match_condition is true" do
      expect(matcher.matches?(response)).to be true
    end

    it "returns false when match_condition is false" do
      matcher.extracted_values = [4, 5, 6]
      expect(matcher.matches?(response)).to be false
    end

    it "sets the actual value and parses events" do
      matcher.matches?(response)
      expect(matcher.instance_variable_get(:@actual)).to eq(response)
      expect(matcher.instance_variable_get(:@parsed_events)).to eq(parsed_events)
    end
  end

  describe "#failure_message" do
    it "returns a proper failure message" do
      matcher.matches?(response)
      expect(matcher.failure_message).to eq("Expected response with events #{test_expected.inspect} to match exactly #{test_expected.inspect}")
    end
  end

  describe "#failure_message_when_negated" do
    it "returns a proper negated failure message" do
      matcher.matches?(response)
      expect(matcher.failure_message_when_negated).to eq("Expected response with events #{test_expected.inspect} not to match exactly #{test_expected.inspect}")
    end
  end

  describe "#description_for" do
    it "handles response objects" do
      matcher.matches?(response)
      result = matcher.send(:description_for, response)
      expect(result).to eq("response with events #{test_expected.inspect}")
    end

    it "handles non-response objects" do
      result = matcher.send(:description_for, "test")
      expect(result).to eq('"test"')
    end
  end
end

RSpec.describe RSpec::SSE::Matchers::ExactMatcher do
  subject(:matcher) { described_class.new([1, 2, 3]) }

  describe "#match_condition" do
    it "returns true when actual and expected are equal" do
      allow(matcher).to receive(:extract_actual).and_return([1, 2, 3])
      expect(matcher.send(:match_condition)).to be true
    end

    it "returns false when actual and expected are not equal" do
      allow(matcher).to receive(:extract_actual).and_return([3, 2, 1])
      expect(matcher.send(:match_condition)).to be false
    end
  end

  describe "#description" do
    it "provides a descriptive message" do
      expect(matcher.send(:description)).to eq("exactly match [1, 2, 3]")
    end
  end
end

RSpec.describe RSpec::SSE::Matchers::ContainExactlyMatcher do
  subject(:matcher) { described_class.new([1, 2, 3]) }

  describe "#match_condition" do
    it "returns true when actual and expected have same elements regardless of order" do
      allow(matcher).to receive(:extract_actual).and_return([3, 1, 2])
      expect(matcher.send(:match_condition)).to be true
    end

    it "returns false when actual and expected have different elements" do
      allow(matcher).to receive(:extract_actual).and_return([1, 2, 4])
      expect(matcher.send(:match_condition)).to be false
    end
  end

  describe "#description" do
    it "provides a descriptive message" do
      expect(matcher.send(:description)).to eq("contain exactly [1, 2, 3] in any order")
    end
  end
end

RSpec.describe RSpec::SSE::Matchers::IncludeMatcher do
  subject(:matcher) { described_class.new([1, 2]) }

  describe "#match_condition" do
    it "returns true when actual includes all expected elements" do
      allow(matcher).to receive(:extract_actual).and_return([1, 2, 3])
      expect(matcher.send(:match_condition)).to be true
    end

    it "returns false when actual doesn't include all expected elements" do
      allow(matcher).to receive(:extract_actual).and_return([1, 3])
      expect(matcher.send(:match_condition)).to be false
    end
  end

  describe "#description" do
    it "provides a descriptive message" do
      expect(matcher.send(:description)).to eq("include [1, 2]")
    end
  end
end
