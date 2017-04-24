#
# Crafting Guide Server - index.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

require("dotenv").config()

{Logger} = require("crafting-guide-common").util

global.logger = new Logger level:Logger.VERBOSE
global._      = require("crafting-guide-common")._
global.util   = require "util"
global.w      = require "when"

########################################################################################################################

CraftingGuideServer = require "./crafting_guide_server"
server = new CraftingGuideServer process.env.PORT, process.env.NODE_ENV

for signal in ["SIGINT", "SIGTERM"]
    process.on signal, ->
        server.stop()
            .timeout 10000
            .catch (error)->
                logger.error "failed to shut down cleanly: #{error.stack}"
            .then ->
                process.exit 0

server.start()
    .catch (e)->
        logger.error -> "failed to start server: #{e}"
        process.exit -1
