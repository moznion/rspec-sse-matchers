# frozen_string_literal: true

RSpec.describe RSpec::SSE::Matchers do
  def create_sse_body(events)
    body = ""
    events.each do |event|
      body += "id: #{event[:id]}\n" if event[:id]
      body += "event: #{event[:type]}\n" if event[:type]
      body += "data: #{event[:data]}\n" if event[:data]
      body += "retry: #{event[:retry]}\n" if event[:retry]
      body += "\n"
    end
    body
  end

  def mock_response_with_events(events)
    body = create_sse_body(events)
    MockResponse.new(body:)
  end

  let(:event1) { {type: "message", data: '{"id":1}', id: "1", retry: 1000} }
  let(:event2) { {type: "update", data: '{"id":2}', id: "2", retry: 2000} }
  let(:event3) { {type: "close", data: '{"id":3}', id: "3", retry: 3000} }

  let(:response_with_two_events) { mock_response_with_events([event1, event2]) }
  let(:response_with_three_events) { mock_response_with_events([event1, event2, event3]) }
  let(:response_with_reversed_events) { mock_response_with_events([event2, event1]) }
  let(:empty_response) { mock_response_with_events([]) }

  # For gracefully closed matcher which doesn't use the parser
  let(:gracefully_closed_response) { MockResponse.new(body: "\n\n") }
  let(:non_gracefully_closed_response) { MockResponse.new(body: "data: test\n") }

  # be_sse_gracefully_closed matcher
  describe "be_sse_gracefully_closed" do
    it "matches when the response body ends with newlines" do
      expect(gracefully_closed_response).to be_sse_gracefully_closed
    end

    it "doesn't match when the response body doesn't end with newlines" do
      expect(non_gracefully_closed_response).not_to be_sse_gracefully_closed
    end
  end

  describe "be_sse_successfully_opened" do
    let(:response) { MockResponse.new(body: "data: test\n\n", status:, headers:) }
    let(:status) { 200 }
    let(:headers) { {"content-type" => "text/event-stream", "cache-control" => "no-store"} }

    it "matches when the response satisfies the condition" do
      expect(response).to be_sse_successfully_opened
    end

    context "when the response status code is not 200" do
      let(:status) { 400 }

      it do
        expect(response).not_to be_sse_successfully_opened
      end
    end

    context "when the response header's content-type is wrong" do
      let(:headers) { {"content-type" => "application/json", "cache-control" => "no-store"} }

      it do
        expect(response).not_to be_sse_successfully_opened
      end
    end

    context "when the response header's cache-control is another allowed one" do
      let(:headers) { {"content-type" => "text/event-stream", "cache-control" => "no-cache"} }

      it do
        expect(response).to be_sse_successfully_opened
      end
    end

    context "when the response header's cache-control is wrong" do
      let(:headers) { {"content-type" => "text/event-stream", "cache-control" => "public"} }

      it do
        expect(response).not_to be_sse_successfully_opened
      end
    end
  end

  # Exact order matchers
  describe "be_sse_events" do
    it "matches when events are in the exact order" do
      expect(response_with_two_events).to be_sse_events([event1, event2])
    end

    it "doesn't match when events are in a different order" do
      expect(response_with_two_events).not_to be_sse_events([event2, event1])
    end

    it "doesn't match when there are missing events" do
      expect(response_with_two_events).not_to be_sse_events([event1])
    end

    it "doesn't match when there are extra events" do
      expect(response_with_two_events).not_to be_sse_events([event1, event2, event3])
    end
  end

  describe "be_sse_event_types" do
    it "matches when event types are in the exact order" do
      expect(response_with_two_events).to be_sse_event_types(%w[message update])
    end

    it "doesn't match when event types are in a different order" do
      expect(response_with_two_events).not_to be_sse_event_types(%w[update message])
    end

    it "doesn't match when there are missing event types" do
      expect(response_with_two_events).not_to be_sse_event_types(["message"])
    end

    it "doesn't match when there are extra event types" do
      expect(response_with_two_events).not_to be_sse_event_types(%w[message update close])
    end

    it "accepts either array or individual arguments" do
      expect(response_with_two_events).to be_sse_event_types("message", "update")
    end
  end

  describe "be_sse_event_data" do
    it "matches when event data are in the exact order" do
      expect(response_with_two_events).to be_sse_event_data(%w[{"id":1} {"id":2}])
    end

    it "doesn't match when event data are in a different order" do
      expect(response_with_two_events).not_to be_sse_event_data(%w[{"id":2} {"id":1}])
    end

    it "doesn't match when there are missing event data" do
      expect(response_with_two_events).not_to be_sse_event_data(['{"id":1}'])
    end

    it "doesn't match when there are extra event data" do
      expect(response_with_two_events).not_to be_sse_event_data(%w[{"id":1} {"id":2} {"id":3}])
    end
  end

  describe "be_sse_event_ids" do
    it "matches when event IDs are in the exact order" do
      expect(response_with_two_events).to be_sse_event_ids(%w[1 2])
    end

    it "doesn't match when event IDs are in a different order" do
      expect(response_with_two_events).not_to be_sse_event_ids(%w[2 1])
    end

    it "doesn't match when there are missing event IDs" do
      expect(response_with_two_events).not_to be_sse_event_ids(["1"])
    end

    it "doesn't match when there are extra event IDs" do
      expect(response_with_two_events).not_to be_sse_event_ids(%w[1 2 3])
    end
  end

  describe "be_sse_reconnection_times" do
    it "matches when reconnection times are in the exact order" do
      expect(response_with_two_events).to be_sse_reconnection_times([1000, 2000])
    end

    it "doesn't match when reconnection times are in a different order" do
      expect(response_with_two_events).not_to be_sse_reconnection_times([2000, 1000])
    end

    it "doesn't match when there are missing reconnection times" do
      expect(response_with_two_events).not_to be_sse_reconnection_times([1000])
    end

    it "doesn't match when there are extra reconnection times" do
      expect(response_with_two_events).not_to be_sse_reconnection_times([1000, 2000, 3000])
    end
  end

  # Order-independent matchers
  describe "contain_exactly_events" do
    it "matches when events contain exactly the same events in any order" do
      expect(response_with_two_events).to contain_exactly_sse_events([event1, event2])
      expect(response_with_two_events).to contain_exactly_sse_events([event2, event1])
    end

    it "doesn't match when there are missing events" do
      expect(response_with_two_events).not_to contain_exactly_sse_events([event1])
    end

    it "doesn't match when there are extra events" do
      expect(response_with_two_events).not_to contain_exactly_sse_events([event1, event2, event3])
    end
  end

  describe "contain_exactly_event_types" do
    it "matches when event types contain exactly the same types in any order" do
      expect(response_with_two_events).to contain_exactly_sse_event_types(%w[message update])
      expect(response_with_two_events).to contain_exactly_sse_event_types(%w[update message])
    end

    it "doesn't match when there are missing event types" do
      expect(response_with_two_events).not_to contain_exactly_sse_event_types(["message"])
    end

    it "doesn't match when there are extra event types" do
      expect(response_with_two_events).not_to contain_exactly_sse_event_types(%w[message update close])
    end
  end

  describe "contain_exactly_event_data" do
    it "matches when event data contain exactly the same data in any order" do
      expect(response_with_two_events).to contain_exactly_sse_event_data(%w[{"id":1} {"id":2}])
      expect(response_with_two_events).to contain_exactly_sse_event_data(%w[{"id":2} {"id":1}])
    end

    it "doesn't match when there are missing event data" do
      expect(response_with_two_events).not_to contain_exactly_sse_event_data(['{"id":1}'])
    end

    it "doesn't match when there are extra event data" do
      expect(response_with_two_events).not_to contain_exactly_sse_event_data(%w[{"id":1} {"id":2} {"id":3}])
    end
  end

  describe "contain_exactly_event_ids" do
    it "matches when event IDs contain exactly the same IDs in any order" do
      expect(response_with_two_events).to contain_exactly_sse_event_ids(%w[1 2])
      expect(response_with_two_events).to contain_exactly_sse_event_ids(%w[2 1])
    end

    it "doesn't match when there are missing event IDs" do
      expect(response_with_two_events).not_to contain_exactly_sse_event_ids(["1"])
    end

    it "doesn't match when there are extra event IDs" do
      expect(response_with_two_events).not_to contain_exactly_sse_event_ids(%w[1 2 3])
    end
  end

  describe "contain_exactly_reconnection_times" do
    it "matches when reconnection times contain exactly the same times in any order" do
      expect(response_with_two_events).to contain_exactly_sse_reconnection_times([1000, 2000])
      expect(response_with_two_events).to contain_exactly_sse_reconnection_times([2000, 1000])
    end

    it "doesn't match when there are missing reconnection times" do
      expect(response_with_two_events).not_to contain_exactly_sse_reconnection_times([1000])
    end

    it "doesn't match when there are extra reconnection times" do
      expect(response_with_two_events).not_to contain_exactly_sse_reconnection_times([1000, 2000, 3000])
    end
  end

  # Inclusion matchers
  describe "have_sse_events" do
    it "matches when all expected events are included" do
      expect(response_with_three_events).to have_sse_events([event1, event2])
    end

    it "doesn't match when some expected events are not included" do
      expect(response_with_two_events).not_to have_sse_events([event1, event3])
    end

    it "matches when one expected event is included" do
      expect(response_with_two_events).to have_sse_events([event1])
      expect(response_with_two_events).to have_sse_events([event2])
    end
  end

  describe "have_sse_event_types" do
    it "matches when all expected event types are included" do
      expect(response_with_three_events).to have_sse_event_types(%w[message update])
    end

    it "doesn't match when some expected event types are not included" do
      expect(response_with_two_events).not_to have_sse_event_types(%w[message close])
    end

    it "matches when one expected event type is included" do
      expect(response_with_two_events).to have_sse_event_types(["message"])
      expect(response_with_two_events).to have_sse_event_types(["update"])
    end
  end

  describe "have_sse_event_data" do
    it "matches when all expected event data are included" do
      expect(response_with_three_events).to have_sse_event_data(%w[{"id":1} {"id":2}])
    end

    it "doesn't match when some expected event data are not included" do
      expect(response_with_two_events).not_to have_sse_event_data(%w[{"id":1} {"id":3}])
    end

    it "matches when one expected event data is included" do
      expect(response_with_two_events).to have_sse_event_data(['{"id":1}'])
      expect(response_with_two_events).to have_sse_event_data(['{"id":2}'])
    end
  end

  describe "have_sse_event_ids" do
    it "matches when all expected event IDs are included" do
      expect(response_with_three_events).to have_sse_event_ids(%w[1 2])
    end

    it "doesn't match when some expected event IDs are not included" do
      expect(response_with_two_events).not_to have_sse_event_ids(%w[1 3])
    end

    it "matches when one expected event ID is included" do
      expect(response_with_two_events).to have_sse_event_ids(["1"])
      expect(response_with_two_events).to have_sse_event_ids(["2"])
    end
  end

  describe "have_sse_reconnection_times" do
    it "matches when all expected reconnection times are included" do
      expect(response_with_three_events).to have_sse_reconnection_times([1000, 2000])
    end

    it "doesn't match when some expected reconnection times are not included" do
      expect(response_with_two_events).not_to have_sse_reconnection_times([1000, 3000])
    end

    it "matches when one expected reconnection time is included" do
      expect(response_with_two_events).to have_sse_reconnection_times([1000])
      expect(response_with_two_events).to have_sse_reconnection_times([2000])
    end
  end

  # Edge cases
  describe "edge cases" do
    it "handles empty responses gracefully" do
      expect(empty_response).to be_sse_events([])
      expect(empty_response).to be_sse_event_types([])
      expect(empty_response).to be_sse_event_data([])
      expect(empty_response).to be_sse_event_ids([])
      expect(empty_response).to be_sse_reconnection_times([])
    end
  end

  # JSON parsing option
  describe "json option" do
    let(:json_event1) { {type: "message", data: '{"id":1,"name":"Alice"}', id: "1", retry: 1000} }
    let(:json_event2) { {type: "update", data: '{"id":2,"name":"Bob"}', id: "2", retry: 2000} }
    let(:response_with_json_events) { mock_response_with_events([json_event1, json_event2]) }

    context "be_sse_event_data with :json option" do
      it "parses JSON data before comparison" do
        expect(response_with_json_events).to be_sse_event_data([{"id" => 1, "name" => "Alice"}, {"id" => 2, "name" => "Bob"}], json: true)
      end

      it "keeps original behavior when :json option is not provided" do
        expect(response_with_json_events).to be_sse_event_data(%w[{"id":1,"name":"Alice"} {"id":2,"name":"Bob"}])
      end

      it "handles non-JSON data gracefully with :json option" do
        non_json_event = {type: "message", data: "Not JSON data", id: "1", retry: 1000}
        response = mock_response_with_events([non_json_event])
        expect {
          expect(response).to be_sse_event_data(["Not JSON data"], json: true)
        }.to raise_error(JSON::ParserError)
      end
    end

    context "contain_exactly_event_data with :json option" do
      it "parses JSON data before comparison" do
        expect(response_with_json_events).to contain_exactly_sse_event_data([{"id" => 2, "name" => "Bob"}, {"id" => 1, "name" => "Alice"}], json: true)
      end
    end

    context "have_sse_event_data with :json option" do
      it "parses JSON data before comparison" do
        expect(response_with_json_events).to have_sse_event_data([{"id" => 1, "name" => "Alice"}], json: true)
      end
    end

    context "be_sse_events with :json option" do
      it "parses JSON data in events before comparison" do
        expected_events = [
          {type: "message", data: {"id" => 1, "name" => "Alice"}, id: "1", retry: 1000},
          {type: "update", data: {"id" => 2, "name" => "Bob"}, id: "2", retry: 2000}
        ]
        expect(response_with_json_events).to be_sse_events(expected_events, json: true)
      end
    end

    context "contain_exactly_events with :json option" do
      it "parses JSON data in events before comparison" do
        expected_events = [
          {type: "update", data: {"id" => 2, "name" => "Bob"}, id: "2", retry: 2000},
          {type: "message", data: {"id" => 1, "name" => "Alice"}, id: "1", retry: 1000}
        ]
        expect(response_with_json_events).to contain_exactly_sse_events(expected_events, json: true)
      end
    end

    context "have_sse_events with :json option" do
      it "parses JSON data in events before comparison" do
        expected_events = [
          {type: "message", data: {"id" => 1, "name" => "Alice"}, id: "1", retry: 1000}
        ]
        expect(response_with_json_events).to have_sse_events(expected_events, json: true)
      end
    end
  end
end
