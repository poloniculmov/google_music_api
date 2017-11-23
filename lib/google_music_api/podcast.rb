require 'google_music_api/util'
module GoogleMusicApi
  #Holds all the playlist related methods
  module Podcast
    include Util
    #Gets all the playlists that user has
    #@return [Array] of Hashes that describe a playlist
    def get_podcast_episode(id)
      url = 'podcast/fetchepisode'
      options = {
        headers: {
          'Content-Type': 'application/json'
        },
        query: {
          'alt': 'json',
          'nid': id
        }
      }
      make_get_request(url,options)
    end

    def get_podcast_stream(track_id, device_id = @dev_id, quality = 'hi')
      url = 'fplay'

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
  end
end

