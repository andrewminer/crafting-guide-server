{Logger} = require 'crafting-guide-common'
fs       = require 'fs'

global._      = require 'underscore'
global.logger = new Logger level:Logger.DEBUG
global.util   = require 'util'
global.w      = require 'when'

_.mixin require('crafting-guide-common').stringMixins

for line in fs.readFileSync('.env', 'utf8').split('\n')
    [key, value] = line.split '='
    process.env[key] = value

GitHubClient = require './src/models/github_client'
client = new GitHubClient accessToken:process.env.GITHUB_TEST_TOKEN

client.fetchCurrentUser()
    .then (userData)->
        logger.info "user data: #{JSON.stringify(userData)}"
    # .then ->
    #     client.fetchFile 'andrewminer', 'crafting-guide-data', 'foo-README.md'
    # .then (file)->
    #     logger.info "retrieved file (#{file.sha}) is:\n\n#{file.content}\n\n"
    #     file.content = 'sample content alpha'
    #
    #     client.updateFile 'andrewminer', 'crafting-guide-data', 'README.md', 'test update', file.content, file.sha
    # .then (response)->
    #     logger.info "response: #{response}"
    #     logger.info "updated"
    .catch (error)->
        logger.error "oops: #{error.stack}"
