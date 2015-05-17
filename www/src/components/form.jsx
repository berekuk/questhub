import React from 'react';

import {Well} from 'components/layout';

export const Form = React.createClass({
  render () {
    return (
      <form>
        <Well {...this.props}/>
      </form>
    );
  },
});

export const Row = React.createClass({
  render () {
    return (
      <div className='form-row'>
        {this.props.children}
      </div>
    );
  },
});

export const Label = React.createClass({
  render () {
    return (
      <label>
        <small className='muted'>{this.props.children}</small>
      </label>
    );
  },
});
