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


    private

    def authorization_token
      @authorization_token
    end

    def make_get_request(url, options)
      url ="#{SERVICE_ENDPOINT}#{url}"
      options[:headers] = {'Authorization': 'GoogleLogin auth='+authorization_token}
      HTTParty.get(url, options).parsed_response
    end

  end
end