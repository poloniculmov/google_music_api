module GoogleMusicApi
  #Keeps all the genre-related methods
  module Genre
    #Returns all genres or all subgenres if parent_id is passed
    # @param [String] parent_id
    # @return [Array] of hashes that describe a genre
    # @example Get all the subgenres of Jazz
    # mobile_client.get_genres('JAZZ')
    def get_genres(parent_id = nil)
      url = 'explore/genres'

      options = {}
      options[:query] = {'parent-genre': parent_id} if parent_id

      make_get_request(url, options)['genres']
    end
  end
end
