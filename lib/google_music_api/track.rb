require "base64"
require 'openssl'
module GoogleMusicApi
  module Track
    #Gets details about a track
    # @param [string] track_id
    # @return [hash] describing the track
    def get_key
      @key = Base64.decode64('MzRlZTc5ODMtNWVlNi00MTQ3LWFhODYtNDQzZWEwNjJhYmY3NzQ0OTNkNmEtMmExNS00M2ZlLWFhY2UtZTc4NTY2OTI3NTg1Cg==')
    end
    def get_track_info(track_id)
      url = 'fetchtrack'

      options = {
          query: {
              nid: track_id
          },
          headers: {
            'Content-Type': 'application/json'
	  }	
      }

      make_get_request url, options
    end

    def get_signature( data, salt=nil)
      if salt == nil
        salt = (Time.now.to_i * 1000).to_s
      end
      
      hmac = OpenSSL::HMAC.new(get_key,OpenSSL::Digest.new('sha1'))
      hmac << data.force_encoding("utf-8")
      hmac << salt.force_encoding("utf-8")
      sig = Base64.urlsafe_encode64(hmac.digest).chop
      
      return sig,salt
    end

    def get_track_stream(track_id, device_id = @dev_id, quality = 'hi')
      url = 'mplay'
      
      sig,salt=get_signature(track_id)
      
      options = {
        query: {
          'opt': quality,
          'net': 'mob',
          'pt': 'e',
          'slt': salt,
          'sig': sig
        },
        headers: {
          'X-Device-ID': device_id
        }
      }
      if track_id.start_with?('T') || track_id.start_with?('D')
        # Store track or podcast episode.
        options[:query]['mjck'] = track_id
      else
        options[:query]['songid'] = track_id    
      end
      make_play_request url, options
    end

    #Increases a tracks play count
    # @param [string] song_id
    # @param [integer] number_of_plays
    # @param [Time] play_time
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

    #Searches tracks
    # @param [string] query
    # @param [integer] max_results
    # @return [Hash] describing tracks
    def search_tracks(query, max_results=50)
      search(query, '1', max_results)
    end

  end
end
