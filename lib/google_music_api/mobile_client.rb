require 'gpsoauth'

module GoogleMusicApi
  class MobileClient

    SERVICE = 'sj'
    APP = 'com.google.android.music'
    CLIENT_SIGNATURE = '38918a453d07199354f8b19af05ec6562ced5788'

    SERVICE_ENDPOINT = 'https://mclients.googleapis.com/sj/v2.4/'


    def login(email, password)

      g = Gpsoauth::Client.new('123das7809ffabde', 'ac2dm', 'ro', 'ro')
      response = g.master_login(email, password)
      oauth_response = g.oauth(email, response["Token"], SERVICE, APP, CLIENT_SIGNATURE)

      @authorization_token = oauth_response["Auth"]

      true
    end

    def is_subscribed?
      url = 'config'
      options = {query: {dv: 0}}

      subscribed = make_get_request(url, options)['data']['entries'].find do |item|
        item['key'] == 'isNautilusUser' && item['value'] == 'true'
      end

      !subscribed.nil?
    end

    def get_genres(parent_id = nil)
      url = 'explore/genres'

      options = {}
      options[:query] = {'parent-genre': parent_id} if parent_id


      make_get_request(url, options)['genres']
    end

    def search(query, max_results: 50)
      url = 'query'

      # The result types returned are requested in the `ct` parameter.
      # Free account search is restricted so may not contain hits for all result types.
      # 1: Song, 2: Artist, 3: Album, 4: Playlist, 6: Station, 7: Situation, 8: Video

      options = {
          query: {
              'ct': '1,2,3,4,6,7,8',
              'q': query,
              'max-results': max_results
          }
      }

      make_get_request(url, options)['entries']
    end

    def get_all_tracks
      url = 'trackfeed'

      make_post_request(url)
    end

    def get_all_playlists
      url = 'playlistfeed'

      make_post_request(url)
    end

    def get_own_playlists_entries
      url = 'plentryfeed'

      make_post_request(url)
    end

    def get_shared_playlists_entries(share_token)
      url = 'plentries/shared'

      options = {body: {entries: [{
                                      shareToken: share_token
                                  }]
      }.to_json
      }
      make_post_request(url, options)
    end

    def get_promoted_songs
      url = 'ephemeral/top'

      make_post_request(url)
    end

    def get_listen_now_items
      url = 'listennow/getlistennowitems'
      options = {'alt': 'json'}

      make_get_request(url)
    end

    def get_listen_now_situations()
      url = 'listennow/situations'
      options = {query: {'alt': 'json', 'tier': 'aa', 'hl': 'en_US'}}

      body = {'requestSignals': {'timeZoneOffsetSecs': Time.now.gmt_offset}}.to_json

      options[:body] = body
      make_post_request(url, options)
    end

    def get_all_stations
      url = 'radio/station'
      options = {query: {'alt': 'json', 'tier': 'aa', 'hl': 'en_US'}}

      make_post_request(url, options)
    end

    def get_station_tracks(station_id, number_of_tracks: 25, recently_played: [])
      url = 'radio/stationfeed'
      options = {query: {'alt': 'json', 'include-tracks': 'true', 'tier': 'aa', 'hl': 'en_US'}}

      options[:body] = {'contentFilter': 1,
                        'stations': [
                            {
                                'numEntries': number_of_tracks,
                                'radioId': station_id,
                                'recentlyPlayed': recently_played.map { |rec| add_track_type rec }
                            }
                        ]}.to_json

      make_post_request(url, options)
    end

    def get_im_feeling_lucky_tracks(number_of_tracks: 25, recently_played: [])
      get_station_tracks 'IFL', number_of_tracks: number_of_tracks, recently_played: recently_played
    end

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

    def get_track_info(track_id)
      url = 'fetchtrack'

      options = {
          query: {
              nid: track_id
          }
      }

      make_get_request url, options
    end


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

    def add_tracks_to_library(song_ids = [])
      #TODO: Implement after adding Hashie support as this needs an extra call
      url = 'trackbatch'

      throw NotImplementedError.new
    end

    def create_playlist(name, description = '', public = false)
      create_playlists [{name: name, description: description, public: public}]
    end

    def create_playlists(playlist_descriptions = [])
      url = 'playlistbatch'

      creates = playlist_descriptions.map do |pd|
        {
            create: {
                creationTimestamp: '-1',
                deleted: false,
                lastModifiedTimestamp: '0',
                name: pd[:name],
                description: pd[:description],
                type: 'USER_GENERATED',
                shareState: (pd[:public] ? 'PUBLIC' : 'PRIVATE')
            }
        }
      end

      options = {
          body: {mutations: creates}.to_json
      }
      make_post_request(url, options)
    end

    # It should be the actual id, not the share token.
    def update_playlist(id, new_name = nil, new_description = nil, new_public = nil)
      update_playlists [{id: id, name: new_name, description: new_description, public: new_public}]
    end

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

      make_post_request(url, options)
    end

    def delete_playlist(id)
      delete_playlists [id]
    end

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

      make_post_request(url, options)

    end

    # It should be the actual id, not the share token.
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


    #it has to be a playlist entry id, not a track id
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

    def create_station
      throw NotImplementedError.new
    end

    def delete_station
      throw NotImplementedError.new
    end



    private

    def authorization_token
      @authorization_token
    end

    def make_get_request(url, options = {})
      url ="#{SERVICE_ENDPOINT}#{url}"
      options[:headers] = {'Authorization': 'GoogleLogin auth='+authorization_token}
      HTTParty.get(url, options).parsed_response
    end

    def make_post_request(url, options = {})
      url ="#{SERVICE_ENDPOINT}#{url}"
      options[:headers] = {'Authorization': 'GoogleLogin auth='+authorization_token, 'Content-Type': 'application/json'}
      HTTParty.post(url, options).parsed_response
    end

    def add_track_type(track_id)
      if track_id[0] == 'T'
        {'id': track_id, 'type': 1}
      else
        {'id': track_id, 'type': 0}
      end
    end

  end
end