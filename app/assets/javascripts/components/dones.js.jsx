var Dones = React.createClass({

  mixins: [ParseReact.Mixin],

  observe: function(){
    return {
      workloads: (new Parse.Query('Workload')).ascending('createdAt')
    };
  },

  render: function() {
    return (
      <ul className="dones">
        {this.data.workloads.map(function(c) {
          return <li>{c.title}</li>;
        })}
      </ul>
    );
  }
});
