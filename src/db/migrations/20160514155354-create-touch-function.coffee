#
# Crafting Guide - 20160514155354-create-touch-function.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

tools = require '../migration_tools'
w     = require 'when'

########################################################################################################################

exports.up = (db) ->
    db.runSql """
        create or replace function touch_updated_at()
        returns trigger as $$
        begin
            new."updatedAt" = now();
            return new;
        end;
        $$ language 'plpgsql';
    """

exports.down = (db) ->
    db.runSql """
        drop function touch_updated_at
    """
