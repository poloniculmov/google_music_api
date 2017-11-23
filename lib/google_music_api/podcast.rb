module GoogleMusicApi
  #Holds all the playlist related methods
  module Podcast

    #Gets all the playlists that user has
    #@return [Array] of Hashes that describe a playlist
    def get_podcast_episode(id)
      url = 'podcast/fetchepisode'
      options = {
        headers: {
          'Content-Type': 'application/json'
        },
        params: {
          'alt': 'json',
          'nid': id
        }
      }
      make_get_request(url,options)
    end
  end
end

