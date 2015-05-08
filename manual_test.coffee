{Logger} = require 'crafting-guide-common'

global._      = require 'underscore'
global.logger = new Logger level:Logger.DEBUG
global.util   = require 'util'
global.w      = require 'when'

_.mixin require('crafting-guide-common').stringMixins

process.env.GITHUB_CLIENT_ID = 'a2a1c5f1bb2d7bd14ebb'
process.env.GITHUB_CLIENT_SECRET = '2f2dfa4971063ea37d02f62a96490db2f4c6593e'

GitHubClient = require './src/models/github_client'
client = new GitHubClient accessToken:'9f4d0506fd09c8ec275557267c39edc05a1576f0'

client.fetchCurrentUser()
    .then (userData)->
        logger.info "user data: #{JSON.stringify(userData)}"
    .then ->
        client.fetchFile 'andrewminer', 'crafting-guide-data', 'README.md'
    .then (file)->
        logger.info "retrieved file (#{file.sha}) is:\n\n#{file.content}\n\n"
        file.content = 'sample content alpha'

        client.updateFile 'andrewminer', 'crafting-guide-data', 'README.md', 'test update', file.content, file.sha
    .then (response)->
        logger.info "response: #{response}"
        logger.info "updated"
    .catch (error)->
        logger.error "oops: #{error.stack}"
