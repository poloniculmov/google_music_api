module GoogleMusicApi
  module Track
    #Gets details about a track
    # @param [string] track_id
    # @return [hash] describing the track
    def get_track_info(track_id)
      url = 'fetchtrack'

      options = {
          query: {
              nid: track_id
          }
      }

      make_get_request url, options
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