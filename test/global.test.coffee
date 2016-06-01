#
# Crafting Guide - global.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

store = require '../src/store'

########################################################################################################################

beforeEach ->
    db = store.getAdapter('sql')?.query
    return unless db

    tables = []
    for name, Resource of store.definitions
        continue unless Resource.table?
        tables.push "\"#{Resource.table}\""

    db.raw "truncate #{tables.join(', ')} cascade"
