-- by p1ng :D

onyx.scoreboard:Print('Loaded SQL configuration.')

local MySQL = {Credentials = {}}

-- Enable MySQL
-- (requires `mysqloo` module and mysql database)
MySQL.Enabled = false

-- MySQL Credentials
MySQL.Credentials.Hostname  = ''
MySQL.Credentials.Username  = ''
MySQL.Credentials.Password  = ''
MySQL.Credentials.Schema    = ''
MySQL.Credentials.Port      = 3306

--[[------------------------------
DO NOT TOUCH STUFF BELOW
--------------------------------]]
onyx.scoreboard:SetupDatabase(MySQL.Enabled, MySQL.Credentials)