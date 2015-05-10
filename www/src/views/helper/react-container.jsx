import _ from 'underscore';
import Base from 'views/proto/base';
import React from 'react';

export default class extends Base {
  constructor (props) {
    super(props);
    this.template = _.template("<div></div>");
    this.isReactComponent = true;
  }

  render () {
    React.render(this.options.component, this.$el[0]);
  }

  remove () {
    React.unmountComponentAtNode(this.$el[0]);
    super.remove();
  }
};
