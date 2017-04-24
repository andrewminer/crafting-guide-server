#
# Crafting Guide Server - mod_ballot_loader.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

store = require "../store"
_     = require "../underscore"

ModBallot     = store.definitions.ModBallot
ModBallotLine = store.definitions.ModBallotLine

########################################################################################################################

module.exports = class ModBallotLoader

    constructor: (@db)->
        if not @db? then throw new Error "db is required"

    # Class Methods ################################################################################

    @loadFrom: (db)->
        loader = new ModBallotLoader db
        return loader.load()

    # Public Methods ###############################################################################

    load: ->
        query = """
            select m.id as "modId", m.name as name, m.url as url, cast(count(mv.id) as Integer) as "voteCount"
            from "Mods" m join "ModVotes" mv on mv."modId" = m.id
            group by m.id, m.name, m.url
            order by "voteCount" desc, name
        """

        @db.raw(query).then (resultSet)->
            ballot = ModBallot.createInstance id:Date.now(), lines:[]
            for row in resultSet.rows
                ballot.lines.push ModBallotLine.createInstance _.extend {ballotId:ballot.id}, row

            return ballot
