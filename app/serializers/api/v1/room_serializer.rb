module Api
  module V1
    class RoomSerializer < Blueprinter::Base
      identifier :id

      fields :name, :channel_name, :public, :user_id

      field :room_path do |room, _options|
        Rails.application.routes.url_helpers.room_path(room)
      end
    end
  end
end