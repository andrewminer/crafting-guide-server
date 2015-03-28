###
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

global._            = require 'underscore'

CraftingGuideServer = require './crafting_guide_server'
{Logger}            = require 'crafting-guide-common'
program             = require 'commander'
util                = require 'util'

_.mixin require('crafting-guide-common').stringMixins

########################################################################################################################

global.logger = new Logger level:Logger.VERBOSE

port = process.env.CRAFTING_GUIDE_PORT or 80
env  = process.env.NODE_ENV

server = new CraftingGuideServer port, env

for signal in ['SIGINT', 'SIGTERM']
    process.on signal, -> server.stop().then -> process.exit 0

server.start()
