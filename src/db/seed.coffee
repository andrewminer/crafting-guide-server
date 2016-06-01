#
# Crafting Guide - seed.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

{Logger}      = require 'crafting-guide-common'
global.logger = new Logger level:Logger.WARNING

w = require 'when'
global.Promise = w.Promise

store   = require '../store'
Mod     = store.definitions.Mod
ModVote = store.definitions.ModVote
User    = store.definitions.User

dataLoaded = []

# ModVotes #############################################################################################################

modVotes = [
    {
        name: 'Atomic Science'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1285665-1-6-4-atomic-science-nuclear-power-and-antimatter'
        voteCount: 2
    }, {
        name: 'Decocraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1292016-decocraft-2-2-decorations-for-minecraft-halloween'
        voteCount: 3
    }, {
        name: 'Flan\'s Mod'
        url: 'http://flansmod.com/'
        voteCount: 4
    }, {
        name: 'OreSpawn'
        url: 'http://www.orespawn.com/'
        voteCount: 5
    }, {
        name: 'Blood Magic'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1290532-1-7-10-2-1-6-4-blood-magic-v1-3-2-1-updated-apr'
        voteCount: 4
    }, {
        name: 'Ex Nihilio'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1291850-ex-nihilo-the-skyblock-companion-mod'
        voteCount: 5
    }, {
        name: 'MineChem'
        url: 'https://jakimfett.github.io/Minechem/'
        voteCount: 5
    }, {
        name: 'RFTools'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2229562-rftools-dimension-builder-teleportation-crafter'
        voteCount: 11
    }, {
        name: 'Redstone Arsenal'
        url: 'http://teamcofh.com/redstone-arsenal/'
        voteCount: 5
    }, {
        name: 'Bibliocraft'
        url: 'http://www.bibliocraftmod.com/'
        voteCount: 7
    }, {
        name: 'Magical Crops'
        url: 'http://www.curse.com/mc-mods/minecraft/228834-magical-crops'
        voteCount: 8
    }, {
        name: 'Witchery'
        url: 'https://sites.google.com/site/witcherymod/home'
        voteCount: 7
    }, {
        name: 'GregTech'
        url: 'http://forum.industrial-craft.net/index.php?page=Thread&threadID=7156&'
        voteCount: 18
    }, {
        name: 'Botania'
        url: 'http://botaniamod.net/'
        voteCount: 22
    }, {
        name: 'Ars Magica'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1292222-ars-magica-2-version-1-4-0-008-updated-february-6'
        voteCount: 1
    }, {
        name: 'Advent of Ascension'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1286381-aoa-21-new-dimensions-330-mobs-27-bosses-skills'
        voteCount: 1
    }, {
        name: 'Gany\'s Nether'
        url: 'http://www.curse.com/mc-mods/minecraft/222302-ganys-nether'
        voteCount: 1
    }, {
        name: 'Steve\'s Carts'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1277433-1-6-steves-carts-2-v2-0-0-a123'
        voteCount: 6
    }, {
        name: 'OpenBlocks'
        url: 'https://openmods.info/'
        voteCount: 6
    }, {
        name: 'Immersive Engineering'
        url: 'http://minecraft.curseforge.com/projects/immersive-engineering'
        voteCount: 1
    }, {
        name: 'PneumaticCraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1289696-techmod-pneumaticcraft'
        voteCount: 6
    }, {
        name: 'Pam\'s Harvestcraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1294413-pams-mods-dec-10th-2015-1-7-10lb-the-missing-link'
        voteCount: 9
    }, {
        name: 'Thaumic Energistics'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/wip-mods/2150151-1-7-10-tc4-ae2-thaumic-energistics'
        voteCount: 1
    }, {
        name: 'PowerConverters'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1293983-powerconverters-originally-by-powercrystals'
        voteCount: 1
    }, {
        name: 'Electricraft'
        url: 'https://sites.google.com/site/reikasminecraft/electricraft'
        voteCount: 1
    }, {
        name: 'RotaryCraft'
        url: 'https://sites.google.com/site/reikasminecraft/rotarycraft'
        voteCount: 1
    }, {
        name: 'ReactorCraft'
        url: 'https://sites.google.com/site/reikasminecraft/reactorcraft'
        voteCount: 1
    }, {
        name: 'Thaumcraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1292130-thaumcraft-5-0-3-updated-2015-11-9'
        voteCount: 23
    }, {
        name: 'Gravitation Suite'
        url: 'http://forum.industrial-craft.net/index.php?page=Thread&threadID=6915'
        voteCount: 5
    }, {
        name: 'Draconic Evolution'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2093099-draconic-evolution-1-0-2-snapshot-8'
        voteCount: 12
    }, {
        name: 'McHelicopter'
        url: 'http://mchelicoptermod.weebly.com/'
        voteCount: 1
    }, {
        name: 'Solar Expansion'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2188753-active-solar-expansion-v1-6a-now-back-and-better'
        voteCount: 7
    }, {
        name: 'Pixelmon'
        url: 'http://pixelmonmod.com/wiki/index.php?title=Main_Page'
        voteCount: 1
    }, {
        name: 'Chocolate Quest'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1278075-chocolate-quest-mods-for-the-adventurers'
        voteCount: 1
    }, {
        name: 'Better Than Wolves'
        url: 'http://sargunster.com/btw/index.php?title=Main_Page'
        voteCount: 1
    }, {
        name: 'Progressive Automation'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2076388-progressive-automation-upgradeable-machines'
        voteCount: 1
    }, {
        name: 'Eccentric Biomes'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2562287-eccentric-biomes-mod'
        voteCount: 1
    }
]

createModVote = (modId, count)->
    return w(true) if count is 0
    User.create name:'Anonymous Voter'
        .then (user)->
            ModVote.create modId:modId, userId:user.id
        .then (modVote)->
            createModVote modId, count - 1

loadModVotes = (remaining)->
    modVote = remaining.pop()
    return w(true) unless modVote?

    Mod.create name:modVote.name, url:modVote.url
        .then (mod)->
            createModVote mod.id, modVote.voteCount
        .then (modVotes)->
            loadModVotes remaining

dataLoaded.push loadModVotes(modVotes)

# Users ################################################################################################################

users = [
    {
        avatarUrl:   'https://avatars.githubusercontent.com/u/445000?v=3'
        email:       'andrewminer@mac.com'
        gitHubId:    445000
        gitHubLogin: 'andrewminer'
        name:        'Andrew Miner'
    }
]

usersLoaded = w.all (store.create 'User', user for user in users)
dataLoaded.push usersLoaded

########################################################################################################################

w.all dataLoaded
    .catch (error) -> console.error "failed to insert seed data: #{error.stack}"
    .then -> process.exit()
