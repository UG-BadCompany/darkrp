-- by p1ng :D

CAMI.RegisterPrivilege({
    Name = 'onyx_scoreboard_edit',
    MinAccess = 'superadmin',
    Description = 'Allows to configure Onyx Scoreboard'
})

onyx.scoreboard:RegisterOption('title', {
    title = 'scoreboard.title.name',
    desc = 'scoreboard.title.desc',
    category = 'General',
    cami = 'onyx_scoreboard_edit',
    type = 'string',
    default = 'ONYX SCOREBOARD'
})

onyx.scoreboard:RegisterOption('scale', {
    title = 'scoreboard.scale.name',
    desc = 'scoreboard.scale.desc',
    category = 'General',
    cami = 'onyx_scoreboard_edit',
    type = 'int',
    default = 100,
    min = 80,
    max = 130
})

onyx.scoreboard:RegisterOption('group_teams', {
    title = 'scoreboard.group_teams.name',
    desc = 'scoreboard.group_teams.desc',
    category = 'General',
    cami = 'onyx_scoreboard_edit',
    type = 'bool',
    default = true
})

onyx.scoreboard:RegisterOption('colored_players', {
    title = 'scoreboard.colored_players.name',
    desc = 'scoreboard.colored_players.desc',
    category = 'General',
    cami = 'onyx_scoreboard_edit',
    type = 'bool',
    default = true
})

onyx.scoreboard:RegisterOption('blur', {
    title = 'scoreboard.blur.name',
    desc = 'scoreboard.blur.desc',
    category = 'General',
    cami = 'onyx_scoreboard_edit',
    type = 'bool',
    default = false
})