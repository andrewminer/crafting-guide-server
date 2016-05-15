#
# Crafting Guide - store.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

JSData     = require 'js-data'
SqlAdapter = require 'js-data-sql'
{Logger}   = require 'crafting-guide-common'

global.logger ?= new Logger

########################################################################################################################

module.exports = store = new JSData.DS()

if process.env.DATABASE_URL?
    postgresAdapter = new SqlAdapter
        client: 'pg' # postgres
        connection: process.env.DATABASE_URL

    store.registerAdapter 'sql', postgresAdapter, default:true
else
    logger.fatal -> "No SQL database has been configured!"
    process.exit 1

########################################################################################################################

require('crafting-guide-common').defineResources(store)
