require 'google_music_api/util'
require 'google_music_api/track'
module GoogleMusicApi
  #Holds all the playlist related methods
  module Podcast
    include Util
    include Track
    
    #Get podcast episodes from series
    #@id [string] id of the podcast series
    #@num [int] count of episodes to grab
    #@return [Array] of Hashes that describe episodes in a series
    def get_podcast_series(id,num=25) 
      url = 'podcast/fetchseries'
 
      options = {
        headers: {
          'Content-Type': 'application/json'
        },
        query: {
          'alt': 'json',
          'nid': id,
          'num': num
        }
      }

      make_get_request url, options
    end

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

