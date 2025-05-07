# RSpec SSE Matchers

A collection of [RSpec](https://rspec.info/) matchers for testing [Server-Sent Events (SSE)](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events).

[![Build Status](https://github.com/moznion/rspec-sse-matchers/workflows/Test/badge.svg)](https://github.com/moznion/rspec-sse-matchers/actions)
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

## Requirements

- Ruby >= 3.0.0
- RSpec >= 3.0
- event_stream_parser ~> 1.0.0

## Usage

This gem provides a set of matchers to test SSE responses in your RSpec request specs:

```ruby
# In your controller
def index
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
    
    # Verify the event types
    expect(response).to be_event_types(['message', 'update'])
    
    # Verify that the response is properly closed
    expect(response).to be_gracefully_closed
  end
end
```

### Available Matchers

#### Exact Order Matchers

These matchers check that the specified values appear in the exact order:

- `be_events`: Check that the events exactly match the expected events
- `be_event_types`: Check that the event types exactly match the expected types
- `be_event_data`: Check that the event data exactly match the expected data
- `be_event_ids`: Check that the event IDs exactly match the expected IDs
- `be_reconnection_times`: Check that the reconnection times exactly match the expected times

#### Order-Independent Matchers

These matchers check that the specified values appear in any order:

- `contain_exactly_events`: Check that the events match the expected events regardless of order
- `contain_exactly_event_types`: Check that the event types match the expected types regardless of order
- `contain_exactly_event_data`: Check that the event data match the expected data regardless of order
- `contain_exactly_event_ids`: Check that the event IDs match the expected IDs regardless of order
- `contain_exactly_reconnection_times`: Check that the reconnection times match the expected times regardless of order

#### Inclusion Matchers

These matchers check that all the expected values are included:

- `have_events`: Check that all the expected events are included
- `have_event_types`: Check that all the expected event types are included
- `have_event_data`: Check that all the expected event data are included
- `have_event_ids`: Check that all the expected event IDs are included
- `have_reconnection_times`: Check that all the expected reconnection times are included

#### Miscellaneous Matchers

- `be_gracefully_closed`: Check that the response body ends with "\n\n" (indicating proper SSE close)

### Argument Formats

All matchers can accept their arguments either as individual arguments or as an array:

```ruby
# These are equivalent:
expect(response).to have_event_types('message', 'update', 'close')
expect(response).to have_event_types(['message', 'update', 'close'])
```

## Examples

### Testing Event Types

```ruby
# Exact order
expect(response).to be_event_types(['message', 'update', 'close'])

# Any order
expect(response).to contain_exactly_event_types(['update', 'message', 'close'])

# Inclusion
expect(response).to have_event_types(['message', 'update'])
```

### Testing Event Data

```ruby
# Exact order
expect(response).to be_event_data(['{"id":1}', '{"id":2}', '{"id":3}'])

# Any order
expect(response).to contain_exactly_event_data(['{"id":2}', '{"id":1}', '{"id":3}'])

# Inclusion
expect(response).to have_event_data(['{"id":1}', '{"id":2}'])
```

### Testing Event IDs

```ruby
# Exact order
expect(response).to be_event_ids(['1', '2', '3'])

# Any order
expect(response).to contain_exactly_event_ids(['2', '1', '3'])

# Inclusion
expect(response).to have_event_ids(['1', '2'])
```

### Testing Reconnection Times

```ruby
# Exact order
expect(response).to be_reconnection_times([1000, 2000, 3000])

# Any order
expect(response).to contain_exactly_reconnection_times([2000, 1000, 3000])

# Inclusion
expect(response).to have_reconnection_times([1000, 2000])
```

### Testing Complete Events

```ruby
events = [
  { type: 'message', data: '{"id":1}', id: '1', retry: 1000 },
  { type: 'update', data: '{"id":2}', id: '2', retry: 2000 }
]

# Exact order
expect(response).to be_events(events)

# Any order
expect(response).to contain_exactly_events(events)

# Inclusion
expect(response).to have_events([events.first])
```

### Testing Proper SSE Closure

```ruby
expect(response).to be_gracefully_closed
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
