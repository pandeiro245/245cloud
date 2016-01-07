var StartBox = React.createClass({
  render: function() {
    return (
      <div className="startBox">
        <h1>Start Buttons</h1>
        <StartWithoutMusic />
      </div>
    );
  }
});

var StartWithoutMusic = React.createClass({
  onClick(e) {
    ParseReact.Mutation.Create('Workload', {
      title: 'no music'
    }).dispatch()
  },
  render: function() {
    return (
      <a className="startWithoutMusic" href='#' onClick={this.onClick} >
      無音で集中
      </a>
    );
  }
});
