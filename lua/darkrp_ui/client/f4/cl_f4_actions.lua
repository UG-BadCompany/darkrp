DarkRPUI=DarkRPUI or {}; DarkRPUI.F4=DarkRPUI.F4 or {}; DarkRPUI.F4.Actions={}
function DarkRPUI.F4.RunCommand(cmd) if cmd and cmd~="" then RunConsoleCommand("say","/"..cmd) end end
function DarkRPUI.F4.ItemName(it) return it and (it.name or it.Name or it.label or it.entity or "Item") or "Item" end
function DarkRPUI.F4.Price(it) return it and (it.price or it.Price or it.pricesep or it.pricewep) end
function DarkRPUI.F4.BuyItem(it) DarkRPUI.F4.RunCommand(it and (it.cmd or it.command)) end
