
/*
 * Copyright (c) 2014 by Redwood Labs
 * All rights reserved.
 */

(function() {
  var CraftingGuideServer, env, i, len, port, program, ref, server, signal, util;

  CraftingGuideServer = require('./crafting_guide_server');

  program = require('commander');

  util = require('util');

  program.usage("\n\n    Runs the Crafting Guide API Server.").version('1.0.0').option('-p, --port <NUMBER>', 'the port number on which to listen', parseInt).options('-e, --env <STRING>', 'the environment in which to run').parse(process.argv);

  global._ = require('underscore');

  global.logger = new Logger({
    level: Logger.VERBOSE
  });

  port = program.port || 8000;

  env = program.env || 'development';

  server = new CraftingGuideApiServer(port, env);

  server.start();

  ref = ['SIGINT', 'SIGTERM'];
  for (i = 0, len = ref.length; i < len; i++) {
    signal = ref[i];
    process.on(signal, function() {
      return server.stop().then(function() {
        return process.exit(0);
      });
    });
  }

}).call(this);
