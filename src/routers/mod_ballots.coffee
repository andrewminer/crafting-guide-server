#
# Crafting Guide - mod_ballot.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express = require 'express'
store   = require '../store'
_       = require '../underscore'

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.get '/', (request, response)->
    ModSuggestion.findAll()
        .then (suggestions)->
            response.api data:(s.toHash() for s in suggestions)

router.post '/', (request, response)->
    attributes = _.pick request.body, ModSuggestion.fields

    ModSuggestion.create attributes
