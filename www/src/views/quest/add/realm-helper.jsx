import _ from 'underscore';
import React from 'react';

export default React.createClass({
  propTypes: {
    model: React.PropTypes.any.isRequired,
  },

  renderStencilsNote () {
    const model = this.props.model;
    const stencils = model.get('stat').stencils;
    if (!stencils) return;

    return (
      <div>
        <span className='label label-important'>New!</span>
        <br/>
        <a href={`/realm/${model.get('id')}/stencils`}>
          Choose a quest from {model.get('stat').stencils} stencils.
        </a>
      </div>
    );
  },

  renderContent () {
    const model = this.props.model;
    if (!model || !model.get('pic')) return;

    return (
      <div>
        <img src={model.get('pic')} className='quest-add-realm-helper--image'/>
        {this.renderStencilsNote()}
      </div>
    );
  },

  render () {
    return (
      <div className='quest-add-realm-helper'>
        {this.renderContent()}
      </div>
    );
  },
});
