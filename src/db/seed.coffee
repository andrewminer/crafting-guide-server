#
# Crafting Guide - seed.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

store = require '../store'
w     = require 'when'

dataLoaded = []

# Mods #################################################################################################################

mods = [
    {
        name: 'Atomic Science'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1285665-1-6-4-atomic-science-nuclear-power-and-antimatter'
    }, {
        name: 'Decocraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1292016-decocraft-2-2-decorations-for-minecraft-halloween'
    }, {
        name: 'Flan\'s Mod'
        url: 'http://flansmod.com/'
    }, {
        name: 'OreSpawn'
        url: 'http://www.orespawn.com/'
    }, {
        name: 'Blood Magic'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1290532-1-7-10-2-1-6-4-blood-magic-v1-3-2-1-updated-apr'
    }, {
        name: 'Ex Nihilio'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1291850-ex-nihilo-the-skyblock-companion-mod'
    }, {
        name: 'MineChem'
        url: 'https://jakimfett.github.io/Minechem/'
    }, {
        name: 'RFTools'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2229562-rftools-dimension-builder-teleportation-crafter'
    }, {
        name: 'Redstone Arsenal'
        url: 'http://teamcofh.com/redstone-arsenal/'
    }, {
        name: 'Bibliocraft'
        url: 'http://www.bibliocraftmod.com/'
    }, {
        name: 'Magical Crops'
        url: 'http://www.curse.com/mc-mods/minecraft/228834-magical-crops'
    }, {
        name: 'Witchery'
        url: 'https://sites.google.com/site/witcherymod/home'
    }, {
        name: 'GregTech'
        url: 'http://forum.industrial-craft.net/index.php?page=Thread&threadID=7156&'
    }, {
        name: 'Botania'
        url: 'http://botaniamod.net/'
    }, {
        name: 'Ars Magica'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1292222-ars-magica-2-version-1-4-0-008-updated-february-6'
    }, {
        name: 'Advent of Ascension'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1286381-aoa-21-new-dimensions-330-mobs-27-bosses-skills'
    }, {
        name: 'QuantumFlux'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2379902-quantumflux-wireless-rf-1-3-3'
    }, {
        name: 'Gany\'s Nether'
        url: 'http://www.curse.com/mc-mods/minecraft/222302-ganys-nether'
    }, {
        name: 'Steve\'s Carts'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1277433-1-6-steves-carts-2-v2-0-0-a123'
    }, {
        name: 'OpenBlocks'
        url: 'https://openmods.info/'
    }, {
        name: 'Immersive Engineering'
        url: 'http://minecraft.curseforge.com/projects/immersive-engineering'
    }, {
        name: 'PneumaticCraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1289696-techmod-pneumaticcraft'
    }, {
        name: 'Pam\'s Harvestcraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1294413-pams-mods-dec-10th-2015-1-7-10lb-the-missing-link'
    }, {
        name: 'Thaumic Energistics'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/wip-mods/2150151-1-7-10-tc4-ae2-thaumic-energistics'
    }, {
        name: 'PowerConverters'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1293983-powerconverters-originally-by-powercrystals'
    }, {
        name: 'Electricraft'
        url: 'https://sites.google.com/site/reikasminecraft/electricraft'
    }, {
        name: 'RotaryCraft'
        url: 'https://sites.google.com/site/reikasminecraft/rotarycraft'
    }, {
        name: 'ReactorCraft'
        url: 'https://sites.google.com/site/reikasminecraft/reactorcraft'
    }, {
        name: 'Thaumcraft'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/1292130-thaumcraft-5-0-3-updated-2015-11-9'
    }, {
        name: 'Gravitation Suite'
        url: 'http://forum.industrial-craft.net/index.php?page=Thread&threadID=6915'
    }, {
        name: 'Draconic Evolution'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2093099-draconic-evolution-1-0-2-snapshot-8'
    }, {
        name: 'McHelicopter'
        url: 'http://mchelicoptermod.weebly.com/'
    }, {
        name: 'Solar Expansion'
        url: 'http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2188753-active-solar-expansion-v1-6a-now-back-and-better'
    }
]

modsLoaded = w.all (store.create 'Mod', mod for mod in mods)
dataLoaded.push modsLoaded

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

# Mod Votes ############################################################################################################

modVotesLoaded = w.join(modsLoaded, usersLoaded).then ->
    w.join store.findAll('Mod'), store.findAll('User')
        .then ([mods, users])->
            rowsLoaded = []
            for mod in mods
                for user in users
                    rowsLoaded.push store.create 'ModVote', modId:mod.id, userId:user.id

            w.all rowsLoaded

dataLoaded.push modVotesLoaded

########################################################################################################################

w.all dataLoaded
    .catch (error) -> console.error "failed to insert seed data: #{error.stack}"
    .then -> process.exit()
