require 'gpsoauth'
require 'google_music_api/http'
require 'google_music_api/genre'
require 'google_music_api/playlist'
require 'google_music_api/library'
require 'google_music_api/station'
require 'google_music_api/album'
require 'google_music_api/artist'
require 'google_music_api/track'

module GoogleMusicApi
  class MobileClient

    SERVICE = 'sj'
    APP = 'com.google.android.music'
    CLIENT_SIGNATURE = '38918a453d07199354f8b19af05ec6562ced5788'
    STREAM_ENDPOINT = 'https://mclients.googleapis.com/music/'
    SERVICE_ENDPOINT = 'https://mclients.googleapis.com/sj/v2.4/'
  
    include Http
    include Genre
    include Playlist
    include Library
    include Station
    include Album
    include Artist
    include Track

    #Pass an authorization token and you won't have to login
    # @param [string] authorization_token
    def initialize(authorization_token = nil, dev_id = nil)
      @authorization_token = authorization_token
      @dev_id = dev_id
    end


    # Logs in to Google using OAuth and obtains an authorization token
    #
    # @param email [String] your email
    # @param [String] password you password
    # @param [String] android_id 16 hex digits, eg '1234567890abcdef'
    # @param [String] device_country the country code of the device you're impersonating, default = 'us'
    # @param [String] operator_country the country code of the device's mobile operator, default = 'us'
    #
    # @raise [AuthenticationError] if authentication fails
    # @return true if success
    def login(email, password, android_id, device_country='us', operator_country='us')
      g = Gpsoauth::Client.new(android_id, 'ac2dm', device_country, operator_country)

      response = g.master_login(email, password)
      oauth_response = g.oauth(email, response['Token'], SERVICE, APP, CLIENT_SIGNATURE)
      raise AuthenticationError.new('Invalid username/password') unless oauth_response.key?('Auth')
      @authorization_token = oauth_response['Auth']
      @dev_id = android_id
      true
    end

    # Checks if there's an authorization token present
    # @return [boolean]
    def authenticated?
      !!@authorization_token
    end

    # Checks whether the user is subscribed or not
    # @return [boolean]
    def subscribed?
      url = 'config'
      options = {query: {dv: 0}}

      subscribed = make_get_request(url, options)['data']['entries'].find do |item|
        item['key'] == 'isNautilusUser' && item['value'] == 'true'
      end

      !subscribed.nil?
    end

    #Generic search
    # 1: Song, 2: Artist, 3: Album, 4: Playlist, 6: Station, 7: Situation, 8: Video
    # @param [string] query
    # @param [string] ct Used to restrict search to specific items, comma-separated list of item type ids.
    # @param [integer] max_results
    def search(query, ct = '1,2,3,4,6,7,8', max_results = 50)
      url = 'query'

      options = {
          query: {
              'ct': ct,
              'q': query,
              'max-results': max_results
          }
      }

      make_get_request(url, options)['entries']
    end

    def authorization_token
      @authorization_token
    end

  end
end
