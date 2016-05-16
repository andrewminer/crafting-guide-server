#
# Crafting Guide - index.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

require('dotenv').config()

{Logger}      = require 'crafting-guide-common'
global.logger = new Logger level:Logger.VERBOSE

global._ = require 'underscore'
_.mixin require('crafting-guide-common').stringMixins

global.util = require 'util'

global.w    = require 'when'

########################################################################################################################

CraftingGuideServer = require './crafting_guide_server'
server = new CraftingGuideServer process.env.PORT, process.env.NODE_ENV

for signal in ['SIGINT', 'SIGTERM']
    process.on signal, -> server.stop().then -> process.exit 0

server.start()
