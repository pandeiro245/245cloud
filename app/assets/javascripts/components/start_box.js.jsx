var StartBox = React.createClass({
  render: function() {
    return (
      <div className="startBox">
        <StartWithoutMusic />
      </div>
    );
  }
});

var StartWithoutMusic = React.createClass({
  onClick(e) {
    $('#news').hide();
    $('#dones').hide();
    $('#start').hide();
    $('#footer').hide();
    ParseReact.Mutation.Create('Workload', {
      title: 'no music'
    }).dispatch()
  },
  render: function() {
    return (
      <a id='start' className="startWithoutMusic" href='#' onClick={this.onClick} >
      <img src='https://ruffnote.com/attachments/24926' />
      </a>
    );
  }
});
