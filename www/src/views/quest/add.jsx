import _ from 'underscore';
import $ from 'jquery';
import React from 'react';

import Backbone from 'backbone';
import Textarea from 'views/helper/textarea-react';
import TagsInput from 'views/helper/tags-input';
import RealmHelper from 'views/quest/add/realm-helper';
import sharedModels from 'models/shared-models';
import QuestModel from 'models/quest';

import ElasticInput from 'components/elastic-input';

const MobileRealmSelector = React.createClass({
  displayName: 'QuestAdd.MobileRealmSelector',

  propTypes: {
    realm: React.PropTypes.string,
    onSwitchRealm: React.PropTypes.func,
  },

  render () {
    const options = sharedModels.realms.models.map(
      r => (
        <option value={r.get('id')} key={r.get('id')}>
          {r.get('name')}
        </option>
      )
    );

    return (
      <div className="mobile-inline-block">
        {' in '}
        <select
          name="realm"
          className="quest-add-realm-select"
          value={this.props.realm}
          onChange={event => this.props.onSwitchRealm(event.target.value)}
        >
          <option value=''>Pick a realm:</option>
          {options}
        </select>
      </div>
    );
  },
});

const RealmSelector = React.createClass({
  displayName: 'QuestAdd.RealmSelector',

  propTypes: {
    realm: React.PropTypes.string,
    onSwitchRealm: React.PropTypes.func,
  },

  renderSelectedRealm () {
    if (!this.props.realm) return null;
    return (
      <RealmHelper
        model={sharedModels.realms.findWhere({ id: this.props.realm })}
      />
    );
  },

  renderRealm (r) {
    let cs = '';
    if (r.get('id') == this.props.realm) {
      cs = 'active';
    }
    return (
      <li key={r.get('id')} className={cs}>
        <a href='#' onClick={() => this.props.onSwitchRealm(r.get('id'))}>
          {r.get('name')}
        </a>
      </li>
    );
  },

  render () {
    let cs = 'quest-add-sidebar sidebar desktop-block';
    if (!this.props.realm) {
      cs += ' quest-add-realm-unpicked';
    }

    const realms = sharedModels.realms.models.map(
      r => this.renderRealm(r)
    );

    return (
      <section className={cs}>
        <div className='quest-add-realm-list clearfix'>
          <header>Realm:</header>

          <ul className="pills">
            {realms}
          </ul>
        </div>

        {this.renderSelectedRealm()}
      </section>
    );
  },
});

const FormLabel = React.createClass({
  render () {
    return (
      <label className='quest-add-form--label'>
        <small className='muted'>{this.props.children}</small>
      </label>
    );
  },
});

const Form = React.createClass({
  displayName: 'QuestAdd.Form',

  propTypes: {
    realm: React.PropTypes.string,
    name: React.PropTypes.string,
    tags: React.PropTypes.array,
    description: React.PropTypes.string,
    onDescriptionChange: React.PropTypes.func.isRequired,
    onNameChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
  },

  focus () {
    this.refs.name.focus();
  },

  render () {
    return (
      <div className='quest-add-form'>
        <div className='form-row'>
          <FormLabel>Write a short description of the task here.</FormLabel>
          <ElasticInput
            ref='name'
            value={this.props.name}
            onChange={this.props.onNameChange}
            onSubmit={this.props.onSubmit}
            placeholder="What's your next goal?"
          />
        </div>

        <div className='form-row'>
          <FormLabel>Description:</FormLabel>
          <Textarea
            realm={this.props.realm} // TODO
            text={this.props.description}
            placeholder='Quest details are optional. You can always add them later.'
            onTextChange={this.props.onDescriptionChange}
            onSubmit={this.props.onSubmit}
          />
        </div>

        <div className='form-row'>
          <FormLabel>Tags are optional. Enter them comma-separated here (for example: "bug,dancer"):</FormLabel>
          <TagsInput
            tags={this.props.tags}
            onChange={this.props.onTagsChange}
            onValid={this.props.onFormIsValid}
            onSubmit={this.props.onSubmit}
          />
        </div>
      </div>
    );
  },
});

const Buttons = React.createClass({
  displayName: 'QuestAdd.Buttons',

  propTypes: {
    submittable: React.PropTypes.bool,
    submitted: React.PropTypes.bool,
    onClose: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
  },

  render () {
    let spinner = null;
    if (this.props.submitted) {
      spinner = <i className='icon-spinner icon-spin'/>;
    }

    let csSubmit = 'btn btn-large btn-primary';
    if (!this.props.submittable) {
      csSubmit += ' disabled';
    }

    return (
      <div className='pull-right'>
        {spinner}
        <button
          className='btn btn-large btn-default'
          onClick={this.props.onClose}
        >
          Cancel
        </button>

        {' '}

        <button
          className={csSubmit}
          dataPlacement='top'
          dataTitle='pick a realm first'
          dataAnimation='false'
          dataTrigger='hover'
          onClick={this.props.onSubmit}
        >
          Start quest
        </button>

      </div>
    );
  },
});

export default React.createClass({
  displayName: 'QuestAdd',

  propTypes: {
    realm: React.PropTypes.string,
    cloned_from: React.PropTypes.any, // Backbone model
  },

  getInitialState () {
    let state;
    if (this.props.cloned_from) {
      state = {
        name: this.props.cloned_from.get('name'),
        realm: this.props.cloned_from.get('realm'),
        description: this.props.cloned_from.get('description'),
        tags: this.props.cloned_from.get('tags'),
      };
    }
    else {
      state = {
        name: '',
        realm: this.props.realm, // copying over, that's ok
        description: '',
        tags: [],
      };
    }

    if (!state.realm) {
      // TODO - untested!
      const userRealms = sharedModels.currentUser.get('realms');
      if (userRealms && userRealms.length == 1) {
        state.realm = userRealms[0];
      }
    }

    state.submitted = false;
    state.valid = true;
    return state;
  },

  submittable () {
    return Boolean(
      !this.state.submitted && this.state.name && this.state.realm && this.state.valid
    );
  },

  submit () {
    if (!this.submittable()) {
      return;
    }

    const model = new QuestModel();

    let modelProps = {
      name: this.state.name,
      realm: this.state.realm,
      description: this.state.description, // to be filled
      tags: this.state.tags,
    };

    if (this.props.cloned_from) {
      modelProps.cloned_from = this.props.cloned_from.id;
    }

    model.set(modelProps);
    model.save(
      {},
      {
        success: () => {
          Backbone.trigger('pp:quest-add', model);
          this.close();
        }
      }
    );

    ga('send', 'event', 'quest', 'add');
    mixpanel.track('add quest');

    // the component will be destroyed now, but whatever
    this.setState({submitted: true});
  },

  close () {
    Backbone.history.navigate('/', {trigger: true, replace: true});
  },

  handleSwitchRealm (realm) {
    this.setState({realm});
    this.refs.form.focus();
  },

  render () {
    return (
      <div className='quest-add'>
        <RealmSelector
          realm={this.state.realm}
          onSwitchRealm={this.handleSwitchRealm}
        />
        <section className='quest-add-mainarea mainarea'>
          <header>
            Go on a quest
            <MobileRealmSelector
              realm={this.state.realm}
              onSwitchRealm={this.handleSwitchRealm}
            />
          </header>

          <Form
            ref='form'
            realm={this.state.realm}
            name={this.state.name}
            tags={this.state.tags}
            description={this.state.description}
            onTagsChange={tags => this.setState({tags})}
            onNameChange={name => this.setState({name})}
            onDescriptionChange={description => this.setState({description})}
            onFormIsValid={valid => this.setState({valid})}
            onSubmit={this.submit}
          />

          <Buttons
            submitted={this.state.submitted}
            submittable={this.submittable()}
            onClose={this.close}
            onSubmit={this.submit}
          />
        </section>
      </div>
    );
  },
});
