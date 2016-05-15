#
# Crafting Guide - users.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express        = require 'express'
store          = require '../store'
_              = require '../underscore'
{requireLogin} = require '../middleware'

User = store.definitions.User

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.get '/current', requireLogin, (request, response)->
    response.api ->
        return request.user
