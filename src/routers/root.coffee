#
# Crafting Guide - root.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express = require 'express'

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.get '/ping', (request, response)->
    response.api message:request.query.message
