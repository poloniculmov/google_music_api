require 'google_music_api/util'
module GoogleMusicApi
  module Station
    include Util

    #Gets the current listen now situations and their associated stations
    # @return [Array] of situations and their respected stations
    def get_listen_now_situations
      url = 'listennow/situations'
      options = {query: {'alt': 'json', 'tier': 'aa', 'hl': 'en_US'}}

      body = {'requestSignals': {'timeZoneOffsetSecs': Time.now.gmt_offset}}.to_json

      options[:body] = body
      make_post_request(url, options)['situations']
    end

    # Gets all radio stations
    # It seems to be tied to what the user
    # @return [Array] of radios stations
    def get_all_stations
      url = 'radio/station'
      options = {query: {'alt': 'json', 'tier': 'aa', 'hl': 'en_US'}}

      make_post_request(url, options)
    end

    # Gets a station's tracks
    # @param [string] station_id
    # In newer implemtations the station_id is really another ID: Track, Album, Artist, etc...
    # @param [integer] number_of_tracks
    # @param [Array] recently_played track ids
    # @return [Array] of tracks
    def get_station_tracks(station_id, number_of_tracks = 25, recently_played = [])
      url = 'radio/stationfeed'
      options = {
        query: {'alt': 'json', 'include-tracks': 'true', 'tier': 'aa', 'hl': 'en_US'},
        headers: {'Content-Type': 'application/json'},
        body: {'contentFilter': 1,
                        'stations': [
                            {
                                'numEntries': number_of_tracks,
                                'recentlyPlayed': recently_played.map { |rec| add_track_type rec},
                                'seed': { 
                                  "#{get_typename_from_id(station_id)}": station_id, 
                                  'kind': 'sj#radioSeed', 
                                  'seedType': get_seed_type_from_id(station_id)
                                }
                            }
                        ]}.to_json
      }

      res = make_post_request(url, options)
      return res['data']['stations']
    end

    #Gets I'm feeling lucky station tracks
    # @param [integer] number_of_tracks
    # @param [Array] recently_played track ids
    # @return [Array] of tracks
    def get_im_feeling_lucky_tracks(number_of_tracks = 25, recently_played = [])
      get_station_tracks 'IFL', number_of_tracks, recently_played
    end

    def create_station
      throw NotImplementedError.new
    end

    def delete_station
      throw NotImplementedError.new
    end


  end
end
