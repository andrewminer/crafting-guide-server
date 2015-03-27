
/*
Crafting Guide Server - middleware.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
 */

(function() {
  var Logger, addApiResponseMethod, approveOrigin, bodyParser, clientSession, ensureRequestId, logRequest, registerFinalizers, reportError, runFinalizers, status, util, w, writeErrorResponse, writeResponse, writeSuccessResponse;

  bodyParser = require('body-parser');

  clientSession = require('client-sessions');

  status = require('./http_status');

  util = require('util');

  w = require('when');

  Logger = require('crafting-guide-common').Logger;

  if (global.logger == null) {
    global.logger = new Logger;
  }

  exports.addPrefixes = function(app) {
    var i, len, m, ref, results;
    ref = [
      approveOrigin, ensureRequestId, registerFinalizers, bodyParser.json(), logRequest, clientSession({
        secret: 'CKpyGnY2C(]@Z38u',
        duration: 1000 * 60 * 60 * 24 * 7 * 2
      }), addApiResponseMethod
    ];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      m = ref[i];
      results.push(app.use(m));
    }
    return results;
  };

  exports.addSuffixes = function(app) {
    return app.use(reportError);
  };

  addApiResponseMethod = function(request, response, next) {
    response.api = (function(req, res) {
      return function(promise) {
        var result;
        result = null;
        return w(promise).then(function(r) {
          result = r;
          if (req.db != null) {
            return req.db.saveAll();
          }
        }).timeout(60000, new Error('Timed out while answering request')).then(function() {
          return writeSuccessResponse(result, req, res);
        })["catch"](function(error) {
          return writeErrorResponse(error, req, res);
        });
      };
    })(request, response);
    return next();
  };

  approveOrigin = function(request, response, next) {
    var origin;
    origin = request.headers.origin;
    if ((origin != null) && origin.match(/^http:\/\/([a-z]{1,7}\.)?crafting-guide\.com(:[0-9]{1,4})?/)) {
      response.set('Access-Control-Allow-Origin', origin);
      response.set('Access-Control-Allow-Credentials', 'true');
      response.set('Access-Control-Allow-Methods', request.headers['access-control-request-method']);
      response.set('Access-Control-Allow-Headers', request.headers['access-control-request-headers']);
    }
    if (request.method === 'OPTIONS') {
      return response.end();
    } else {
      return next();
    }
  };

  ensureRequestId = function(request, response, next) {
    request.id = request.param('requestId');
    if (request.id == null) {
      request.id = _.uuid();
    }
    return next();
  };

  logRequest = function(request, response, next) {
    var account, ref, start;
    account = (ref = request.session) != null ? ref.account : void 0;
    logger.verbose(function() {
      return ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
    });
    logger.info(function() {
      return "HTTP " + request.httpVersion + " " + request.method + " " + request.originalUrl + " id:" + request.id;
    });
    logger.verbose(function() {
      return "*** headers: " + (_.pp(request.headers));
    });
    logger.verbose(function() {
      return "*** ips:     " + (_.pp(request.ips));
    });
    logger.verbose(function() {
      return "*** params:  " + (_.pp(request.params));
    });
    logger.verbose(function() {
      return "----------";
    });
    start = new Date().valueOf();
    response.finalizers.push(function(request, response) {
      logger.verbose(function() {
        return "----------";
      });
      logger.verbose(function() {
        return "*** session: " + request.session;
      });
      return logger.info(function() {
        var duration, length, resultLine, unit;
        duration = new Date().valueOf() - start;
        resultLine = "Responded: " + response.statusCode + " after " + duration + "ms";
        if (response.result != null) {
          length = response.result.length;
          unit = 'B';
          if (length > 1024) {
            length /= 1024;
            unit = 'kB';
          }
          if (length > 1024) {
            length /= 1024;
            unit = 'MB';
          }
          resultLine += " with " + length + unit + " of data";
        }
        return resultLine;
      });
    });
    return next();
  };

  registerFinalizers = function(request, response, next) {
    response.finalizers = [];
    return next();
  };

  reportError = function(error, request, response, next) {
    logger.error("Caught unexpected error: " + error.message + ":\n" + error.stack);
    writeErrorResponse(error, request, response);
    return runFinalizers(request, response);
  };

  exports.requireLogin = function(request, response, next) {
    var ref;
    if (((ref = request.session) != null ? ref.owner_id : void 0) == null) {
      status.unauthorized["throw"]('you must be logged in to use this API');
    }
    return next();
  };

  runFinalizers = function(request, response) {
    var processRemaining;
    processRemaining = function(finalizers) {
      if (finalizers.length === 0) {
        return;
      }
      return w["try"](finalizers[0], request, response)["catch"](function(e) {
        return logger.error(function() {
          return "Error while running finalizers: " + e.message + "\n" + e.stack;
        });
      }).then(function() {
        return processRemaining(_.rest(finalizers));
      });
    };
    return processRemaining(response.finalizers.reverse());
  };

  writeErrorResponse = function(error, request, response) {
    var ref, result, statusCode;
    statusCode = error.statusCode != null ? error.statusCode : status.internalServerError;
    if (statusCode === status.internalServerError) {
      logger.error("Unexpected internal error: " + error.stack);
    }
    result = {
      requestId: request.id,
      status: 'error',
      message: error.message
    };
    if (error.data != null) {
      result.data = error.data;
    }
    if ((ref = request.app.env) === ('test' || 'development')) {
      result.stack = error.stack;
    }
    return writeResponse(request, response, statusCode, result);
  };

  writeResponse = function(request, response, statusCode, result) {
    logger.verbose(function() {
      return "writing result: " + statusCode + " " + (util.inspect(result, {
        depth: 10
      }));
    });
    response.status(statusCode).json(result);
    return runFinalizers(request, response);
  };

  writeSuccessResponse = function(result, request, response) {
    if (_.isString(result)) {
      result = {
        message: result
      };
    }
    if (result == null) {
      result = {};
    }
    if (result.data == null) {
      result.data = null;
    }
    if (result.message == null) {
      result.message = 'ok';
    }
    result.requestId = request.id;
    if (result.status == null) {
      result.status = 'success';
    }
    return writeResponse(request, response, status.ok, result);
  };

}).call(this);
