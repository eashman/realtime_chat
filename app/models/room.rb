# frozen_string_literal: true

class Room < ApplicationRecord
  include Discard::Model

  belongs_to :user
  has_many :messages, class_name: 'RoomMessage', dependent: :destroy
  has_many :rooms_users, dependent: :destroy
  has_many :users, through: :rooms_users, dependent: :destroy

  # Validations
  validates :name, presence: true

  def channel_name
    [RoomChannel.channel_name, to_gid_param].join(':')
  end

  def serialized
    Api::V1::RoomSerializer.render_as_hash(self)
  end
end
