###
Crafting Guide Common - test_helper.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

{Logger} = require 'crafting-guide-common'

require 'when/monitor/console'

chai = require 'chai'
chai.use require 'sinon-chai'

########################################################################################################################

chai.config.includeStack = true

global._      = require 'underscore'
global.assert = chai.assert
global.expect = chai.expect
global.logger = new Logger level:Logger.FATAL
global.should = chai.should()
global.util   = require 'util'
global.w      = require 'when'

_.mixin require('crafting-guide-common').stringMixins