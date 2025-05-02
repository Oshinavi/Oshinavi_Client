// twitter_text_bridge.js
importScripts('https://cdn.jsdelivr.net/npm/twitter-text@3.1.0/dist/twitter-text.umd.min.js');

self.onmessage = function(e) {
  const text = e.data;
  const result = twitter.parseTweet(text);
  self.postMessage(result.weightedLength);
};