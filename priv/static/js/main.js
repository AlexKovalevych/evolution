/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;
/******/
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// identity function for calling harmony imports with the correct context
/******/ 	__webpack_require__.i = function(value) { return value; };
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 3);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_phoenix_html__ = __webpack_require__(2);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_phoenix_html___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_phoenix_html__);


let Elm = __webpack_require__(1);
Elm.Main.fullscreen();



/***/ }),
/* 1 */
/***/ (function(module, exports) {

throw new Error("Module build failed: Error: Compiler process exited with error Compilation failed\n-- NAMING ERROR ---------------------------------------- ./web/static/Router.elm\n\nCould not export `delta2url` which is not defined in this module.\n\n1| module Router exposing (parseUrl, delta2url)\n                                     ^^^^^^^^^\n\n\n-- NAMING ERROR ---------------------------------------- ./web/static/Router.elm\n\nCannot find type `Message`\n\n9| parseUrl : Location -> List Message\n                               ^^^^^^^\n\n\nDetected errors in 1 module.\n\n    at ChildProcess.<anonymous> (/Users/alex/Sites/evolution/node_modules/node-elm-compiler/index.js:141:27)\n    at emitTwo (events.js:100:13)\n    at ChildProcess.emit (events.js:185:7)\n    at maybeClose (internal/child_process.js:850:16)\n    at Socket.<anonymous> (internal/child_process.js:323:11)\n    at emitOne (events.js:90:13)\n    at Socket.emit (events.js:182:7)\n    at Pipe._onclose (net.js:475:12)");

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


function isLinkToSubmitParent(element) {
  var isLinkTag = element.tagName === 'A';
  var shouldSubmitParent = element.getAttribute('data-submit') === 'parent';

  return isLinkTag && shouldSubmitParent;
}

function getClosestForm(element) {
  while (element && element !== document && element.nodeType === Node.ELEMENT_NODE) {
    if (element.tagName === 'FORM') {
      return element;
    }
    element = element.parentNode;
  }
  return null;
}

function didHandleSubmitLinkClick(element) {
  while (element && element.getAttribute) {
    if (isLinkToSubmitParent(element)) {
      var message = element.getAttribute('data-confirm');
      if (message === null || confirm(message)) {
        getClosestForm(element).submit();
      }
      return true;
    } else {
      element = element.parentNode;
    }
  }
  return false;
}

window.addEventListener('click', function (event) {
  if (event.target && didHandleSubmitLinkClick(event.target)) {
    event.preventDefault();
    return false;
  }
}, false);



/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(0);


/***/ })
/******/ ]);