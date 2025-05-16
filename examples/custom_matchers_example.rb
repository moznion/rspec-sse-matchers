# frozen_string_literal: true

require "rspec"
require "rspec/sse/matchers"
require "json"

# Mock response for demonstration
class MockResponse
  attr_reader :body, :headers, :status
  def initialize(body:, status: 200, headers: {"content-type" => "text/event-stream", "cache-control" => "no-store"})
    @body = body
    @status = status
    @headers = headers
  end
end

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

RSpec.describe "SSE with custom matchers" do
  include RSpec::Matchers

  describe "example from the original request" do
    let(:event1) { {type: "in_progress", data: '{"event":"in_progress","data":{}}', id: "", retry: 250} }
    let(:event2) { {type: "finished", data: '{"event":"finished","data":{"object_id":"special_prefix_12345","results":[1,2,3]}}', id: "", retry: 250} }
    let(:response) { MockResponse.new(body: create_sse_body([event1, event2])) }

    it "matches SSE events with custom matchers" do
      expect(response).to be_sse_events([
        {type: "in_progress", data: {"event" => "in_progress", "data" => {}}, id: "", retry: 250},
        hash_including(
          type: "finished",
          data: hash_including(
            "event" => "finished",
            "data" => hash_including(
              "object_id" => a_kind_of(String),  # or a_string_starting_with("special_prefix_")
              "results" => be_an(Array)
            )
          ),
          id: "",
          retry: 250
        )
      ], json: true)
    end
  end

  describe "other examples" do
    context "partial matching with hash_including" do
      let(:events) {
        [
          {type: "user_update", data: '{"user_id":123,"name":"John","email":"john@example.com","status":"active"}', id: "1", retry: 1000}
        ]
      }
      let(:response) { MockResponse.new(body: create_sse_body(events)) }

      it "matches only specific fields" do
        expect(response).to be_sse_events([
          hash_including(
            type: "user_update",
            data: hash_including(
              "user_id" => 123,
              "status" => "active"
              # Other fields are ignored
            )
          )
        ], json: true)
      end
    end

    context "type checking with RSpec matchers" do
      let(:events) {
        [
          {type: "data_point", data: '{"value":42.5,"timestamp":"2023-01-01T10:00:00Z","tags":["sensor","temperature"]}', id: "2", retry: 500}
        ]
      }
      let(:response) { MockResponse.new(body: create_sse_body(events)) }

      it "validates data types" do
        expect(response).to be_sse_events([
          hash_including(
            type: "data_point",
            data: hash_including(
              "value" => a_kind_of(Numeric),
              "timestamp" => match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/),
              "tags" => include("sensor")
            )
          )
        ], json: true)
      end
    end

    context "array matching" do
      let(:events) {
        [
          {type: "batch", data: '{"items":[{"id":1,"status":"ok"},{"id":2,"status":"error"},{"id":3,"status":"ok"}]}', id: "3", retry: 1000}
        ]
      }
      let(:response) { MockResponse.new(body: create_sse_body(events)) }

      it "matches arrays with custom expectations" do
        expect(response).to be_sse_events([
          hash_including(
            type: "batch",
            data: hash_including(
              "items" => include(
                hash_including("id" => 2, "status" => "error")
              )
            )
          )
        ], json: true)
      end

      it "matches array properties" do
        expect(response).to be_sse_events([
          hash_including(
            type: "batch",
            data: hash_including(
              "items" => have_attributes(size: 3)
            )
          )
        ], json: true)
      end
    end
  end
end
