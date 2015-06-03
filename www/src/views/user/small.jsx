import _ from 'underscore';
import React from 'react';

import currentUserModel from 'models/current-user';
import {User, UpicSmall, Reward} from 'components/partials';
import RouterMap from 'router-map';

export default React.createClass({
  propTypes: {
    model: React.PropTypes.object.isRequired,
    realm: React.PropTypes.string.isRequired,
  },

  isCurrent () {
    const currentUser = currentUserModel.get('login');
    return (
      currentUser
      && this.props.model.get('login') == currentUser
    );
  },

  login () {
    return this.props.model.get('login');
  },

  points () {
    return this.props.model.get('rp')[this.props.realm];
  },

  renderLeaderboardTooltip () {
    if (!this.isCurrent()) {
      return;
    }
    // Bootstrap 2.3.0 tries to line up the text vertically, so we have to use &nbsp;
    return (
      <div className='current-user-leaderboard-tip'>
        <span data-toggle='tooltip' data-trigger='manual' data-placement='right' title='This&nbsp;is&nbsp;you.&nbsp;Climb&nbsp;up!'></span>
      </div>
    );
  },

  renderOpenQuests () {
    const openQuests = this.props.model.get('open_quests');
    if (!openQuests) {
      return;
    }

    const line = `${openQuests} open quest${openQuests > 1 ? 's' : ''}`;

    return (
      <span className='user-small-quests'>
        <a href={RouterMap.player(this.login())}>
          {line}
        </a>
      </span>
    );
  },

  render () {
    let cs = 'user-small-inner';
    if (this.isCurrent()) {
      cs += ' user-small-current';
    }
    return (
      <div className={cs}>
        <span className='user-small-points'>
          <Reward size='small' points={this.points()}/>
        </span>
        <UpicSmall login={this.login()}/>
        <User login={this.login()}/>

        {this.renderLeaderboardTooltip()}
        {this.renderOpenQuests()}
      </div>
    );
  },
});
