# frozen_string_literal: true

require "rspec/sse/matchers"

# Mock response class for examples
class MockResponse
  attr_reader :body, :headers

  def initialize(body, headers = {})
    @body = body
    @headers = headers
  end
end

RSpec.describe "SSE Matchers Examples" do
  # Helper method to create a test SSE response with events
  def create_sse_response(events)
    body = ""
    events.each do |event|
      body += "id: #{event[:id]}\n" if event[:id]
      body += "event: #{event[:type]}\n" if event[:type]
      body += "data: #{event[:data]}\n" if event[:data]
      body += "retry: #{event[:retry]}\n" if event[:retry]
      body += "\n"
    end

    # Add proper closing for gracefully closed examples
    body += "\n" if events.any?

    MockResponse.new(body, {"Content-Type" => "text/event-stream"})
  end

  let(:event1) { {type: "message", data: '{"id":1,"message":"Hello"}', id: "1", retry: 1000} }
  let(:event2) { {type: "update", data: '{"id":2,"message":"World"}', id: "2", retry: 2000} }
  let(:event3) { {type: "close", data: '{"id":3,"message":"Goodbye"}', id: "3", retry: 3000} }

  let(:single_event_response) { create_sse_response([event1]) }
  let(:multiple_events_response) { create_sse_response([event1, event2, event3]) }
  let(:empty_response) { create_sse_response([]) }

  describe "Exact Order Matchers" do
    context "be_events" do
      it "passes when events match exactly in order" do
        expect(single_event_response).to be_events([event1])
        expect(multiple_events_response).to be_events([event1, event2, event3])
      end

      it "fails when events are in different order" do
        expect(multiple_events_response).not_to be_events([event3, event2, event1])
      end
    end

    context "be_event_types" do
      it "passes when event types match exactly in order" do
        expect(multiple_events_response).to be_event_types(%w[message update close])
      end

      it "accepts individual arguments" do
        expect(multiple_events_response).to be_event_types("message", "update", "close")
      end
    end

    context "be_event_data" do
      it "passes when event data match exactly in order" do
        expect(multiple_events_response).to be_event_data(%w[{"id":1,"message":"Hello"} {"id":2,"message":"World"} {"id":3,"message":"Goodbye"}])
      end
    end

    context "be_event_ids" do
      it "passes when event IDs match exactly in order" do
        expect(multiple_events_response).to be_event_ids(%w[1 2 3])
      end
    end

    context "be_reconnection_times" do
      it "passes when reconnection times match exactly in order" do
        expect(multiple_events_response).to be_reconnection_times([1000, 2000, 3000])
      end
    end
  end

  describe "Order-Independent Matchers" do
    context "contain_exactly_events" do
      it "passes when events match in any order" do
        expect(multiple_events_response).to contain_exactly_events([event3, event1, event2])
      end
    end

    context "contain_exactly_event_types" do
      it "passes when event types match in any order" do
        expect(multiple_events_response).to contain_exactly_event_types(%w[close message update])
      end
    end

    context "contain_exactly_event_data" do
      it "passes when event data match in any order" do
        expect(multiple_events_response).to contain_exactly_event_data(%w[{"id":3,"message":"Goodbye"} {"id":1,"message":"Hello"} {"id":2,"message":"World"}])
      end
    end

    context "contain_exactly_event_ids" do
      it "passes when event IDs match in any order" do
        expect(multiple_events_response).to contain_exactly_event_ids(%w[3 1 2])
      end
    end

    context "contain_exactly_reconnection_times" do
      it "passes when reconnection times match in any order" do
        expect(multiple_events_response).to contain_exactly_reconnection_times([3000, 1000, 2000])
      end
    end
  end

  describe "Inclusion Matchers" do
    context "have_events" do
      it "passes when all expected events are included" do
        expect(multiple_events_response).to have_events([event1, event2])
      end

      it "passes when a single expected event is included" do
        expect(multiple_events_response).to have_events([event1])
      end
    end

    context "have_event_types" do
      it "passes when all expected event types are included" do
        expect(multiple_events_response).to have_event_types(%w[message update])
      end
    end

    context "have_event_data" do
      it "passes when all expected event data are included" do
        expect(multiple_events_response).to have_event_data(%w[{"id":1,"message":"Hello"} {"id":2,"message":"World"}])
      end
    end

    context "have_event_ids" do
      it "passes when all expected event IDs are included" do
        expect(multiple_events_response).to have_event_ids(%w[1 2])
      end
    end

    context "have_reconnection_times" do
      it "passes when all expected reconnection times are included" do
        expect(multiple_events_response).to have_reconnection_times([1000, 2000])
      end
    end
  end

  describe "Miscellaneous Matchers" do
    context "be_gracefully_closed" do
      it "passes when the response body ends with a double newline" do
        expect(single_event_response).to be_gracefully_closed
        expect(multiple_events_response).to be_gracefully_closed
      end

      it "fails when the response body doesn't end with a double newline" do
        incomplete_response = MockResponse.new("event: message\ndata: test\n")
        expect(incomplete_response).not_to be_gracefully_closed
      end
    end
  end

  describe "Edge Cases" do
    context "empty responses" do
      it "works with empty event collections" do
        expect(empty_response).to be_events([])
        expect(empty_response).to be_event_types([])
        expect(empty_response).to be_event_data([])
        expect(empty_response).to be_event_ids([])
        expect(empty_response).to be_reconnection_times([])
      end
    end
  end
end
