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
      options = { query: {dv: 0} }

      subscribed = make_get_request(url, options)['data']['entries'].find do |item|
        item['key'] == 'isNautilusUser' && item['value'] == 'true'
      end

      !subscribed.nil?
    end

    private

    def authorization_token
      @authorization_token
    end

    def make_get_request(url, options)
      url ="#{SERVICE_ENDPOINT}#{url}"
      options[:headers] = { 'Authorization': 'GoogleLogin auth='+authorization_token}
      HTTParty.get(url, options).parsed_response
    end

  end
end