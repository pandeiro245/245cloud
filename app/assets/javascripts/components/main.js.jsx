//class TodoList extends ParseComponent {
var TodoList = React.createClass({
  //observe(props, state) {
  //  return {
  //    items: new Parse.Query('TodoItem').ascending('createdAt')
  //  };
  //}

  render: function() {
    // If a query is outstanding, this.props.queryPending will be true
    // We can use this to display a loading indicator
    return (
      <div className={this.pendingQueries().length ? 'todo_list loading' : 'todo_list'}>
        <a onClick={this._refresh.bind(this)} className="refresh">Refresh</a>
        {this.data.items.map(function(i) {
          // Loop over the objects returned by the items query, rendering them
          // with TodoItem components.
          return (
            <TodoItem key={i.id} item={i} update={this._updateItem} destroy={this._destroyItem} />
          );
        }, this)}
        <TodoCreator submit={this._createItem} />
      </div>
    );
  }

  //_refresh() {
  //  this.refreshQueries('items');
  //}

  //// A Create mutation takes a className and a set of new attributes
  //_createItem(text) {
  //  ParseReact.Mutation.Create('TodoItem', {
  //    text: text
  //  }).dispatch();
  //}

  //// A Set mutation takes an Id object and a set of attribute changes
  //_updateItem(id, text) {
  //  ParseReact.Mutation.Set(id, {
  //    text: text
  //  }).dispatch();
  //}

  //// A Destroy mutation simply takes an Id object
  //_destroyItem(id) {
  //  ParseReact.Mutation.Destroy(id).dispatch();
  //}
});

var TodoItem = React.createClass({
  getInitialState: function() {
    return ({
      editing: false,
      editText: ''
    });
  },

  render: function() {
    if (this.state.editing) {
      return (
        <div className="todo_item editing">
          <input
            ref="edit_input"
            onChange={this._onChange}
            onKeyDown={this._onKeyDown}
            value={this.state.editText}
          />
          <a className="save" onClick={this._stopEdit}>
            <i className="icon_submit" />
          </a>
        </div>
      );
    }
    return (
      <div className="todo_item">
        <div className="item_text">
          {this.props.item.text}
          <div className="options">
            <a onClick={this._startEdit}><i className="icon_edit" /></a>
            <a onClick={this._removeItem}><i className="icon_delete" /></a>
          </div>
        </div>
        <div className="item_date">
          <PrettyDate value={this.props.item.createdAt} />
        </div>
      </div>
    );
  },

  _startEdit: function() {
    this.setState({
      editText: this.props.item.text,
      editing: true
    }, function() {
      // Set the cursor to the end of the input
      var node = this.refs.edit_input.getDOMNode();
      node.focus();
      var len = this.state.editText.length;
      node.setSelectionRange(len, len);
    });
  },

  _onChange: function(e) {
    this.setState({
      editText: e.target.value
    });
  },

  _onKeyDown: function(e) {
    if (e.keyCode === 13) {
      this._stopEdit();
    }
  },

  _stopEdit: function() {
    if (this.state.editText) {
      this.props.update(this.props.item.id, this.state.editText);
      this.setState({
        editing: false
      });
    } else {
      this.props.destroy(this.props.item.id);
    }
  },

  _removeItem: function() {
    this.props.destroy(this.props.item.id);
  }
});



var TodoCreator = React.createClass({
  getInitialState: function() {
    return ({
      value: ''
    });
  },

  render: function() {
    return (
      <div className="todo_creator">
        <input
          value={this.state.value}
          onChange={this._onChange}
          onKeyDown={this._onKeyDown}
        />
        <a onClick={this._submit} className="todo_submit">Add</a>
      </div>
    );
  },

  _onChange: function(e) {
    this.setState({
      value: e.target.value
    });
  },

  _onKeyDown: function(e) {
    if (e.keyCode === 13) {
      this._submit();
    }
  },

  _submit: function() {
    this.props.submit(this.state.value);
    this.setState({
      value: ''
    });
  }
});



var months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

var PrettyDate = React.createClass({
  componentWillMount: function() {
    this.interval = null;
  },
  componentDidMount: function() {
    var delta = (new Date() - this.props.value) / 1000;
    if (delta < 60 * 60) {
      this.setInterval(this.forceUpdate.bind(this), 10000);
    }
  },
  componentWillUnmount: function() {
    if (this.interval) {
      clearInterval(this.interval);
    }
  },
  setInterval: function() {
    this.interval = setInterval.apply(null, arguments);
  },
  render: function() {
    var val = this.props.value;
    var text = months[val.getMonth()] + ' ' + val.getDate();
    var delta = (new Date() - val) / 1000;
    if (delta < 60) {
      text = 'Just now';
    } else if (delta < 60 * 60) {
      var mins = ~~(delta / 60);
      text = mins + (mins === 1 ? ' minute ago' : ' minutes ago');
    } else if (delta < 60 * 60 * 24) {
      var hours = ~~(delta / 60 / 60);
      text = hours + (hours === 1 ? ' hour ago' : ' hours ago');
    }
    return (
      <span>{text}</span>
    );
  }
});

Parse.initialize('5QB2LreJhbVUNC6axMF9ET1XIp7KwFmNLHMcUHgl', '40jRd7RSMAPQVfxFFOZWegzlC0KwhffFqt1gHgck');

React.render(
  <TodoList />,
  document.getElementById('app')
);
