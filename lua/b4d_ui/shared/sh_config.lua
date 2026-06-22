B4DUI = B4DUI or {}
B4DUI.Config = {
    Name="B4D UI", Command="b4d", Currency="$", Theme="Obsidian Blue",
    Links={Donate="https://example.com/donate",Discord="https://discord.gg/example",Forum="https://example.com",Rules="https://example.com/rules"},
    HUD={Main=true,Ammo=true,Agenda=true,Alerts=true,Notifications=true,DoorInfo=true,DoorRadial=true,Overhead=true,PickupHistory=true,Status=true,Timeout=true,Vehicle=true,Voice=true,Votes=true,WeaponSelector=true,LevelXP=true},
    F4={Tabs={"Dashboard","Jobs","Shop","Inventory","Player Upgrades","Donate","Discord","Forum","Rules","Settings","Admin"}},
    Scoreboard={Columns={"Name","Job","Rank","Ping","Wallet"}, Groups={superadmin="Owners",admin="Staff",user="Players"}},
    Admin={DefaultCooldown=1.5, MaxReasonLength=180, MaxDuration=31536000}
}
