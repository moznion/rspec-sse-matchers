# frozen_string_literal: true

RSpec.describe RSpec::SSE::Matchers::SseParser do
  describe ".parse" do
    it "parses valid SSE events" do
      body = "event: message\ndata: {\"hello\":\"world\"}\nid: 1\nretry: 1000\n\n" \
             "event: update\ndata: {\"status\":\"ok\"}\nid: 2\nretry: 2000\n\n"

      events = described_class.parse(body)

      expect(events.size).to eq(2)
      expect(events[0][:type]).to eq("message")
      expect(events[0][:data]).to eq('{"hello":"world"}')
      expect(events[0][:id]).to eq("1")
      expect(events[0][:retry]).to eq(1000)

      expect(events[1][:type]).to eq("update")
      expect(events[1][:data]).to eq('{"status":"ok"}')
      expect(events[1][:id]).to eq("2")
      expect(events[1][:retry]).to eq(2000)
    end

    it "handles events with missing fields" do
      body = "data: hello\n\n" \
             "event: message\ndata: world\n\n" \
             "id: 123\n\n"

      events = described_class.parse(body)

      expect(events.size).to eq(2)
      expect(events[0][:type]).to eq("")
      expect(events[0][:data]).to eq("hello")
      expect(events[0][:id]).to eq("")
      expect(events[0][:retry]).to be_nil

      expect(events[1][:type]).to eq("message")
      expect(events[1][:data]).to eq("world")
      expect(events[1][:id]).to eq("")
      expect(events[1][:retry]).to be_nil
    end

    it "handles empty bodies" do
      events = described_class.parse("")
      expect(events).to be_empty
    end

    it "parses multiline data" do
      body = "event: message\ndata: line1\ndata: line2\ndata: line3\nid: 1\n\n"

      events = described_class.parse(body)

      expect(events.size).to eq(1)
      expect(events[0][:type]).to eq("message")
      expect(events[0][:data]).to eq("line1\nline2\nline3")
      expect(events[0][:id]).to eq("1")
    end
  end
end
