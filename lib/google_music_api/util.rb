require "base64"
require 'openssl'
module GoogleMusicApi
  module Util

    def get_key
      @key = Base64.decode64('MzRlZTc5ODMtNWVlNi00MTQ3LWFhODYtNDQzZWEwNjJhYmY3NzQ0OTNkNmEtMmExNS00M2ZlLWFhY2UtZTc4NTY2OTI3NTg1Cg==')
    end

    def get_signature( data, salt=nil)
      if salt == nil
        salt = (Time.now.to_i * 1000).to_s
      end

      hmac = OpenSSL::HMAC.new(get_key,OpenSSL::Digest.new('sha1'))
      hmac << data.force_encoding("utf-8")
      hmac << salt.force_encoding("utf-8")
      sig = Base64.urlsafe_encode64(hmac.digest).chop

      return sig,salt
    end
  end
end
