/******/ (function(modules) { // webpackBootstrap
/******/ 	// install a JSONP callback for chunk loading
/******/ 	var parentJsonpFunction = window["webpackJsonp"];
/******/ 	window["webpackJsonp"] = function webpackJsonpCallback(chunkIds, moreModules) {
/******/ 		// add "moreModules" to the modules object,
/******/ 		// then flag all "chunkIds" as loaded and fire callback
/******/ 		var moduleId, chunkId, i = 0, callbacks = [];
/******/ 		for(;i < chunkIds.length; i++) {
/******/ 			chunkId = chunkIds[i];
/******/ 			if(installedChunks[chunkId])
/******/ 				callbacks.push.apply(callbacks, installedChunks[chunkId]);
/******/ 			installedChunks[chunkId] = 0;
/******/ 		}
/******/ 		for(moduleId in moreModules) {
/******/ 			modules[moduleId] = moreModules[moduleId];
/******/ 		}
/******/ 		if(parentJsonpFunction) parentJsonpFunction(chunkIds, moreModules);
/******/ 		while(callbacks.length)
/******/ 			callbacks.shift().call(null, __webpack_require__);

/******/ 	};

/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// object to store loaded and loading chunks
/******/ 	// "0" means "already loaded"
/******/ 	// Array means "loading", array contains callbacks
/******/ 	var installedChunks = {
/******/ 		0:0
/******/ 	};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}

/******/ 	// This file contains only the entry chunk.
/******/ 	// The chunk loading function for additional chunks
/******/ 	__webpack_require__.e = function requireEnsure(chunkId, callback) {
/******/ 		// "0" is the signal for "already loaded"
/******/ 		if(installedChunks[chunkId] === 0)
/******/ 			return callback.call(null, __webpack_require__);

/******/ 		// an array means "currently loading".
/******/ 		if(installedChunks[chunkId] !== undefined) {
/******/ 			installedChunks[chunkId].push(callback);
/******/ 		} else {
/******/ 			// start chunk loading
/******/ 			installedChunks[chunkId] = [callback];
/******/ 			var head = document.getElementsByTagName('head')[0];
/******/ 			var script = document.createElement('script');
/******/ 			script.type = 'text/javascript';
/******/ 			script.charset = 'utf-8';
/******/ 			script.async = true;

/******/ 			script.src = __webpack_require__.p + "" + chunkId + ".bundle.js";
/******/ 			head.appendChild(script);
/******/ 		}
/******/ 	};

/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	eval("__webpack_require__.e/* require */(1, function(__webpack_require__) { var __WEBPACK_AMD_REQUIRE_ARRAY__ = [__webpack_require__(16), __webpack_require__(17), __webpack_require__(5), __webpack_require__(6), __webpack_require__(7), __webpack_require__(8), __webpack_require__(9), __webpack_require__(11), __webpack_require__(10), __webpack_require__(12), __webpack_require__(13), __webpack_require__(15), __webpack_require__(14), __webpack_require__(181), __webpack_require__(18), __webpack_require__(3), __webpack_require__(4), __webpack_require__(2), __webpack_require__(19)]; (function($, Backbone, MainRouter, UserRouter, RealmRouter, QuestRouter, AboutRouter, LegacyRouter, NotFoundRouter, SearchRouter, App, sharedModels, TextArea) {\n  var appView;\n  appView = new App({\n    el: $(\"#wrap\")\n  });\n  appView.render();\n  $(document).ajaxError(function() {\n    appView.notify(\"error\", \"Internal HTTP error\");\n    return ga(\"send\", \"event\", \"server\", \"error\");\n  });\n  new NotFoundRouter(appView);\n  new MainRouter(appView);\n  new RealmRouter(appView);\n  new QuestRouter(appView);\n  new UserRouter(appView);\n  new AboutRouter(appView);\n  new SearchRouter(appView);\n  new LegacyRouter(appView);\n  Backbone.on(\"pp:notify\", function(type, message) {\n    return appView.notify(type, message);\n  });\n  Backbone.on(\"pp:settings-dialog\", function() {\n    Backbone.history.navigate(\"/settings\", {\n      trigger: true\n    });\n    return ga(\"send\", \"event\", \"settings\", \"open\");\n  });\n  sharedModels.preload(function() {\n    return Backbone.history.start({\n      pushState: true\n    });\n  });\n  window.onbeforeunload = function() {\n    if (TextArea.active()) {\n      return \"You haven't finished editing yet.\";\n    }\n  };\n  $(document).on(\"click\", \"a[href='#']\", function(event) {\n    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) {\n      return;\n    }\n    return event.preventDefault();\n  });\n  $(document).on(\"click\", \"a[href^='/']\", function(event) {\n    var el, fragment;\n    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) {\n      return;\n    }\n    if (TextArea.active()) {\n      return;\n    }\n    el = $(event.currentTarget);\n    if (el.attr(\"target\") === \"_blank\") {\n      return;\n    }\n    event.preventDefault();\n    fragment = el.attr(\"href\").replace(/^\\//, \"\");\n    if (Backbone.history.fragment === fragment) {\n      return Backbone.history.loadUrl(fragment);\n    } else {\n      return Backbone.history.navigate(fragment, {\n        trigger: true\n      });\n    }\n  });\n  return $(document).on(\"click\", \"a[href^='h']\", function(event) {\n    var url;\n    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) {\n      return;\n    }\n    event.preventDefault();\n    url = $(event.currentTarget).attr(\"href\");\n    return window.open(url, '_blank');\n  });\n}.apply(null, __WEBPACK_AMD_REQUIRE_ARRAY__));});\n//@ sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9hcHAuY29mZmVlPzU3MjMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQ0Esc0VBQVEscUNBQ0osdUJBREksRUFDTSx1QkFETixFQUVKLHNCQUZJLEVBRVksc0JBRlosRUFFNEIsc0JBRjVCLEVBRTZDLHNCQUY3QyxFQUU4RCxzQkFGOUQsRUFFK0UsdUJBRi9FLEVBRWlHLHVCQUZqRyxFQUVzSCx1QkFGdEgsRUFHSix1QkFISSxFQUlKLHVCQUpJLEVBS0osdUJBTEksRUFNSix3QkFOSSxFQU1TLHVCQU5ULEVBTTRCLHNCQU41QixFQU04QyxzQkFOOUMsRUFPSixzQkFQSSxFQVFKLHVCQVJJLENBQVIsR0FTRyxTQUFDLENBQUQsRUFBSSxRQUFKLEVBQWMsVUFBZCxFQUEwQixVQUExQixFQUFzQyxXQUF0QyxFQUFtRCxXQUFuRCxFQUFnRSxXQUFoRSxFQUE2RSxZQUE3RSxFQUEyRixjQUEzRixFQUEyRyxZQUEzRyxFQUF5SCxHQUF6SCxFQUE4SCxZQUE5SCxFQUE0SSxRQUE1STtBQUNDO0FBQUEsWUFBYyxRQUFJO0FBQUEsUUFBSSxFQUFFLE9BQUYsQ0FBSjtHQUFKLENBQWQ7QUFBQSxFQUNBLE9BQU8sQ0FBQyxNQUFSLEVBREE7QUFBQSxFQUVBLEVBQUUsUUFBRixDQUFXLENBQUMsU0FBWixDQUFzQjtBQUNsQixXQUFPLENBQUMsTUFBUixDQUFlLE9BQWYsRUFBd0IscUJBQXhCO1dBQ0EsR0FBRyxNQUFILEVBQVcsT0FBWCxFQUFvQixRQUFwQixFQUE4QixPQUE5QixFQUZrQjtFQUFBLENBQXRCLENBRkE7QUFBQSxFQU1JLG1CQUFlLE9BQWYsQ0FOSjtBQUFBLEVBT0ksZUFBVyxPQUFYLENBUEo7QUFBQSxFQVFJLGdCQUFZLE9BQVosQ0FSSjtBQUFBLEVBU0ksZ0JBQVksT0FBWixDQVRKO0FBQUEsRUFVSSxlQUFXLE9BQVgsQ0FWSjtBQUFBLEVBV0ksZ0JBQVksT0FBWixDQVhKO0FBQUEsRUFZSSxpQkFBYSxPQUFiLENBWko7QUFB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ZSBpbnRvIGFwcHJvcHJpYXRlIG1vZHVsZXNcbnJlcXVpcmUgW1xuICAgIFwianF1ZXJ5XCIsIFwiYmFja2JvbmVcIixcbiAgICBcInJvdXRlcnMvbWFpblwiLCBcInJvdXRlcnMvdXNlclwiLCBcInJvdXRlcnMvcmVhbG1cIiwgXCJyb3V0ZXJzL3F1ZXN0XCIsIFwicm91dGVycy9hYm91dFwiLCBcInJvdXRlcnMvbGVnYWN5XCIsIFwicm91dGVycy9ub3QtZm91bmRcIiwgXCJyb3V0ZXJzL3NlYXJjaFwiXG4gICAgXCJ2aWV3cy9hcHBcIixcbiAgICBcIm1vZGVscy9zaGFyZWQtbW9kZWxzXCIsXG4gICAgXCJ2aWV3cy9oZWxwZXIvdGV4dGFyZWFcIlxuICAgIFwiYm9vdHN0cmFwXCIsIFwianF1ZXJ5LWF1dG9zaXplXCIsIFwianF1ZXJ5LnRpbWVhZ29cIiwgXCJqcXVlcnkuZWFzaW5nXCJcbiAgICBcImF1dGhcIlxuICAgIFwibWFpbi5zY3NzXCJcbl0sICgkLCBCYWNrYm9uZSwgTWFpblJvdXRlciwgVXNlclJvdXRlciwgUmVhbG1Sb3V0ZXIsIFF1ZXN0Um91dGVyLCBBYm91dFJvdXRlciwgTGVnYWN5Um91dGVyLCBOb3RGb3VuZFJvdXRlciwgU2VhcmNoUm91dGVyLCBBcHAsIHNoYXJlZE1vZGVscywgVGV4dEFyZWEpIC0+XG4gICAgYXBwVmlldyA9IG5ldyBBcHAoZWw6ICQoXCIjd3JhcFwiKSlcbiAgICBhcHBWaWV3LnJlbmRlcigpXG4gICAgJChkb2N1bWVudCkuYWpheEVycm9yIC0+XG4gICAgICAgIGFwcFZpZXcubm90aWZ5IFwiZXJyb3JcIiwgXCJJbnRlcm5hbCBIVFRQIGVycm9yXCJcbiAgICAgICAgZ2EgXCJzZW5kXCIsIFwiZXZlbnRcIiwgXCJzZXJ2ZXJcIiwgXCJlcnJvclwiXG5cbiAgICBuZXcgTm90Rm91bmRSb3V0ZXIoYXBwVmlldylcbiAgICBuZXcgTWFpblJvdXRlcihhcHBWaWV3KVxuICAgIG5ldyBSZWFsbVJvdXRlcihhcHBWaWV3KVxuICAgIG5ldyBRdWVzdFJvdXRlcihhcHBWaWV3KVxuICAgIG5ldyBVc2VyUm91dGVyKGFwcFZpZXcpXG4gICAgbmV3IEFib3V0Um91dGVyKGFwcFZpZXcpXG4gICAgbmV3IFNlYXJjaFJvdXRlcihhcHBWaWV3KVxuICAgIG5ldyBMZWdhY3lSb3V0ZXIoYXBwVmlldylcblxuICAgIEJhY2tib25lLm9uIFwicHA6bm90aWZ5XCIsICh0eXBlLCBtZXNzYWdlKSAtPlxuICAgICAgICBhcHBWaWV3Lm5vdGlmeSB0eXBlLCBtZXNzYWdlXG5cbiAgICBCYWNrYm9uZS5vbiBcInBwOnNldHRpbmdzLWRpYWxvZ1wiLCAtPlxuICAgICAgICBCYWNrYm9uZS5oaXN0b3J5Lm5hdmlnYXRlIFwiL3NldHRpbmdzXCIsIHRyaWdnZXI6IHRydWVcbiAgICAgICAgZ2EgXCJzZW5kXCIsIFwiZXZlbnRcIiwgXCJzZXR0aW5nc1wiLCBcIm9wZW5cIlxuXG4gICAgIyBXZSdyZSB3YWl0aW5nIGZvciBzaGFyZWQgZGF0YSB0byBiZSBsb2FkZWQgYmVmb3JlIGV2ZXJ5dGhpbmcgZWxzZS5cbiAgICAjIEl0J3MgYSBiaXQgc2xvd2VyIHRoYW4gc3RhcnRpbmcgdGhlIHJvdXRlciBpbW1lZGlhdGVseSwgYnV0IGl0IHByZXZlbnRzIGEgZmV3IG5hc3R5IHJhY2UgY29uZGl0aW9ucy5cbiAgICAjIEFsc28sIGl0J3MgZG9uZSBqdXN0IG9uY2UsIHNvIGFsbCBmb2xsb3dpbmcgbmF2aWdhdGlvbiBpcyBhY3R1YWxseSAqZmFzdGVyKi5cbiAgICBzaGFyZWRNb2RlbHMucHJlbG9hZCAtPiBCYWNrYm9uZS5oaXN0b3J5LnN0YXJ0IHB1c2hTdGF0ZTogdHJ1ZVxuXG4gICAgd2luZG93Lm9uYmVmb3JldW5sb2FkID0gLT5cbiAgICAgICAgaWYgVGV4dEFyZWEuYWN0aXZlKClcbiAgICAgICAgICAgIHJldHVybiBcIllvdSBoYXZlbid0IGZpbmlzaGVkIGVkaXRpbmcgeWV0LlwiXG4gICAgICAgIHJldHVyblxuXG4gICAgJChkb2N1bWVudCkub24gXCJjbGlja1wiLCBcImFbaHJlZj0nIyddXCIsIChldmVudCkgLT5cbiAgICAgICAgcmV0dXJuIGlmIGV2ZW50LmFsdEtleSBvciBldmVudC5jdHJsS2V5IG9yIGV2ZW50Lm1ldGFLZXkgb3IgZXZlbnQuc2hpZnRLZXlcbiAgICAgICAgZXZlbnQucHJldmVudERlZmF1bHQoKVxuXG4gICAgJChkb2N1bWVudCkub24gXCJjbGlja1wiLCBcImFbaHJlZl49Jy8nXVwiLCAoZXZlbnQpIC0+XG4gICAgICAgIHJldHVybiBpZiBldmVudC5hbHRLZXkgb3IgZXZlbnQuY3RybEtleSBvciBldmVudC5tZXRhS2V5IG9yIGV2ZW50LnNoaWZ0S2V5XG4gICAgICAgIHJldHVybiBpZiBUZXh0QXJlYS5hY3RpdmUoKSAjIG5vdCBjYWxsaW5nIHByZXZlbnREZWZhdWx0LCBzbyB3ZSdsbCBkbyBhIGZ1bGwgcGFnZSByZWxvYWRcbiAgICAgICAgZWwgPSAkKGV2ZW50LmN1cnJlbnRUYXJnZXQpXG4gICAgICAgIHJldHVybiBpZiBlbC5hdHRyKFwidGFyZ2V0XCIpID09IFwiX2JsYW5rXCJcblxuICAgICAgICBldmVudC5wcmV2ZW50RGVmYXVsdCgpXG4gICAgICAgIGZyYWdtZW50ID0gZWwuYXR0cihcImhyZWZcIikucmVwbGFjZSgvXlxcLy8sIFwiXCIpXG4gICAgICAgIGlmIEJhY2tib25lLmhpc3RvcnkuZnJhZ21lbnQgPT0gZnJhZ21lbnRcbiAgICAgICAgICAgICMgQmFja2JvbmUgd29uJ3QgcmVsb2FkIHRoZSBwYWdlIGlmIHdlIG5hdmlnYXRlIHRvIHRoZSBjdXJyZW50IGZyYWdtZW50XG4gICAgICAgICAgICAjIHNvIHdlIGhhdmUgdG8gbWVzcyB3aXRoIGl0cyBpbnRlcm5hbHNcbiAgICAgICAgICAgIEJhY2tib25lLmhpc3RvcnkubG9hZFVybCBmcmFnbWVudFxuICAgICAgICBlbHNlXG4gICAgICAgICAgICBCYWNrYm9uZS5oaXN0b3J5Lm5hdmlnYXRlIGZyYWdtZW50LCB0cmlnZ2VyOiB0cnVlXG5cbiAgICAkKGRvY3VtZW50KS5vbiBcImNsaWNrXCIsIFwiYVtocmVmXj0naCddXCIsIChldmVudCkgLT5cbiAgICAgICAgcmV0dXJuIGlmIGV2ZW50LmFsdEtleSBvciBldmVudC5jdHJsS2V5IG9yIGV2ZW50Lm1ldGFLZXkgb3IgZXZlbnQuc2hpZnRLZXlcbiAgICAgICAgZXZlbnQucHJldmVudERlZmF1bHQoKVxuICAgICAgICB1cmwgPSAkKGV2ZW50LmN1cnJlbnRUYXJnZXQpLmF0dHIoXCJocmVmXCIpXG4gICAgICAgIHdpbmRvdy5vcGVuIHVybCwgJ19ibGFuaydcblxuXG5cbi8qKiBXRUJQQUNLIEZPT1RFUiAqKlxuICoqIC4vYXBwLmNvZmZlZVxuICoqLyJdLCJzb3VyY2VSb290IjoiIn0=");

/***/ }
/******/ ]);