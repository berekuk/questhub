import $ from 'jquery';
import React from 'react';

export default React.createClass({
  displayName: 'ElasticInput',

  propTypes: {
    value: React.PropTypes.string,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
    placeholder: React.PropTypes.string,
    minFontSize: React.PropTypes.number,
  },

  getDefaultProps () {
    return {
      minFontSize: 14,
    };
  },

  handleChange (event) {
    this.props.onChange(event.target.value);
  },

  componentDidUpdate () {
    this.optimizeFont();
  },

  optimizeFont () {
    const el = React.findDOMNode(this);
    const elStyle = window.getComputedStyle(el);

    let tester = document.createElement('span');
    tester.style = {
      display: 'block',
      visibility: 'hidden',
      position: 'absolute',
      top: '-1000px',
    };

    ['fontFamily', 'fontSize', 'lineHeight'].forEach(
      prop => { tester.style[prop] = elStyle[prop] }
    );

    document.body.appendChild(tester);

    tester.appendChild(document.createTextNode(el.value));
    window.getComputedStyle(tester); // force recalculation

    if (tester.offsetWidth > el.offsetWidth) {
      let newFontSize = parseInt(elStyle.fontSize) - 1;
      if (newFontSize > this.props.minFontSize) {
        newFontSize += 'px';
        el.style.fontSize = newFontSize;
        el.style.lineHeight = newFontSize;
      }
    }

    document.body.removeChild(tester);
  },

  handleKeyDown (event) {
    if (event.which == 13) {
      this.props.onSubmit();
    }
  },

  focus () {
    React.findDOMNode(this).focus();
  },

  render () {
    return (
      <input
        name='name'
        type='text'
        className='input-large'
        placeholder={this.props.placeholder}
        value={this.props.value}
        onChange={this.handleChange}
        onKeyDown={this.handleKeyDown}
      />
    );
  },
});
