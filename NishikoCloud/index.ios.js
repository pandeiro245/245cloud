import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  Image,
  View,
  ScrollView,
  TouchableHighlight
} from 'react-native';

var url = 'http://245cloud.com/api/workloads.json';
var debug = true;
var pomo = debug ? 0.1 : 24;
var chat = debug ? 0.1 : 5;

function zero(i) {
  if(i < 0) {
    return "00";
  }
  return i < 10 ? '0'+ i : i;
}

var start = null;
var status = 'before';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      start: new Date().getTime(),
      status: 'before',
    };
    setInterval(() => {
      now = new Date().getTime();
      total = parseInt(pomo * 60 - (now - start)/1000);

      if(status == 'playing' && total < 0) {
        status = 'chatting'
      } else if (status == 'chatting' && total < -1 * chat * 60) {
        status = 'before'
      }

      if(status == 'playing') {
        min = parseInt(total/60);
        sec = total - min*60;
        remain = 'あと' + zero(min) + ':' + zero(sec);
        this.setState({ remain: remain });
      } else if(status == 'chatting') {
        total2 = chat * 60 + total
        min = parseInt(total2/60);
        sec = total2 - min*60;
        remain = 'あと' + zero(min) + ':' + zero(sec);
        this.setState({ remain: remain });
      } else {
        this.setState({ remain: '' });
      }
    }, 1000);
  }

  _onPressButton() {
    start = new Date().getTime();
    status = 'playing';
  }

  render() {
    let header = {
      uri: 'https://ruffnote.com/attachments/24932'
    };
    let nomusic = {
      uri: 'https://ruffnote.com/attachments/24927'
    };
    
    let remain = this.state.remain
    return (
      <View style={styles.container}>
        <Text style={styles.header}>
        <Image source={header} style={styles.headerimage}/>
        </Text>
        <Text style={styles.main}>
        <Text style={styles.welcome}>
        245cloudは24分間、自分の作業に集中したら5分間達成した人同士で交換日記ができるサービスです。{'\n'}
        みんなが聞いている音楽で集中することもできますし、{'\n'}無音も人気です。{'\n'}
        </Text>
        <Text style={styles.timer}>
        {'\n'}{remain}{'\n'}{'\n'}
        </Text>
        <Text style={styles.buttons}>
          <TouchableHighlight onPress={this._onPressButton} style={{width: 150, height: 30}}>
          <Image source={nomusic} style={{width: 150, height: 30}} />
          </TouchableHighlight>
        </Text>
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    marginTop: 20,
    textAlign: 'center',
    backgroundColor: '#231809',
  },
  headerimage: {
    width: 300,
    height: 150,
    marginTop: 5
  },
  main: {
    alignSelf: 'stretch',
    textAlign: 'center',
    backgroundColor: '#FFFFFF',
  },
  welcome: {
    fontSize: 13,
    flex: 1,
    marginTop: 30
  },
  timer: {
    fontSize: 30
  },
  buttons: {
    flex: 1,
  },
});

AppRegistry.registerComponent('NishikoCloud', () => App);
