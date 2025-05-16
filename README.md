# RSpec SSE Matchers

A collection of [RSpec](https://rspec.info/) matchers for testing [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events).

[![Tests](https://github.com/moznion/rspec-sse-matchers/actions/workflows/test.yml/badge.svg)](https://github.com/moznion/rspec-sse-matchers/actions/workflows/test.yml)
[![Gem Version](https://badge.fury.io/rb/rspec-sse-matchers.svg)](https://badge.fury.io/rb/rspec-sse-matchers)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-sse-matchers'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install rspec-sse-matchers
```

## Synopsis

This gem provides a set of matchers to test SSE responses in your RSpec request specs:

```ruby
# In your controller
def index
  response.headers['Cache-Control'] = 'no-store'
  response.headers['Content-Type'] = 'text/event-stream'
  sse = SSE.new(response.stream)

  sse.write({id: 1, message: 'Hello'}, event: 'message', id: 1)
  sse.write({id: 2, message: 'World'}, event: 'update', id: 2)
  sse.close
end

# In your spec
RSpec.describe 'SSE endpoint', type: :request do
  it 'sends the expected events' do
    get '/events', headers: { 'Accept' => 'text/event-stream' }

    # Verify the response indicates a successful SSE connection
    expect(response).to be_sse_successfully_opened

    # Verify the event types
    expect(response).to be_sse_event_types(['message', 'update'])

    # Verify that the response is properly closed
    expect(response).to be_sse_gracefully_closed
  end
end
```

### Available Matchers

#### Exact Order Matchers

These matchers check that the specified values appear in the exact order:

- `be_sse_events`: Check that the events exactly match the expected events
- `be_sse_event_types`: Check that the event types exactly match the expected types
- `be_sse_event_data`: Check that the event data exactly match the expected data
- `be_sse_event_ids`: Check that the event IDs exactly match the expected IDs
- `be_sse_reconnection_times`: Check that the reconnection times exactly match the expected times

All event data matchers (`be_sse_event_data`, `contain_exactly_sse_event_data`, `have_sse_event_data`) and event matchers (`be_sse_events`, `contain_exactly_sse_events`, `have_sse_events`) accept a `json: true` option that will parse the JSON in event data for comparison.

#### Order-Independent Matchers

These matchers check that the specified values appear in any order:

- `contain_exactly_sse_events`: Check that the events match the expected events regardless of order
- `contain_exactly_sse_event_types`: Check that the event types match the expected types regardless of order
- `contain_exactly_sse_event_data`: Check that the event data match the expected data regardless of order
- `contain_exactly_sse_event_ids`: Check that the event IDs match the expected IDs regardless of order
- `contain_exactly_sse_reconnection_times`: Check that the reconnection times match the expected times regardless of order

#### Inclusion Matchers

These matchers check that all the expected values are included:

- `have_sse_events`: Check that all the expected events are included
- `have_sse_event_types`: Check that all the expected event types are included
- `have_sse_event_data`: Check that all the expected event data are included
- `have_sse_event_ids`: Check that all the expected event IDs are included
- `have_sse_reconnection_times`: Check that all the expected reconnection times are included

#### Miscellaneous Matchers

- `be_sse_successfully_opened`: Check that the response indicates the SSE connection has been opened successfully
- `be_sse_gracefully_closed`: Check that the response body ends with "\n\n" (indicating proper SSE close)

### Argument Formats

All matchers can accept their arguments either as individual arguments or as an array:

```ruby
# These are equivalent:
expect(response).to have_sse_event_types('message', 'update', 'close')
expect(response).to have_sse_event_types(['message', 'update', 'close'])
```

### JSON Parsing Option

Event data matchers and event matchers accept a `json: true` option that automatically parses JSON in event `data` for comparison:

```ruby
# Without JSON parsing (string comparison)
expect(response).to be_sse_event_data(['{"id":1,"name":"Alice"}', '{"id":2,"name":"Bob"}'])

# With JSON parsing (object comparison)
expect(response).to be_sse_event_data([{"id" => 1, "name" => "Alice"}, {"id" => 2, "name" => "Bob"}], json: true)

# This also works with event matchers
expect(response).to be_sse_events([
  {type: 'message', data: {"id" => 1, "name" => "Alice"}, id: '1'},
  {type: 'update', data: {"id" => 2, "name" => "Bob"}, id: '2'}
], json: true)
```

When the `json: true` option is enabled, the matcher attempts to parse each event's `data` as JSON. If parsing fails (the data is not valid JSON), it raises an error.

### Using Custom RSpec Matchers

The SSE matchers now support RSpec custom matchers like `hash_including`, `a_kind_of`, `be_an`, etc. This allows for more flexible matching when testing SSE events with complex data structures:

```ruby
# With hash_including for partial matching
expect(response).to be_sse_events([
  {type: "in_progress", data: {"event" => "in_progress", "data" => {}}, id: "1", retry: 250},
  hash_including(
    type: "finished",
    data: hash_including(
      "event" => "finished",
      "data" => hash_including(
        "object_id" => a_kind_of(String),  # or a_string_starting_with("prefix_")
        "results" => be_an(Array)
      )
    ),
    id: "2",
    retry: 250
  )
], json: true)

# With type checking matchers
expect(response).to be_sse_event_data([
  hash_including("id" => a_kind_of(Integer), "name" => a_kind_of(String)),
  hash_including("status" => match(/active|pending/))
], json: true)

# Works with all matcher types
expect(response).to contain_exactly_sse_events([
  hash_including(data: hash_including("status" => "pending")),
  hash_including(data: hash_including("status" => "active"))
], json: true)

expect(response).to have_sse_events([
  hash_including(data: hash_including("important_field" => "value"))
], json: true)
```

Custom matchers are particularly useful when:
- You only care about specific fields in the event data
- You want to match patterns or types rather than exact values
- You need to test complex nested structures
- You want to ignore irrelevant fields

## Examples

### Testing Event Types

```ruby
# Exact order
expect(response).to be_sse_event_types(['message', 'update', 'close'])

# Any order
expect(response).to contain_exactly_sse_event_types(['update', 'message', 'close'])

# Inclusion
expect(response).to have_sse_event_types(['message', 'update'])
```

### Testing Event Data

```ruby
# Exact order
expect(response).to be_sse_event_data(['{"id":1}', '{"id":2}', '{"id":3}'])

# Any order
expect(response).to contain_exactly_sse_event_data(['{"id":2}', '{"id":1}', '{"id":3}'])

# Inclusion
expect(response).to have_sse_event_data(['{"id":1}', '{"id":2}'])

# With JSON parsing
expect(response).to be_sse_event_data([{"id" => 1}, {"id" => 2}, {"id" => 3}], json: true)
```

### Testing Event IDs

```ruby
# Exact order
expect(response).to be_sse_event_ids(['1', '2', '3'])

# Any order
expect(response).to contain_exactly_sse_event_ids(['2', '1', '3'])

# Inclusion
expect(response).to have_sse_event_ids(['1', '2'])
```

### Testing Reconnection Times

```ruby
# Exact order
expect(response).to be_sse_reconnection_times([1000, 2000, 3000])

# Any order
expect(response).to contain_exactly_sse_reconnection_times([2000, 1000, 3000])

# Inclusion
expect(response).to have_sse_reconnection_times([1000, 2000])
```

### Testing Complete Events

```ruby
events = [
  {type: 'message', data: '{"id":1}', id: '1', retry: 1000},
  {type: 'update', data: '{"id":2}', id: '2', retry: 2000}
]

# Exact order
expect(response).to be_sse_events(events)

# Any order
expect(response).to contain_exactly_sse_events(events)

# Inclusion
expect(response).to have_sse_events([events.first])

# With JSON parsing
json_events = [
  {type: 'message', data: {"id" => 1}, id: '1', retry: 1000},
  {type: 'update', data: {"id" => 2}, id: '2', retry: 2000}
]
expect(response).to be_sse_events(json_events, json: true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moznion/rspec-sse-matchers. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/moznion/rspec-sse-matchers/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RSpec SSE Matchers project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/moznion/rspec-sse-matchers/blob/main/CODE_OF_CONDUCT.md).
