# frozen_string_literal: true

require_relative "matchers/version"
require "event_stream_parser"

# @rbs!
#   type ssePayload = {type: String?, data: String, id: String?, retry: Integer}

module RSpec
  module Matchers
    # Matches if the response body ends with "\n\n" (SSE graceful close)
    # @rbs return: RSpec::SSE::Matchers::BeGracefullyClosed
    def be_gracefully_closed
      RSpec::SSE::Matchers::BeGracefullyClosed.new
    end

    # Matches if the response indicates successfully SSE connection opened
    #
    # @rbs return: RSpec::SSE::Matchers::BeSuccessfullyOpened
    def be_successfully_opened
      RSpec::SSE::Matchers::BeSuccessfullyOpened.new
    end

    # Matches if the response's events match the expected events in order
    #
    # @rbs *events: ssePayload | Array[ssePayload]
    # @rbs return: RSpec::SSE::Matchers::BeEvents
    def be_events(*events)
      RSpec::SSE::Matchers::BeEvents.new(events.flatten)
    end

    # Matches if the response's event types match the expected types in order
    #
    # @rbs *types: String | Array[String]
    # @rbs return: RSpec::SSE::Matchers::BeEventTypes
    def be_event_types(*types)
      RSpec::SSE::Matchers::BeEventTypes.new(types.flatten)
    end

    # Matches if the response's event data match the expected data in order
    #
    # @rbs *data: String | Array[String]
    # @rbs return: RSpec::SSE::Matchers::BeEventData
    def be_event_data(*data)
      RSpec::SSE::Matchers::BeEventData.new(data.flatten)
    end

    # Matches if the response's event IDs match the expected IDs in order
    #
    # @rbs *ids: String
    # @rbs return: RSpec::SSE::Matchers::BeEventIds
    def be_event_ids(*ids)
      RSpec::SSE::Matchers::BeEventIds.new(ids.flatten)
    end

    # Matches if the response's reconnection times match the expected times in order
    #
    # @rbs *times: Integer | Array[Integer]
    # @rbs return: RSpec::SSE::Matchers::BeReconnectionTimes
    def be_reconnection_times(*times)
      RSpec::SSE::Matchers::BeReconnectionTimes.new(times.flatten)
    end

    # Matches if the response's events contain the expected events regardless of order
    #
    # @rbs *events: ssePayload | Array[ssePayload]
    # @rbs return: RSpec::SSE::Matchers::ContainExactlyEvents
    def contain_exactly_events(*events)
      RSpec::SSE::Matchers::ContainExactlyEvents.new(events.flatten)
    end

    # Matches if the response's event types contain the expected types regardless of order
    #
    # @rbs *types: String | Array[String]
    # @rbs return: RSpec::SSE::Matchers::ContainExactlyEventTypes
    def contain_exactly_event_types(*types)
      RSpec::SSE::Matchers::ContainExactlyEventTypes.new(types.flatten)
    end

    # Matches if the response's event data contain the expected data regardless of order
    #
    # @rbs *data: String | Array[String]
    # @rbs return: RSpec::SSE::Matchers::ContainExactlyEventData
    def contain_exactly_event_data(*data)
      RSpec::SSE::Matchers::ContainExactlyEventData.new(data.flatten)
    end

    # Matches if the response's event IDs contain the expected IDs regardless of order
    #
    # @rbs *ids: String | Array[String]
    # @rbs return: RSpec::SSE::Matchers::ContainExactlyEventIds
    def contain_exactly_event_ids(*ids)
      RSpec::SSE::Matchers::ContainExactlyEventIds.new(ids.flatten)
    end

    # Matches if the response's reconnection times contain the expected times regardless of order
    #
    # @rbs *times: Integer | Array[Integer]
    # @rbs return: RSpec::SSE::Matchers::ContainExactlyReconnectionTimes
    def contain_exactly_reconnection_times(*times)
      RSpec::SSE::Matchers::ContainExactlyReconnectionTimes.new(times.flatten)
    end

    # Matches if the response's events include all the expected events
    #
    # @rbs *events: ssePayload
    # @rbs return: RSpec::SSE::Matchers::HaveEvents
    def have_events(*events)
      RSpec::SSE::Matchers::HaveEvents.new(events.flatten)
    end

    # Matches if the response's event types include all the expected types
    #
    # @rbs *types: String | Array[String]
    # @rbs return: RSpec::SSE::Matchers::HaveEventTypes
    def have_event_types(*types)
      RSpec::SSE::Matchers::HaveEventTypes.new(types.flatten)
    end

    # Matches if the response's event data include all the expected data
    #
    # @rbs *data: String | Array[String]
    # @rbs return: RSpec::SSE::Matchers::HaveEventData
    def have_event_data(*data)
      RSpec::SSE::Matchers::HaveEventData.new(data.flatten)
    end

    # Matches if the response's event IDs include all the expected IDs
    #
    # @rbs *ids: String
    # @rbs return: RSpec::SSE::Matchers::HaveEventIds
    def have_event_ids(*ids)
      RSpec::SSE::Matchers::HaveEventIds.new(ids.flatten)
    end

    # Matches if the response's reconnection times include all the expected times
    #
    # @rbs *times: Integer
    # @rbs return: RSpec::SSE::Matchers::HaveReconnectionTimes
    def have_reconnection_times(*times)
      RSpec::SSE::Matchers::HaveReconnectionTimes.new(times.flatten)
    end
  end
end

module RSpec
  module SSE
    module Matchers
      class SseParser
        # @rbs body: String
        # @rbs return: Array[ssePayload]
        def self.parse(body)
          events = []
          EventStreamParser::Parser.new.feed(body) do |type, data, id, reconnection_time|
            events << {
              type:,
              data:,
              id:,
              retry: reconnection_time
            }
          end
          events
        end
      end

      class BaseMatcher
        # @rbs @expected: Array[Object]
        # @rbs @actual: Object
        # @rbs @parsed_events: Array[ssePayload]

        # Initialize the matcher with expected values
        #
        # @rbs expected: Array[Object]
        # @rbs return: RSpec::SSE::Matchers::BaseMatcher
        def initialize(expected)
          @expected = expected
        end

        # @rbs actual: Object
        # @rbs return: bool
        def matches?(actual)
          @actual = actual
          @parsed_events = SseParser.parse(actual.body)
          match_condition
        end

        # @rbs return: String
        def failure_message
          "Expected #{description_for(@actual)} to #{description}"
        end

        # @rbs return: String
        def failure_message_when_negated
          "Expected #{description_for(@actual)} not to #{description}"
        end

        private

        # @rbs obj: Object
        # @rbs return: String
        def description_for(obj)
          return "response with events #{extract_actual.inspect}" if obj.respond_to?(:body)
          obj.inspect
        end

        # @rbs return: Array[Object]
        def extract_actual
          @parsed_events
        end

        # @rbs return: String
        def description
          "match #{@expected.inspect}"
        end

        # @rbs return: bool
        def match_condition
          raise NotImplementedError, "Subclasses must implement match_condition"
        end
      end

      class BeGracefullyClosed
        # @rbs @actual: Object

        # Match if the response body ends with "\n\n" (SSE graceful close)
        #
        # @rbs actual: Object
        # @rbs return: bool
        def matches?(actual)
          @actual = actual
          @actual.body.end_with?("\n\n")
        end

        # @rbs return: String
        def failure_message
          'Expected response body to end with "\\n\\n" (SSE graceful close)'
        end

        # @rbs return: String
        def failure_message_when_negated
          'Expected response body not to end with "\\n\\n" (SSE graceful close)'
        end

        # @rbs return: String
        def description
          "be gracefully closed"
        end
      end

      class BeSuccessfullyOpened
        # @rbs @actual: Object

        # Match if the header and status code indicate a successful SSE connection
        #
        # @rbs actual: Object
        # @rbs return: bool
        def matches?(actual)
          @actual = actual
          @actual.headers["content-type"] == "text/event-stream" \
            && @actual.headers["cache-control"]&.match(/no-store/) \
            && @actual.headers["content-length"].nil? \
            && @actual.status == 200
        end

        # @rbs return: String
        def failure_message
          "Expected response header of `content-type` is `text/event-stream`, `cache-control` contains `no-store`, `content-length` does not exist, and status code is `2xx`"
        end

        # @rbs return: String
        def failure_message_when_negated
          "Expected response header of `content-type` is not `text/event-stream`, `cache-control` does not contain `no-store`, `content-length` exists, and/or status code is not `2xx`"
        end

        # @rbs return: String
        def description
          "be successfully opened"
        end
      end

      class ExactMatcher < BaseMatcher
        # Match if extracted actual values exactly match expected values
        #
        # @rbs return: bool
        def match_condition
          extract_actual == @expected
        end

        # @rbs return: String
        def description
          "exactly match #{@expected.inspect}"
        end
      end

      # Base matcher for contain exactly matching (order doesn't matter)
      class ContainExactlyMatcher < BaseMatcher
        # Match if extracted actual values match expected values in any order
        #
        # @rbs return: bool
        def match_condition
          (extract_actual - @expected).empty? && (@expected - extract_actual).empty? && extract_actual.size == @expected.size
        end

        # @rbs return: String
        def description
          "contain exactly #{@expected.inspect} in any order"
        end
      end

      # Base matcher for inclusion matching (subset)
      class IncludeMatcher < BaseMatcher
        # Match if extracted actual values include all expected values
        #
        # @rbs return: bool
        def match_condition
          @expected.all? { |expected_item| extract_actual.include?(expected_item) }
        end

        # @rbs return: String
        def description
          "include #{@expected.inspect}"
        end
      end

      # Events matchers

      # Matcher for be_events
      class BeEvents < ExactMatcher
      end

      # Matcher for contain_exactly_events
      class ContainExactlyEvents < ContainExactlyMatcher
      end

      # Matcher for have_events
      class HaveEvents < IncludeMatcher
      end

      module TypeExtractor
        private

        # Extract event types from parsed events
        #
        # @rbs return: Array[String|nil]
        def extract_actual
          @parsed_events.map { |event| event[:type] }
        end
      end

      # Matcher for be_event_types
      class BeEventTypes < ExactMatcher
        include TypeExtractor

        private

        # @rbs return: String
        def description
          "have event types exactly matching #{@expected.inspect}"
        end
      end

      # Matcher for contain_exactly_event_types
      class ContainExactlyEventTypes < ContainExactlyMatcher
        include TypeExtractor

        private

        # @rbs return: String
        def description
          "contain exactly event types #{@expected.inspect} in any order"
        end
      end

      # Matcher for have_event_types
      class HaveEventTypes < IncludeMatcher
        include TypeExtractor

        private

        # @rbs return: String
        def description
          "include event types #{@expected.inspect}"
        end
      end

      module DataExtractor
        private

        # Extract event data from parsed events
        #
        # @rbs return: Array[String]
        def extract_actual
          @parsed_events.map { |event| event[:data] }
        end
      end

      # Matcher for be_event_data
      class BeEventData < ExactMatcher
        include DataExtractor

        private

        # @rbs return: String
        def description
          "have event data exactly matching #{@expected.inspect}"
        end
      end

      # Matcher for contain_exactly_event_data
      class ContainExactlyEventData < ContainExactlyMatcher
        include DataExtractor

        private

        # @rbs return: String
        def description
          "contain exactly event data #{@expected.inspect} in any order"
        end
      end

      # Matcher for have_event_data
      class HaveEventData < IncludeMatcher
        include DataExtractor

        private

        # @rbs return: String
        def description
          "include event data #{@expected.inspect}"
        end
      end

      module IdExtractor
        private

        # Extract event IDs from parsed events
        #
        # @rbs return: Array[String|nil]
        def extract_actual
          @parsed_events.map { |event| event[:id] }
        end
      end

      # Matcher for be_event_ids
      class BeEventIds < ExactMatcher
        include IdExtractor

        private

        # @rbs return: String
        def description
          "have event IDs exactly matching #{@expected.inspect}"
        end
      end

      # Matcher for contain_exactly_event_ids
      class ContainExactlyEventIds < ContainExactlyMatcher
        include IdExtractor

        private

        # @rbs return: String
        def description
          "contain exactly event IDs #{@expected.inspect} in any order"
        end
      end

      # Matcher for have_event_ids
      class HaveEventIds < IncludeMatcher
        include IdExtractor

        private

        # @rbs return: String
        def description
          "include event IDs #{@expected.inspect}"
        end
      end

      module RetryExtractor
        private

        # Extract reconnection times from parsed events
        #
        # @rbs return: Array[Integer,nil]
        def extract_actual
          @parsed_events.map { |event| event[:retry] }
        end
      end

      # Matcher for be_reconnection_times
      class BeReconnectionTimes < ExactMatcher
        include RetryExtractor

        private

        # @rbs return: String
        def description
          "have reconnection times exactly matching #{@expected.inspect}"
        end
      end

      # Matcher for contain_exactly_reconnection_times
      class ContainExactlyReconnectionTimes < ContainExactlyMatcher
        include RetryExtractor

        private

        # @rbs return: String
        def description
          "contain exactly reconnection times #{@expected.inspect} in any order"
        end
      end

      # Matcher for have_reconnection_times
      class HaveReconnectionTimes < IncludeMatcher
        include RetryExtractor

        private

        # @rbs return: String
        def description
          "include reconnection times #{@expected.inspect}"
        end
      end
    end
  end
end
