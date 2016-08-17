require 'spec_helper'
describe GoogleMusicApi::MobileClient do
  let(:api) { GoogleMusicApi::MobileClient.new }
  describe '#authenticated?' do
    it 'returns true if authentication token is set' do
      api.instance_variable_set '@authorization_token', 'abc'

      expect(api.authenticated?).to be_truthy
    end

    it 'returns false if authentication token is not set' do
      api.instance_variable_set '@authorization_token', nil

      expect(api.authenticated?).to be_falsey
    end
  end

  describe '#login' do
    it 'throws an exception if authorization fails' do
      allow_any_instance_of(Gpsoauth::Client).to receive(:master_login).and_return({Token: 'a'})
      allow_any_instance_of(Gpsoauth::Client).to receive(:oauth).and_return({Error: 'BadAuthentication'})

      expect{api.login('email@example.com', 'apassword', '1234567890ABCDEF')}.to raise_error GoogleMusicApi::AuthenticationError
    end

    it 'authenticates the api if it succeeds' do
      allow_any_instance_of(Gpsoauth::Client).to receive(:master_login).and_return({Token: 'a'})
      allow_any_instance_of(Gpsoauth::Client).to receive(:oauth).and_return({'Auth' => 'some ok token'})

      expect(api.login('email@example.com', 'apassword', '1234567890ABCDEF')).to be_truthy

      expect(api.authenticated?).to be_truthy
    end
  end
end
