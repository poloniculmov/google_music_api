module GoogleMusicApi
  module Album

    #Gets an album's details
    # @param [string] album_id
    # @param [string] include_tracks
    # @return [Hash] describing an album and tracks
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

    #Searches albums
    # @param [string] query
    # @param [integer] max_results
    # @return [Hash] describing albums
    def search_albums(query, max_results=50)
      search(query, '3', max_results)
    end

  end
end