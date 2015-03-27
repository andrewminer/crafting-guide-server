
/*
Crafting Guide Server - server.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
 */

(function() {
  var CraftingGuideServer, express, http, middleware, w;

  express = require('express');

  http = require('http');

  middleware = require('./middleware');

  w = require('when');

  if (global.logger == null) {
    global.logger = new Logger;
  }

  module.exports = CraftingGuideServer = (function() {
    function CraftingGuideServer(port, env) {
      if (port == null) {
        throw new Error('port is mandatory');
      }
      if (env == null) {
        throw new Error('env is mandatory');
      }
      this.expressApp = express();
      this.port = port;
      this.expressApp.env = env;
      middleware.addPrefixes(this.expressApp);
      this.expressApp.use('/', require('./routers/root'));
      middleware.addSuffixes(this.expressApp);
      this.httpServer = http.createServer(this.expressApp);
    }

    CraftingGuideServer.prototype.start = function() {
      var deferred;
      deferred = w.defer();
      this.httpServer.once('error', function(e) {
        return deferred.reject(e);
      });
      this.httpServer.listen(this.port, (function(_this) {
        return function() {
          logger.warning("Graffer API Server is listening on port " + _this.port);
          return deferred.resolve(_this);
        };
      })(this));
      return deferred.promise;
    };

    CraftingGuideServer.prototype.stop = function() {
      return w.promise((function(_this) {
        return function(resolve, reject) {
          if (_this.expressApp.env !== 'test') {
            logger.warning("Graffer API Server is shutting down");
          }
          return _this.httpServer.close(function() {
            return resolve(this);
          });
        };
      })(this));
    };

    return CraftingGuideServer;

  })();

}).call(this);
