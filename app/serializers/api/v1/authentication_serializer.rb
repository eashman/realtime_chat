module Api
  module V1
    class AuthenticationSerializer < Blueprinter::Base
      identifier :id

      view :auth do
        fields :email, :authentication_token, :refresh_token
      end

      view :refresh do
        fields :refresh_token
      end
    end
  end
end