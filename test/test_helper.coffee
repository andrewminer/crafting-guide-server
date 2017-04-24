#
# Crafting Guide Server - test_helper.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Logger} = require("crafting-guide-common").util
_ = require "../src/underscore"

require "when/monitor/console"

chai = require "chai"
chai.use require "sinon-chai"

########################################################################################################################

chai.config.includeStack = true

global._      = _
global.assert = chai.assert
global.expect = chai.expect
global.logger = new Logger level:Logger.FATAL
global.should = chai.should()
global.util   = require "util"
global.w      = require "when"

global.Promise = w.Promise

# Mocha Test Helpers ###################################################################################################

process.env.DATABASE_URL = "postgres:///crafting_guide_test"
store = require "../src/store"
