module GoogleMusicApi
  module Http

    private

    def make_get_request(url, options = {})
      url ="#{self.class::SERVICE_ENDPOINT}#{url}"
      options[:headers] = {'Authorization': 'GoogleLogin auth='+authorization_token}
      HTTParty.get(url, options).parsed_response
    end

    def make_post_request(url, options = {})
      url ="#{self.class::SERVICE_ENDPOINT}#{url}"
      options[:headers] = {'Authorization': 'GoogleLogin auth='+authorization_token, 'Content-Type': 'application/json'}
      HTTParty.post(url, options).parsed_response
    end

  end
end