#
# Crafting Guide - migration_tools.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

########################################################################################################################

exports.addTimestamps = (db, tableName)->
    db.addColumn tableName, 'createdAt', { type:'datetime', defaultValue:'now()', notNull:true }
    db.addColumn tableName, 'updatedAt', { type:'datetime', defaultValue:'now()', notNull:true }, ->
        db.runSql """
            create trigger touch_updated_at_#{tableName}
            before update on "#{tableName}"
            for each row execute procedure touch_updated_at();
        """

exports.cascadeRules = {onDelete:'CASCADE', onUpdate:'RESTRICT'}