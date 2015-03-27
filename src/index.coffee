###
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

CraftingGuideServer = require './crafting_guide_server'
program             = require 'commander'
util                = require 'util'

########################################################################################################################

program
    .usage("\n\n    Runs the Crafting Guide API Server.")
    .version('1.0.0')
    .option('-p, --port <NUMBER>', 'the port number on which to listen', parseInt)
    .options('-e, --env <STRING>', 'the environment in which to run')
    .parse(process.argv)

global._ = require 'underscore'
_.mixin require('crafting-guide-common').stringMixins

global.logger = new Logger level:Logger.VERBOSE

port  = program.port or 8000
env = program.env or 'development'

server = new CraftingGuideApiServer port, env
server.start()

for signal in ['SIGINT', 'SIGTERM']
    process.on signal, -> server.stop().then -> process.exit 0
