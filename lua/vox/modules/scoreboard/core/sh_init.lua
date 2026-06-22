-- by p1ng :D

CAMI.RegisterPrivilege({
    Name = 'vox_scoreboard_edit',
    MinAccess = 'superadmin',
    Description = 'Allows to configure Vox Scoreboard'
})

vox.scoreboard:RegisterOption('title', {
    title = 'scoreboard.title.name',
    desc = 'scoreboard.title.desc',
    category = 'General',
    cami = 'vox_scoreboard_edit',
    type = 'string',
    default = 'Vox Scoreboard'
})

vox.scoreboard:RegisterOption('scale', {
    title = 'scoreboard.scale.name',
    desc = 'scoreboard.scale.desc',
    category = 'General',
    cami = 'vox_scoreboard_edit',
    type = 'int',
    default = 100,
    min = 80,
    max = 130
})

vox.scoreboard:RegisterOption('group_teams', {
    title = 'scoreboard.group_teams.name',
    desc = 'scoreboard.group_teams.desc',
    category = 'General',
    cami = 'vox_scoreboard_edit',
    type = 'bool',
    default = true
})

vox.scoreboard:RegisterOption('colored_players', {
    title = 'scoreboard.colored_players.name',
    desc = 'scoreboard.colored_players.desc',
    category = 'General',
    cami = 'vox_scoreboard_edit',
    type = 'bool',
    default = true
})

vox.scoreboard:RegisterOption('blur', {
    title = 'scoreboard.blur.name',
    desc = 'scoreboard.blur.desc',
    category = 'General',
    cami = 'vox_scoreboard_edit',
    type = 'bool',
    default = true
})
