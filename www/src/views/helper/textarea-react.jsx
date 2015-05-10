import $ from 'jquery';
import React from 'react';
import Markdown from 'views/helper/markdown-react';
import Popover from 'views/helper/popover';
import currentUser from 'models/current-user';

import 'jquery-autosize';

// via https://github.com/andreypopp/react-textarea-autosize
const TextareaAutosize = React.createClass({
  componentDidMount () {
    $(React.findDOMNode(this)).autosize({append: '\n'});
  },

  componentWillUnmount () {
    $(React.findDOMNode(this)).trigger('autosize.destroy');
  },

  render () {
    return (
      <textarea {...this.props} disabled={!this.props.enabled}>
        {this.props.children}
      </textarea>
    );
  },
});

const MainArea = React.createClass({
  displayName: 'Textarea.MainArea',

  propTypes: {
    placeholder: React.PropTypes.string,
    preview: React.PropTypes.bool,
    enabled: React.PropTypes.bool,
    onTextChange: React.PropTypes.func,
    onCancel: React.PropTypes.func,
    onSubmit: React.PropTypes.func.isRequired,
  },

  getInitialState () {
    // unlike 'preview', 'help' is an internal state
    return {help: false};
  },

  focus () {
    this.refs.textarea.getDOMNode().focus();
  },

  handleHelpToggle () {
    this.setState({help: !this.state.help});
  },

  repositionPopover () {
    const $el = $(React.findDOMNode(this));
    const target = $el.find('.helper-textarea-show-help');
    const element = $el.find('.popover');

    const attachPoint = {
      left: target.offset().left + target.width() / 2,
      top: target.offset().top,
    };

    const auxOffset = {left: -2, top: -11};

    element.offset({
      left: attachPoint.left - element.width() / 2 + auxOffset.left,
      top: attachPoint.top - element.height() + auxOffset.top,
    });
  },

  componentDidUpdate () {
    if (this.state.help) {
      this.repositionPopover();
      $('body').on('click', this.hideHelp);
    }
    else {
      $('body').off('click', this.hideHelp);
    }
  },

  hideHelp () {
    if (!this.state.help) return;

    this.setState({help: false});
  },

  handleKeyDown (event) {
    if (event.ctrlKey && (event.which == 13 || event.which == 10)) {
      this.props.onSubmit();
    }
    else if (event.which == 27) {
      if (this.props.onCancel) this.props.onCancel();
    }
  },

  renderPopover () {
    if (!this.state.help) return null;

    return (
      <Popover
        placement='top'
        title='Formatting cheat sheet'
      >
        <div className='helper-textarea-cheatsheet'>
          <code>*Italic*</code><br/>
          <code>**Bold**</code><br/>
          <code># Header1</code><br/>
          <code>## Header2</code><br/>
          <code>{'>'} Blockquote</code><br/>
          <code>@login</code><br/>
          <code>[Link title](Link URL)</code><br/>
          <a href='/about/syntax' target='_blank'>
            Full cheat sheat →
          </a>
        </div>
      </Popover>
    );
  },

  renderToggle () {
    if (this.props.preview) {
      return (
        <a href='#' title='Hide preview' onClick={() => this.props.onPreviewToggle(false)}>
          <i className='icon-caret-up'></i>
        </a>
      );
    }
    else {
      return (
        <a href='#' title='Show preview' onClick={() => this.props.onPreviewToggle(true)}>
          <i className='icon-caret-down'></i>
        </a>
      );
    }
  },

  renderControls () {
    let cs = 'helper-textarea-controls';
    if (!this.props.text && !this.state.help) {
      cs += ' helper-textarea-controls-empty';
    }
    return (
      <div className={cs}>
        <a href='#' className='helper-textarea-show-help' onClick={this.handleHelpToggle}>
          <i className='icon-question'></i>
        </a>
        {this.renderPopover()}
        {' '}
        {this.renderToggle()}
      </div>
    );
  },

  render () {
    return (
      <div className='helper-textarea-main'>
        <TextareaAutosize
          ref='textarea'
          placeholder={this.props.placeholder}
          value={this.props.text}
          enabled={this.props.enabled}
          onChange={event => this.props.onTextChange(event.target.value)}
          onKeyDown={this.handleKeyDown}
        />
        {this.renderControls()}
      </div>
    );
  },
});

const PreviewArea = React.createClass({
  displayName: 'Textarea.PreviewArea',

  propTypes: {
    realm: React.PropTypes.string,
    text: React.PropTypes.string.isRequired,
  },

  render () {
    return (
      <div className='helper-textarea-preview'>
        <div className='_label'>
          Preview
        </div>
        <div className='_content'>
          <Markdown
            realm={this.props.realm}
            text={this.props.text}
            editable={false}
          />
        </div>
      </div>
    );
  }
});


export default React.createClass({
  displayName: 'Textarea',

  propTypes: {
    text: React.PropTypes.string,
    realm: React.PropTypes.string,
    enabled: React.PropTypes.bool,
    onTextChange: React.PropTypes.func,
    onCancel: React.PropTypes.func,
    onSubmit: React.PropTypes.func,
  },

  getDefaultProps () {
    return {
      text: '',
      realm: '',
      enabled: true,
    };
  },

  getInitialState () {
    return {
      preview: !!( currentUser.getSetting("preview-mode") - 0 ), // casting string to boolean
    }
  },

  handlePreviewToggle (value) {
    this.setState({preview: value});
    currentUser.setSetting('preview-mode', 0 + value);
    this.refs.main.focus();
  },

  renderMainArea () {
    return (
      <MainArea
        ref='main'
        text={this.props.text}
        placeholder={this.props.placeholder}
        preview={this.state.preview}
        enabled={this.props.enabled}
        onPreviewToggle={this.handlePreviewToggle}
        onTextChange={this.props.onTextChange}
        onCancel={this.props.onCancel}
        onSubmit={this.props.onSubmit}
      />
    );
  },

  renderPreviewArea () {
    if (!this.state.preview || !this.props.text) {
      return null;
    }

    return (
      <PreviewArea
        realm={this.props.realm}
        text={this.props.text}
      />
    );
  },

  render () {
    return (
      <div className='helper-textarea'>
        {this.renderMainArea()}
        {this.renderPreviewArea()}
      </div>
    );
  },
});
