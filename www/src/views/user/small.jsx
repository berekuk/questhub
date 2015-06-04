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

  renderOpenQuests () {
    const openQuests = this.props.model.get('open_quests');
    if (!openQuests) {
      return;
    }

    const line = `${openQuests} open quest${openQuests > 1 ? 's' : ''}`;

    return (
      <span className='user-small__quests'>
        <a href={RouterMap.player(this.login())}>
          {line}
        </a>
      </span>
    );
  },

  render () {
    let cs = 'user-small';
    if (this.isCurrent()) {
      cs += ' user-small--current';
    }
    return (
      <div className={cs}>
        <div className='user-small__left'>
          <div className='user-small__points'>
            <Reward size='small' points={this.points()} />
          </div>
          <UpicSmall login={this.login()} />
          <User login={this.login()} />
        </div>

        {this.renderOpenQuests()}
      </div>
    );
  },
});
