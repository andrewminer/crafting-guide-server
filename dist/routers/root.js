
/*
Crafting Guide Server - admin.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
 */

(function() {
  var express, router;

  express = require('express');

  module.exports = router = express.Router();

  router.get('/ping', function(request, response) {
    return response.api({
      message: request.message
    });
  });

}).call(this);
