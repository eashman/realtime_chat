# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoomsController, type: :controller do
  let(:user) { create(:user_with_rooms) }

  describe '#index' do
    context 'unauthorized' do
      it 'expects to respond with error' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to render view' do
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end

  describe '#show' do
    let(:room) { user.rooms.first }

    context 'unauthorized' do
      it 'expects to respond with error' do
        get :show, params: { id: room.id }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to render view' do
        get :show, params: { id: room.id }
        expect(response).to have_http_status(200)
      end
    end
  end

  describe '#new' do
    context 'unauthorized' do
      it 'expects to respond with error' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to render view' do
        get :new
        expect(response).to have_http_status(200)
      end
    end
  end

  describe '#create' do
    let(:room_params) { { room: attributes_for(:room) } }

    context 'unauthorized' do
      it 'expects to respond with error' do
        post :create, params: room_params
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to create new room' do
        expect do
          post :create, params: room_params
        end.to(change { Room.count }.by(1))

        expect(response).to redirect_to rooms_path
      end

      it 'expects to respond with error due to invalid params' do
        expect do
          post :create, params: { room: { name: '' } }
        end.not_to(change { Room.count })

        expect(response).to render_template 'new'
      end

      it 'expects to broadcast new room from AppChannel' do
        expect do
          post :create, params: room_params
        end.to have_broadcasted_to(:app).from_channel(AppChannel)
      end

      it 'expects to broadcast new private room from UserChanel' do
        participant = create(:user)

        expect do
          post :create, params: { room: attributes_for(:room, public: false), users_ids: participant.id.to_s }
        end.to have_broadcasted_to(participant).from_channel(UserChannel)
      end
    end
  end

  describe '#edit' do
    let(:room) { user.rooms.first }

    context 'unauthorized' do
      it 'expects to respond with error' do
        get :edit, params: { id: room.id }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to render view' do
        get :edit, params: { id: room.id }
        expect(response).to have_http_status(200)
      end

      it 'expects to raise unauthorized for foreign room' do
        other_room = create(:room)

        expect do
          get :edit, params: { id: other_room.id }
        end.to(raise_exception(Pundit::NotAuthorizedError))
      end
    end
  end

  describe '#update' do
    let(:room) { user.rooms.first }
    let(:private_room) { create(:room_with_participants, user: user) }

    context 'unauthorized' do
      it 'expects to respond with error' do
        put :update, params: { id: room.id, room: { name: 'New name' } }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to change room name' do
        expect do
          put :update, params: { id: room.id, room: { name: 'New name' } }
        end.to(change { room.reload.name }.to('New name'))

        expect(response).to redirect_to rooms_path
      end

      it 'expects to respond with error due to invalid params' do
        expect do
          put :update, params: { id: room.id, room: { name: '' } }
        end.not_to(change { room.reload.name })

        expect(response).to render_template 'edit'
      end

      it 'expects to raise not_found for foreign room' do
        other_room = create(:room)

        expect do
          put :update, params: { id: other_room.id, room: { name: 'New name' } }
        end.to(raise_exception(Pundit::NotAuthorizedError))
      end

      it 'expects to broadcast updated room from AppChannel' do
        expect do
          put :update, params: { id: room.id, room: { name: 'New name' } }
        end.to have_broadcasted_to(:app).from_channel(AppChannel)
      end

      it 'expects to broadcast updated room from UserChannel' do
        expect do
          put :update, params: { id: private_room.id, room: { name: 'New name' } }
        end.to have_broadcasted_to(private_room.users.last).from_channel(UserChannel)
      end
    end
  end

  describe '#destroy' do
    let(:room) { user.rooms.first }

    context 'unauthorized' do
      it 'expects to respond with error' do
        delete :destroy, params: { id: room.id }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to discard room' do
        expect do
          delete :destroy, params: { id: room.id }
        end.to(change { Room.kept.count }.by(-1))

        expect(response).to redirect_to rooms_path
      end

      it 'expects to raise not_found for foreign room' do
        other_room = create(:room)

        expect do
          delete :destroy, params: { id: other_room.id }
        end.to(raise_exception(Pundit::NotAuthorizedError))
      end

      it 'expects to broadcast discarded room' do
        expect do
          delete :destroy, params: { id: room.id }
        end.to have_broadcasted_to(:app).from_channel(AppChannel)
      end
    end
  end

  describe '#update_activity' do
    let!(:room) { create(:room, user: user) }

    context 'unauthorized' do
      it 'expects to respond with error' do
        post :update_activity, params: { id: room.id }, as: :json
        expect(response).to have_http_status 401
      end
    end

    context 'authorized' do
      before(:each) { sign_in user }

      it 'expects to update room activity' do
        allow(subject.current_user).to receive(:update_room_activity).with(room)
        post :update_activity, params: { id: room.id }, as: :json

        expect(subject.current_user).to have_received(:update_room_activity).with(room)
        expect(response).to have_http_status 204
      end
    end
  end
end
