#
# Crafting Guide - 20160514155355-add-mod-suggestions.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

tools = require '../migration_tools'
w     = require 'when'

########################################################################################################################

exports.up = (db) ->
    createMods = db.createTable 'Mods',
        id:     { type:'int',    autoIncrement:true, notNull:true, primaryKey:true }
        name:   { type:'string', notNull:true }
        url:    { type:'string', notNull:true }

    createMods.then ->
        tools.addTimestamps db, 'Mods'

    createUsers = db.createTable 'Users',
        id:                { type:'int', autoIncrement:true, notNull:true, primaryKey:true }
        avatarUrl:         { type:'string' }
        email:             { type:'string' }
        gitHubAccessToken: { type:'string' }
        gitHubId:          { type:'int' }
        gitHubLogin:       { type:'string' }
        name:              { type:'string' }

    createUsers.then ->
        tools.addTimestamps db, 'Users'
        db.addIndex 'Users', 'Users_gitHubId', ['gitHubId'], true

    w.all(createMods, createUsers).then ->
        createModVotes = db.createTable 'ModVotes',
            id:      { type:'int', autoIncrement:true, notNull:true, primaryKey:true }
            modId:   { type:'int', notNull:true }
            userId:  { type:'int', notNull:true }

        createModVotes.then ->
            tools.addTimestamps db, 'ModVotes'
            db.addForeignKey 'ModVotes', 'Mods', 'ModVotes-Mods', {'modId': 'id'}, tools.cascadeRules
            db.addForeignKey 'ModVotes', 'Users', 'ModVotes-Users', {'userId': 'id'}, tools.cascadeRules

exports.down = (db) ->
    db.dropTable 'ModVotes'
        .then ->
            db.dropTable 'Mods'
            db.dropTable 'Users'
