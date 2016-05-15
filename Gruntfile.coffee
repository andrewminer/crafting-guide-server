#
# Crafting Guide - Gruntfile.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

fs = require 'fs'

########################################################################################################################

module.exports = (grunt)->

    grunt.loadTasks tasks for tasks in grunt.file.expand './node_modules/grunt-*/tasks'

    grunt.config.init

        mochaTest:
            options:
                bail: true
                color: true
                reporter: 'list'
                require: [
                    'coffee-script/register'
                    './test/test_helper.coffee'
                ]
                verbose: true
            src: ['./src/**/*.test.coffee', './test/**/*.test.coffee']

        watch:
            coffee:
                files: ['./src/**/*.coffee', './test/**/*.coffee']
                tasks: ['script:clear', 'test']

    # Compound Tasks ###################################################################################################


    grunt.registerTask 'default', 'by default, grunt will run tests and then start the server',
        ['test', 'start']

    grunt.registerTask 'deploy', 'deploy to both staging and production via CircleCI',
        ['deploy:staging', 'deploy:prod']

    grunt.registerTask 'deploy:prod', 'deploy the project to production via CircleCI',
        ['script:deploy:prod']

    grunt.registerTask 'deploy:staging', 'deploy the project to staging via CircleCI',
        ['script:deploy:staging']

    grunt.registerTask 'deploy:staging', 'deploy the project to staging via CircleCI',
        ['script:deploy:staging']

    grunt.registerTask 'start', 'starts the local server',
        ['script:start']

    grunt.registerTask 'test', 'run unit tessts',
        ['script:create-test-db', 'mochaTest']

    grunt.registerTask 'use-local-deps', 'run unit tessts',
        ['script:use-local-deps']

    # Script Tasks #####################################################################################################

    grunt.registerTask 'script:clear', "clear the current terminal buffer", ->
      done = this.async()
      grunt.util.spawn cmd:'clear', opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:create-test-db', "create a test database as a clone of the local database", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/db', args:['create-test-db'], opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:deploy:prod', "deploy code by copying to the production branch", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/deploy', args:['--prod'], opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:deploy:staging', "deploy code by copying to the staging branch", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/deploy', args:['--staging'], opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:start', "starts running a local server on port ", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/start', opts:{stdio:'inherit'}, (error)-> done(error)

    grunt.registerTask 'script:use-local-deps', "use local dependencies instead of NPM dependencies", ->
      done = this.async()
      grunt.util.spawn cmd:'./scripts/use_local_deps', opts:{stdio:'inherit'}, (error)-> done(error)
