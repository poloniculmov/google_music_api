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

  end
end