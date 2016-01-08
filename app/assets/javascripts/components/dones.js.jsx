var Dones = React.createClass({

  mixins: [ParseReact.Mixin],

  observe: function(){
    return {
      workloads: (new Parse.Query('Workload')).descending('createdAt').equalTo('is_done', true)
    };
  },

  render: function() {
    return (
      <ul className="dones" id="dones">
        {this.data.workloads.map(function(c) {
          title = c.title || '無音'
          return <li>{title}</li>;
        })}
      </ul>
    );
  }
});
