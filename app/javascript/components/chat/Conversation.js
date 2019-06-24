import React, { Component } from 'react';

import ConversationItem from './ConversationItem';

class Conversation extends Component {
  componentDidMount() {
    this.scrollToBottom();
  }
  
  componentDidUpdate() {
    this.scrollToBottom();
  }

  renderTypingMessage = () => {
    const typers = _.map(this.props.typers, 'username')

    let result;

    switch (typers.length) {
      case 0:
        result = ''
        break;
      case 1:
        result = `${typers[0]} is typing ...`
        break;
      case 2:
          result = `${typers.join(' and ')} are typing ...`
          break;
      default:
        const othersCount = typers.length - 1
        result = `${typers[0]} and ${othersCount} other people are typing ...`
    }

    return <span>{result}</span>;
  }

  scrollToBottom = () => {
    this.messagesEnd.scrollIntoView();
  }

  render() {
    const { messages, currentUserId } = this.props;

    return (
      <div className="conversation">
        <div className="conversation__content">
          {messages.length > 0 ? messages.map(message => (
            <ConversationItem key={message.id} message={message} currentUserId={currentUserId} />
          )) : (
            <p>There are no messages</p>
          )}

          <div ref={el => this.messagesEnd = el} />
        </div>

        <div className="conversation__typers">
          {this.renderTypingMessage()}
        </div>
      </div>
    )
  }
}

export default Conversation;