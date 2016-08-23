require 'gpsoauth'
require 'google_music_api/http'
require 'google_music_api/genre'
require 'google_music_api/playlist'
require 'google_music_api/library'

module GoogleMusicApi
  class MobileClient

    SERVICE = 'sj'
    APP = 'com.google.android.music'
    CLIENT_SIGNATURE = '38918a453d07199354f8b19af05ec6562ced5788'

    SERVICE_ENDPOINT = 'https://mclients.googleapis.com/sj/v2.4/'

    include Http
    include Genre
    include Playlist
    include Library



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


    def search(query, max_results: 50)
      url = 'query'

      # The result types returned are requested in the `ct` parameter.
      # Free account search is restricted so may not contain hits for all result types.
      # 1: Song, 2: Artist, 3: Album, 4: Playlist, 6: Station, 7: Situation, 8: Video

      options = {
          query: {
              'ct': '1,2,3,4,6,7,8',
              'q': query,
              'max-results': max_results
          }
      }

      make_get_request(url, options)['entries']
    end

    def get_listen_now_situations
      url = 'listennow/situations'
      options = {query: {'alt': 'json', 'tier': 'aa', 'hl': 'en_US'}}

      body = {'requestSignals': {'timeZoneOffsetSecs': Time.now.gmt_offset}}.to_json

      options[:body] = body
      make_post_request(url, options)
    end

    def get_all_stations
      url = 'radio/station'
      options = {query: {'alt': 'json', 'tier': 'aa', 'hl': 'en_US'}}

      make_post_request(url, options)
    end

    def get_station_tracks(station_id, number_of_tracks: 25, recently_played: [])
      url = 'radio/stationfeed'
      options = {query: {'alt': 'json', 'include-tracks': 'true', 'tier': 'aa', 'hl': 'en_US'}}

      options[:body] = {'contentFilter': 1,
                        'stations': [
                            {
                                'numEntries': number_of_tracks,
                                'radioId': station_id,
                                'recentlyPlayed': recently_played.map { |rec| add_track_type rec }
                            }
                        ]}.to_json

      make_post_request(url, options)
    end

    def get_im_feeling_lucky_tracks(number_of_tracks: 25, recently_played: [])
      get_station_tracks 'IFL', number_of_tracks: number_of_tracks, recently_played: recently_played
    end

    def get_artist_info(artist_id, include_albums = true, max_top_tracks = 5, max_related_artists = 5)
      url = 'fetchartist'

      options = {
          query: {
              nid: artist_id,
              'include-albums': include_albums,
              'num-top-tracks': max_top_tracks,
              'num-related-artists': max_related_artists
          }
      }

      make_get_request(url, options)
    end

    def get_album_info(album_id, include_tracks = true)
      url = 'fetchalbum'

      options = {
          query: {
              nid: album_id,
              'include-tracks': include_tracks
          }
      }

      make_get_request(url, options)
    end

    def get_track_info(track_id)
      url = 'fetchtrack'

      options = {
          query: {
              nid: track_id
          }
      }

      make_get_request url, options
    end


    def increase_track_play_count(song_id, number_of_plays = 1, play_time = Time.now)
      url = 'trackstats'

      options = {
          query: {
              alt: 'json'
          }
      }

      play_timestamp = (play_time.to_f * 1000).to_i
      event = {
          context_type: 1,
          event_timestamp_micros: play_timestamp,
          event_type: 2
      }

      options[:body] = {
          track_stats: [{
                            id: song_id,
                            incremental_plays: number_of_plays,
                            last_play_time_millis: play_timestamp,
                            type: song_id[0] == 'T' ? 2 : 1,
                            track_events: [event] * number_of_plays
                        }]
      }.to_json

      make_post_request url, options
    end



    def create_station
      throw NotImplementedError.new
    end

    def delete_station
      throw NotImplementedError.new
    end


    def authorization_token
      @authorization_token
    end

  end
end