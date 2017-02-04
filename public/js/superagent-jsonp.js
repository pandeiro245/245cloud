'use strict';

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol ? "symbol" : typeof obj; };

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

var serialise = function serialise(obj) {
	if ((typeof obj === 'undefined' ? 'undefined' : _typeof(obj)) != 'object') return obj;
	var pairs = [];
	for (var key in obj) {
		if (null != obj[key]) {
			pairs.push(encodeURIComponent(key) + '=' + encodeURIComponent(obj[key]));
		}
	}
	return pairs.join('&');
};

var jsonp = function jsonp(requestOrConfig) {
	var reqFunc = function reqFunc(request) {
		// In case this is in nodejs, run without modifying request
		if (typeof window == 'undefined') return request;

		request.end = end.bind(request)(requestOrConfig);
		return request;
	};
	// if requestOrConfig is request
	if (typeof requestOrConfig.end == 'function') {
		return reqFunc(requestOrConfig);
	} else {
		return reqFunc;
	}
};

jsonp.callbackWrapper = function (data) {
	var err = null;
	var res = {
		body: data
	};
	clearTimeout(this._jsonp.timeout);

	this._jsonp.callback.call(this, err, res);
};

jsonp.errorWrapper = function () {
	var err = new Error('404 NotFound');
	this._jsonp.callback.call(this, err, null);
};

var end = function end() {
	var config = arguments.length <= 0 || arguments[0] === undefined ? { timeout: 1000 } : arguments[0];

	return function (callback) {

		var timeout = setTimeout(jsonp.errorWrapper.bind(this), config.timeout);

		this._jsonp = {
			callbackParam: config.callbackParam || 'callback',
			callbackName: config.callbackName || 'superagentCallback' + new Date().valueOf() + parseInt(Math.random() * 1000),
			callback: callback,
			timeout: timeout
		};

		window[this._jsonp.callbackName] = jsonp.callbackWrapper.bind(this);

		var params = _defineProperty({}, this._jsonp.callbackParam, this._jsonp.callbackName);

		this._query.push(serialise(params));
		var queryString = this._query.join('&');

		var s = document.createElement('script');
		var separator = this.url.indexOf('?') > -1 ? '&' : '?';
		var url = this.url + separator + queryString;

		s.src = url;
		document.getElementsByTagName('head')[0].appendChild(s);

		return this;
	};
};

// Prefer node/browserify style requires
if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
	module.exports = jsonp;
} else if (typeof window !== 'undefined') {
	window.superagentJSONP = jsonp;
}