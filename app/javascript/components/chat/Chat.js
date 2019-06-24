import React, { Component } from 'react';

import createChannel from '@/utils/cable';

import Conversation from './Conversation';

import { createMessage } from '@/actions/chat'

class Chat extends Component {
  constructor(props) {
    super(props)

    this.state = {
      messages: props.data.messages,
      currentUserId: props.data.current_user_id,
      currentMessage: '',
      typers: []
    }

    this.subscription = createChannel(
      {
        channel: 'RoomChannel',
        room: props.data.room_id
      },
      {
        received: response => {
          if (response.message === 'typing') {
            this.handleTypingAction(response)
          } else if (response.type === 'create') {
            this.handleNewMessage(response.data)
          } else if (response.type === 'update') {
            this.handleUpdatedMessage(response.data)
          }
        },
        userTyping: typing => {
          this.subscription.perform('user_typing', { typing: typing, room_id: props.data.room_id })
        }
      }
    )
  }

  handleMessageChange = e => {
    this.setState({ currentMessage: e.target.value })
  }

  handleNewMessage = data => {
    const messages = [...this.state.messages, data]
    this.setState({ messages })
  }

  handleUpdatedMessage = data => {
    const messages = [...this.state.messages]
    const index = _.findIndex(messages, { id: data.id })

    messages.splice(index, 1, data)
    this.setState({ messages })
  }

  handleTypingAction = data => {
    const typers = _.uniqBy([data.user, ...this.state.typers], 'id')

    if (!data.typing || data.user.id == this.state.currentUserId) {
      const index = typers.indexOf(data.user)
      typers.splice(index, 1)
    }

    this.setState({ typers })
  }

  handleUserTyping = e => {
    this.setState({ currentMessage: e.target.value })
    this.subscription.userTyping(e.target.value != '')
  }

  handleMessageSubmit = e => {
    e.preventDefault()

    if (this.state.currentMessage != '') {
      const params = {
        room_id: this.props.data.room_id,
        body: this.state.currentMessage
      }

      createMessage(params, () => {
        this.setState({ currentMessage: '' })
        this.subscription.userTyping(false)
      })
    }
  }

  render() {
    const {
      messages,
      currentUserId,
      currentMessage,
      typers
    } = this.state;

    return (
      <div className="chat">
        <Conversation
          currentUserId={currentUserId}
          messages={messages}
          typers={typers}
        />

        <form onSubmit={this.handleMessageSubmit} className="message-area">
          <div className="input-group">
            <input
              value={currentMessage}
              onChange={this.handleMessageChange}
              onKeyUp={this.handleUserTyping}
              className="form-control"
            />
            <div className="input-group-append">
              <button type="submit" className="btn btn-primary">Send</button>
            </div>
          </div>
        </form>
      </div>
    )
  }
}

export default Chat;