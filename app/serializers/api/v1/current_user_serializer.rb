# frozen_string_literal: true

module Api
  module V1
    class CurrentUserSerializer < Blueprinter::Base
      identifier :id

      fields :username, :email, :rooms_activity

      field :avatar_url do |user, _options|
        user.avatar.thumb.url
      end
    end
  end
end
