import React from 'react';

import RouterMap from 'router-map';

export const Reward = React.createClass({
  propTypes: {
    size: React.PropTypes.string.isRequired,
    status: React.PropTypes.string,
    plus: React.PropTypes.bool,
    points: React.PropTypes.number.isRequired,
  },

  renderIcon () {
    if (this.props.size && this.props.size == 'small') {
      return <i className='icon-star'></i>;
    }
    else {
      return (
        <span className='icon-stack' data-toggle='tooltip' title='Reward&nbsp;points'>
          <i className='icon-circle icon-stack-base'></i>
          <i className='icon-star icon-light'></i>
        </span>
      );
    }
  },

  render () {
    let cs = this.props.size ? 'reward-' + this.props.size : 'reward';
    if (this.props.status) {
      cs += 'reward-status-' + this.props.status;
    }
    return (
      <div className={cs}>
        <span className='reward-points'>{this.props.points}</span>
        {' '}
        {this.renderIcon()}
      </div>
    );
  },
});

export const User = React.createClass({
  propTypes: {
    login: React.PropTypes.string.isRequired,
    colon: React.PropTypes.bool,
  },

  render () {
    let text = this.props.login;
    if (this.props.colon) text += ':';

    return (
      <a href={RouterMap.player(this.props.login)} className='user-link'>
        {text}
      </a>
    );
  },
});

export const UpicSmall = React.createClass({
  propTypes: {
    login: React.PropTypes.string.isRequired,
  },

  render () {
    return (
      <a href={RouterMap.player(this.props.login)}>
        <img
          src={RouterMap.upic(this.props.login, 'small')}
          alt={this.props.login}
          title={this.props.login}
          className='upic-small'
        />
      </a>
    );
  },
});
