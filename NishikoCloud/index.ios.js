import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  Image,
  View,
  ScrollView
} from 'react-native';

var url = 'http://245cloud.com/api/workloads.json';

class NishikoCloud extends Component {
  render() {
    let header = {
      uri: 'https://ruffnote.com/attachments/24932'
    };
    let nomusic = {
      uri: 'https://ruffnote.com/attachments/24927'
    };
    return (
      <ScrollView style={styles.container}>
        <Text style={styles.header}>
        <Image source={header} style={{width: 300, height: 150}}/>
        </Text>

        <Text style={styles.main}>
        <Text style={styles.welcome}>
        245cloudは24分間、自分の作業に集中したら5分間達成した人同士で交換日記ができるサービスです。{'\n'}
        みんなが聞いている音楽で集中することもできますし、{'\n'}無音も人気です。{'\n'}{'\n'}
        </Text>
        <Text style={styles.buttons}>
          <Image source={nomusic} style={{width: 150, height: 30}} />
        </Text>
        </Text>
      </ScrollView>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    marginTop: 20,
    flex: 1,
    //justifyContent: 'center',
    //alignItems: 'center',
  },
  header: {
    textAlign: 'center',
    backgroundColor: '#231809',
  },
  main: {
    //flex: 1,
    alignSelf: 'stretch',
    textAlign: 'center',
    backgroundColor: '#FFFFFF',
  },
  welcome: {
    fontSize: 13,
    flex: 1,
    marginTop: 30
  },
  buttons: {
    flex: 1,
  },
});

AppRegistry.registerComponent('NishikoCloud', () => NishikoCloud);
