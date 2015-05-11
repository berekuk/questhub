import _ from 'underscore';
import Backbone from 'backbone';
import React from 'react';

export default class extends Backbone.View {
  constructor (component, props={}, children=[]) {
    super();
    this.component = component;
    this.props = props;
    this.children = children;
    this.isReactComponent = true;
  }

  setProp (prop, value) {
    this.props[prop] = value;
    this.render();
  }

  render () {
    React.render(React.createElement(this.component, this.props, this.children), this.$el[0]);
  }

  remove () {
    React.unmountComponentAtNode(this.$el[0]);
    super.remove();
  }
};
