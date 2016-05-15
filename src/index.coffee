#
# Crafting Guide - index.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

global._    = require 'underscore'
global.util = require 'util'
global.w    = require 'when'

CraftingGuideServer = require './crafting_guide_server'
{Logger}            = require 'crafting-guide-common'

########################################################################################################################

_.mixin require('crafting-guide-common').stringMixins

global.logger = new Logger level:Logger.VERBOSE

server = new CraftingGuideServer process.env.PORT, process.env.NODE_ENV

for signal in ['SIGINT', 'SIGTERM']
    process.on signal, -> server.stop().then -> process.exit 0

server.start()
