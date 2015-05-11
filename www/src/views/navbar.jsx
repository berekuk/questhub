import React from 'react';
import currentUserModel from 'models/current-user';
import Backbone from 'backbone';
import NotificationsBoxView from 'views/user/notifications-box';

const linkClassName = (isActive) => {
  let cs = 'navbar-link';
  if (isActive) {
    cs += ' navbar-link--active';
  }
  return cs;
};

const Iconed = React.createClass({
  propTypes: {
    icon: React.PropTypes.string.isRequired,
  },

  render () {
    return (
      <span>
        <i className={`icon-${this.props.icon}`}></i>
        {' '}
        {this.props.children}
      </span>
    );
  },
});

const MenuItem = React.createClass({
  propTypes: {
    href: React.PropTypes.string.isRequired,
    icon: React.PropTypes.string.isRequired,
    text: React.PropTypes.string.isRequired,
    isActive: React.PropTypes.bool,
  },

  render () {
    return (
      <a href={this.props.href} className={linkClassName(this.props.isActive)}>
        <Iconed icon={this.props.icon}>
          <span className='desktop-text'>
            {this.props.text}
          </span>
        </Iconed>
      </a>
    );
  },
});

const Brand = React.createClass({
  propTypes: {
    isActive: React.PropTypes.bool,
    registered: React.PropTypes.bool,
  },

  render () {
    let inner;
    if (this.props.registered) {
      inner = <i className='icon-rss'></i>
    }
    else {
      inner = <span className='mobile-text'>QH</span>
    }

    return (
      <a className={'brand ' + linkClassName(this.props.isActive)} href='/'>
        {inner}
        {' '}
        <span className='desktop-text'>Questhub.io</span>
      </a>
    );
  },
});

const SearchBox = React.createClass({
  getInitialState () {
    return {
      value: '',
    };
  },

  handleChange (e) {
    this.setState({value: e.target.value});
  },

  doSearch () {
    Backbone.history.navigate(`/search?q=${encodeURIComponent(this.state.value)}`, {trigger: true});
  },

  handleKeyUp (e) {
    if (e.keyCode == 13) {
      this.doSearch();
    }
  },

  render () {
    return (
      <div className='navbar-search'>
        <input
          className='navbar-search__input'
          type='text'
          name='search'
          value={this.state.value}
          onChange={this.handleChange}
          onKeyUp={this.handleKeyUp}
        />
        <a href='#' className='navbar-search__icon' onClick={this.doSearch}>
          <i className='icon-search'></i>
        </a>
      </div>
    );
  },
});

const NewQuest = React.createClass({
  propTypes: {
    isActive: React.PropTypes.bool,
    realm: React.PropTypes.string,
  },

  render () {
    let href = '/quest/add';
    if (this.props.realm) {
      href = `/realm/${this.props.realm}/quest/add`;
    }

    return <MenuItem
      href={href}
      icon='plus'
      text='New quest'
      isActive={this.props.isActive}
    />;
  },
});

const SettingsDropdown = React.createClass({
  propTypes: {
    isActive: React.PropTypes.bool,
  },

  render () {
    return (
      <div className='dropdown'>
        <a href="#" className={'dropdown-toggle ' + linkClassName(this.props.isActive)} data-toggle='dropdown'>
          <i className='icon-cog'></i>
        </a>
        <ul className='dropdown-menu navbar-bootstrap-dropdown'>
          <li>
          <a href='/settings'>
            <Iconed icon='wrench'>Settings</Iconed>
          </a>
          <a href='#' onClick={e => Backbone.trigger('pp:logout')}>
            <Iconed icon='signout'>Logout</Iconed>
          </a>
          </li>
        </ul>
      </div>
    );
  },
});

const NotificationsLink = React.createClass({
  showNotifications () {
    // TODO - protection against duplicates (it was included in the old current-user.coffee)
    const notificationsBox = new NotificationsBoxView({model: currentUserModel});
    notificationsBox.start();
  },

  render () {
    const notifications = currentUserModel.get('notifications');
    if (!notifications || !notifications.length) {
      return <span></span>;
    }

    return (
      <div className='navbar-notifications'>
        <a href='#' className={linkClassName(false)} onClick={this.showNotifications}>
          <i className='icon-envelope-alt icon-large'></i>
        </a>
      </div>
    );
  },
});

const Personal = React.createClass({
  propTypes: {
    realm: React.PropTypes.string,
    active: React.PropTypes.string,
  },

  render () {
    return (
      <div className='navbar-group'>
        <NewQuest
          isActive={this.props.active=='new-quest'}
          realm={this.props.realm}
        />
        <NotificationsLink />
        <SettingsDropdown isActive={this.props.active=='settings'}/>
      </div>
    );
  },
});


const Unsigned = React.createClass({
  render () {
    return (
      <div className='dropdown'>
        <a href='#' className={linkClassName(false)} data-toggle='dropdown'>
          <Iconed icon='signin'>
            <span className='desktop-text'>
              Sign In
            </span>
          </Iconed>
        </a>

        <ul className='dropdown-menu navbar-bootstrap-dropdown'>
          <li>
            <a href='#' onClick={e => Backbone.trigger('pp:login-with-twitter')}>
              with Twitter
            </a>
          </li>
          <li>
            <a href='#' onClick={e => Backbone.trigger('pp:login-with-persona')}>
              with Email
            </a>
          </li>
        </ul>
      </div>
    );
  }
});

export default React.createClass({
  propTypes: {
    realm: React.PropTypes.string,
    active: React.PropTypes.string,
  },

  getInitialState () {
    return {
      sticked: false,
    };
  },

  componentWillMount () {
    window.addEventListener('scroll', this.onScroll);
  },

  componentWillUnmount () {
    window.removeEventListener('scroll', this.onScroll);
  },

  onScroll () {
    console.log(window.scrollY);
    if (window.scrollY > 10) {
      this.setState({sticked: true});
    }
    else {
      this.setState({sticked: false});
    }
  },

  isRegistered () {
    return !!currentUserModel.get('registered');
  },

  renderProfileLink () {
    if (!this.isRegistered()) return;

    const login = currentUserModel.get('login');
    return <MenuItem
      href={`/player/${login}`}
      icon='list-ul'
      text={login}
      isActive={this.props.active == 'my-quests'}
    />;
  },

  renderMenuItems () {
    return <MenuItem
      href='/realms'
      icon='puzzle-piece'
      text='Realms'
      isActive={this.props.active == 'realms'}
    />;
  },

  renderPersonal () {
    if (this.isRegistered()) {
      return (
        <Personal
          active={this.props.active}
          realm={this.props.realm}
        />
      );
    }
    else {
      return <Unsigned/>;
    }
  },

  render () {
    let cs = 'navbar';
    if (this.state.sticked) {
      cs += ' navbar--sticked';
    }

    return (
      <nav className={cs}>
        <div className='navbar__inner'>
          <div className='navbar-group'>
            <Brand
              registered={this.isRegistered()}
              isActive={this.props.active == 'feed'}
            />
            {this.renderProfileLink()}
            {this.renderMenuItems()}
          </div>
          <div className='navbar-group'>
            <SearchBox />
            {' '}
            {this.renderPersonal()}
          </div>
        </div>
      </nav>
    );
  }
});
