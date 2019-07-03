import React, { Component } from 'react';

import createChannel from '@/utils/cable';

import RoomItem from './RoomItem';

class RoomsList extends Component {
  constructor(props) {
    super(props);

    this.state = {
      currentUserId: props.data.current_user.id,
      currentUserActivity: props.data.current_user.rooms_activity,
      rooms: props.data.rooms,
      filteredRooms: props.data.rooms,
      searchValue: '',
    };

    this.appSubscription = createChannel(
      {
        channel: 'AppChannel',
      },
      {
        received: this.handleChannelResponse,
      },
    );

    this.userSubscription = createChannel(
      {
        channel: 'UserChannel',
      },
      {
        received: this.handleChannelResponse,
      },
    );
  }

  filterRooms = () => {
    const { searchValue, rooms } = this.state;
    let filteredRooms;

    if (searchValue.length > 0) {
      filteredRooms = rooms.filter(room => room.name.toLowerCase().indexOf(searchValue.toLowerCase()) > -1);
    } else {
      filteredRooms = [...rooms];
    }

    this.setState({ filteredRooms });
  }

  handleChannelResponse = (response) => {
    switch (response.type) {
      case 'room_create':
      case 'room_open':
        this.handleNewRoom(response.data);
        break;
      case 'room_update':
        this.handleUpdatedRoom(response.data);
        break;
      case 'room_close':
        this.handleClosedRoom(response.data);
        break;
      default:
        break;
    }
  }

  handleNewRoom = (room) => {
    const sortedRooms = _.orderBy([...this.state.rooms, room], [r => r.name.toLowerCase()], ['asc']);
    this.setState({ rooms: _.uniqBy(sortedRooms, 'id') });
    this.filterRooms();
  }

  handleUpdatedRoom = (room) => {
    const rooms = [...this.state.rooms];
    const index = _.findIndex(rooms, { id: room.id });

    rooms.splice(index, 1, room);

    const sortedRooms = _.orderBy(rooms, [r => r.name.toLowerCase()], ['asc']);
    this.setState({ rooms: sortedRooms });
    this.filterRooms();
  }

  handleClosedRoom = (room) => {
    const rooms = [...this.state.rooms];
    const index = _.findIndex(rooms, { id: room.id });

    rooms.splice(index, 1);

    this.setState({ rooms });
    this.filterRooms();
  }

  handleSearch = async (e) => {
    await this.setState({ searchValue: e.target.value });
    this.filterRooms();
  }

  render() {
    const {
      filteredRooms,
      currentUserId,
      searchValue,
      currentUserActivity,
    } = this.state;

    return (
      <div className="rooms">
        <div className="rooms__search py-2">
          <input
            value={searchValue}
            className="form-control"
            type="text"
            placeholder="Search..."
            onChange={this.handleSearch}
          />
        </div>

        <div className="rooms__list mb-2">
          {filteredRooms.map(room => (
            <RoomItem
              key={room.id}
              room={room}
              currentUserId={currentUserId}
              lastActivity={currentUserActivity[room.id]}
            />
          ))}
        </div>
      </div>
    );
  }
}

export default RoomsList;
