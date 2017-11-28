require 'google_music_api/util'
require 'google_music_api/track'
module GoogleMusicApi
  #Holds all the playlist related methods
  module Podcast
    include Util
    include Track
    
    #Gets podcast episode metadata
    #@id [string] podcast id
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
      get_track_stream(track_id,device_id,quality,url)
    end
  end
end

