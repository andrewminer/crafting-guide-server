#
# Crafting Guide - global.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

store = require '../src/store'

########################################################################################################################

beforeEach ->
    promises = []
    for name, Resource of store.definitions
        promises.push Resource.destroyAll()
    w.all promises
