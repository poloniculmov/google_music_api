module GoogleMusicApi
  module Artist

    # Gets an artists details
    # @param [String] artist_id
    # @param [boolean] include_albums
    # @param [integer] max_top_tracks
    # @param [integer] max_related_artists
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

    #Searches albums
    # @param [string] query
    # @param [integer] max_results
    # @return [Hash] describing artists
    def search_artists(query, max_results=50)
      search(query, '2', max_results)
    end

  end
end