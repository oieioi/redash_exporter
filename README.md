[![Gem Version](https://badge.fury.io/rb/redash_exporter.svg)](https://badge.fury.io/rb/redash_exporter)
![Ruby](https://github.com/oieioi/redash_exporter/workflows/Ruby/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/oieioi/redash_exporter/badge.svg?branch=master)](https://coveralls.io/github/oieioi/redash_exporter?branch=master)

# RedashExporter

This gem is inspired by [Redash Query Export Tool](https://gist.github.com/arikfr/598590356c4da18be976)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redash_exporter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redash_exporter

## Usage

Shell

    $ redash_exporter --redash-url "http://your-redash-domain.example/<slug>" --api-key="your_api_key"

With destination path and force to overwrite existed files

    $ redash_exporter --redash-url "http://your-redash-domain.example/<slug>" --api-key="your_api_key" --dest=destination_directory --overwrite

in Ruby Script

```ruby
queries = RedashExporter::Queries.new 'https://your-redash-host.example/your_path', 'your_api_key', 'export_path'
queries.fetch
queries.export_all

# filter
queries
  .reject! { |query| query['retrieved_at'].nil? }
  .reject! { |qeury| query['retrieved_at'].to_time < 3.months.ago }
  .export_all

# OR
queries
  .reject { |query| query[:retrieved_at].nil? }
  .each(&:export)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oieioi/redash_exporter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RedashExporter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/oieioi/redash_exporter/blob/master/CODE_OF_CONDUCT.md).
