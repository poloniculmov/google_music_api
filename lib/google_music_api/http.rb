module GoogleMusicApi
  module Http

    private
    def make_get_request(url, options = {})
      url ="#{self.class::SERVICE_ENDPOINT}#{url}"
      if options[:headers] == nil
        options[:headers] = {}
      end
      options[:headers]['Authorization'] = 'GoogleLogin auth='+authorization_token
      HTTParty.get(url, options).parsed_response
    end

    def make_play_request(url, options = {})
      url ="#{self.class::STREAM_ENDPOINT}#{url}"
      if options[:headers] == nil
        options[:headers] = {}
      end
      options[:headers]['Authorization'] = 'GoogleLogin auth='+authorization_token
      options[:follow_redirects] = false
      HTTParty.get(url, options).headers['location']
    end

    def make_post_request(url, options = {})
      url ="#{self.class::SERVICE_ENDPOINT}#{url}"
      if options[:headers] == nil
        options[:headers] = {}
      end
      options[:headers]['Authorization']= 'GoogleLogin auth='+authorization_token
      options[:headers]['Content-Type']= 'application/json'
      HTTParty.post(url, options).parsed_response
    end

  end
end
