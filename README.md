# GoogleMusicApi

This is a port of Simon Webber's cool [`gmusicapi`](https://github.com/simon-weber/gmusicapi) Python library. It currently
only implements the `MobileClient` methods. I don't have any plans to add support for `Webclient` or `MusicManager` at 
this moment, but I would welcome anybody who wants to add it. 


## Notes
Google Two-Factor Authentication is not supported at the moment, you will have to create a app 
password for using this. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'google_music_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google_music_api

## Usage

```ruby
client = GoogleMusicApi::Mobileclient.new

client.login(email, password)
 
client.search('Radiohead')
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/poloniculmov/google_music_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

