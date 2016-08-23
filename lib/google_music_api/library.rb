module GoogleMusicApi
  #Holds all the library related methods
  module Library

    #Gets all tracks in the library#
    # @return [Array] of hashes describing tracks
    def get_all_tracks
      url = 'trackfeed'

      make_post_request(url)['data']['items']
    end

    #Gets the promoted songs
    # @return [Array] of hashes describing tracks
    def get_promoted_songs
      url = 'ephemeral/top'

      make_post_request(url)['data']['items']
    end

    # Gets all listen now items
    # return [Array] of hashes, each hash can describe a different kind of item Station/Track/Album
    def get_listen_now_items
      url = 'listennow/getlistennowitems'
      options = {'alt': 'json'}

      make_get_request(url)['listennow_items']
    end

    def add_tracks_to_library(song_ids = [])
      #TODO: Implement after adding Hashie support as this needs an extra call
      url = 'trackbatch'

      throw NotImplementedError.new
    end

  end
end