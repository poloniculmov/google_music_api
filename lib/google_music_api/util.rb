require "base64"
require 'openssl'
module GoogleMusicApi
  module Util

    # Gets the radio seed type for a particular id
    # @param [string] id
    # @return [string] Type name
    def get_seed_type_from_id(id)
      case id.chars[0]
      when 'T'
        '2'
      when 'B'
        '1'
      when 'A'
        '3'
      when 'L'
        '9'
      else
        '6'
      end
    end

    # Gets the id type based on the ID format
    # TODO: This list is incomplete
    # @param [string] id
    # @return [string] Type name
    def get_typename_from_id(id)
      case id.chars[0]
      when 'T'
        'trackId'
      when 'A'
        'artistId'
      when 'B'
        'albumId'
      when 'L'
        'curatedStationId'
      else
        'stationId'
      end
    end

    # Gets the key used for signing urls
    # @return [string] key
    def get_key
      @key = Base64.decode64('MzRlZTc5ODMtNWVlNi00MTQ3LWFhODYtNDQzZWEwNjJhYmY3NzQ0OTNkNmEtMmExNS00M2ZlLWFhY2UtZTc4NTY2OTI3NTg1Cg==')
    end

    # This method returns components required for url signing.
    # @param [string] key
    # @param [string] salt - Optional
    # @return [string,string] signature, salt
    def get_signature(data, salt=nil)
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
