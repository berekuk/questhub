import React from 'react';

export const Sidebar = React.createClass({
  propTypes: {
    desktopOnly: React.PropTypes.bool,
  },

  render () {
    let cs = 'sidebar';
    if (this.props.desktopOnly) {
      cs += ' desktop-block';
    }
    return (
      <div className={cs}>
        {this.props.children}
      </div>
    );
  },
});

export const Mainarea = React.createClass({
  render () {
    return (
      <div className='mainarea'>
        {this.props.children}
      </div>
    );
  },
});

export const Well = React.createClass({
  render () {
    return (
      <div className='well'>
        {this.props.children}
      </div>
    );
  },
});
