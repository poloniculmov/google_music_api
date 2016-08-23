module GoogleMusicApi
  #Holds all the playlist related methods
  module Playlist

    #Gets all the playlists that user has
    #@return [Array] of Hashes that describe a playlist
    def get_all_playlists
      url = 'playlistfeed'

      make_post_request(url).fetch('data', {'items' => []})['items']
    end

    #Gets all the tracks in the user's own playlists. Doesn't include subscribed playlists. If you want to get the tracks of a single playlist, use
    # {get_shared_playlists_entries}
    #@return [Array] of hashes describing playlist entries. Each Playlist entry will have the playlist's id and the track description
    def get_own_playlists_entries
      url = 'plentryfeed'

      make_post_request(url).fetch('data', {'items' => []})['items']
    end


    #Gets all the playlist entries of a playlist that user is subscribed to
    #@return [Array] of describing playlist entries
    # @param [String] share_token - this is not the playlist's id, but the share_token
    # @example get_shared_playlists_entries 'AMaBXykmxW9ZMK3C7WvoLKDw8AQB00UNiHXEwWwFRZ8lGc9yfb-SFI6nmj6t-IZKE5AvKFlVSzmU2wmQ2j0e3RqCJe4ytpBAMQ=='
    def get_shared_playlists_entries(share_token)
      url = 'plentries/shared'

      options = {body: {entries: [{
                                      shareToken: share_token
                                  }]
      }.to_json
      }

      make_post_request(url, options)
    end


    #Creates a playlist
    # @param [String] name
    # @param [String] description, default = ''
    # @param [boolean] public, default = false
    # @return [Hash] with the API response, status is in the 'response_code' key
    def create_playlist(name, description = '', public = false)
      create_playlists [{name: name, description: description, public: public}][0]
    end

    #Batch creates playlists
    # @param [Array] playlist_descriptions, consists of one or more hashes with the keys :name, :description and :public
    # @return [Array] of hashes with the result of each creation operation
    def create_playlists(playlist_descriptions = [])
      url = 'playlistbatch'

      creates = playlist_descriptions.map do |pd|
        {
            create: {
                creationTimestamp: '-1',
                deleted: false,
                lastModifiedTimestamp: '0',
                name: pd[:name],
                description: pd.fetch(:description, ''),
                type: 'USER_GENERATED',
                shareState: (pd.fetch(:public, false) ? 'PUBLIC' : 'PRIVATE')
            }
        }
      end

      options = {
          body: {mutations: creates}.to_json
      }
      make_post_request(url, options).fetch('mutate_response')
    end

    # Updates a single playlist
    # @param [string] id, the actual id, not the share token
    # @param [string] new_name
    # @param [string] new_description
    # @param [boolean] new_public
    # @return [Hash] with the API response, status is in the 'response_code' key
    def update_playlist(id, new_name = nil, new_description = nil, new_public = nil)
      update_playlists [{id: id, name: new_name, description: new_description, public: new_public}][0]
    end

    # Batch updates one or more playlists
    # @param [Array] playlist_descriptions, consists of one or more hashes with the keys id:, :name, :description and :public
    # @return [Array] of hashes with the result of each creation operation
    def update_playlists(playlist_descriptions)
      url = 'playlistbatch'

      updates = playlist_descriptions.map do |pd|
        {
            update: {
                id: pd[:id],
                name: pd[:name],
                description: pd[:description],
                shareState: (pd[:public] ? 'PUBLIC' : 'PRIVATE')
            }
        }
      end

      options = {
          body: {mutations: updates}.to_json
      }

      make_post_request(url, options).fetch('mutate_response')
    end

    #Deletes a playlist
    # @param [string] id
    # @return [Hash] with the API response, status is in the 'response_code' key
    def delete_playlist(id)
      delete_playlists([id])[0]
    end

    # Batch deletes one or more playlists
    # @return [Array] of hashes with the result of each creation operation
    # @param [Array] ids
    def delete_playlists(ids = [])
      url = 'playlistbatch'

      deletes = ids.map do |pd|
        {
            delete: pd
        }
      end

      options = {
          body: {mutations: deletes}.to_json
      }

      make_post_request(url, options).fetch('mutate_response')
    end

    # Adds tracks to a playlist
    # @param [string] playlist_id
    # @param [array] track_ids
    def add_tracks_to_playlist(playlist_id, track_ids)
      url = 'plentriesbatch'
      options = {}


      prev_id, cur_id, next_id = nil, SecureRandom.uuid, SecureRandom.uuid

      mutations = []
      track_ids.each_with_index do |value, index|
        m_details = {
            clientId: cur_id,
            creationTimestamp: '-1',
            deleted: false,
            lastModifiedTimestamp: '0',
            playlistId: playlist_id,
            source: 1,
            trackId: value,
        }

        m_details[:source] = 2 if value[0] == 'T'

        m_details[:precedingEntryId] = prev_id if index > 0

        m_details[:followingEntryId] = next_id if index < value.length - 1

        mutations << {create: m_details}

        prev_id, cur_id, next_id = cur_id, next_id, SecureRandom.uuid
      end


      options[:body] = {mutations: mutations}.to_json

      make_post_request(url, options)
    end


    #Batch removes track from playlists. You can send playlist entries of multiple playlists
    # @param [Array] playlist_entry_ids These are playlist entries, not track ids
    def remove_tracks_from_playlist(playlist_entry_ids)
      url = 'plentriesbatch'

      mutations = playlist_entry_ids.map { |id| {delete: id}}
      options = {
          body: {
              mutations: mutations
          }.to_json
      }

      make_post_request url, options
    end

    def reorder_playlist_entry
      throw NotImplementedError.new
    end

    protected

    def add_track_type(track_id)
      if track_id[0] == 'T'
        {'id': track_id, 'type': 1}
      else
        {'id': track_id, 'type': 0}
      end
    end

  end
end