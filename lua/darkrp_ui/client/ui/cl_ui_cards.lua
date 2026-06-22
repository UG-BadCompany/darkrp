DarkRPUI=DarkRPUI or {}; DarkRPUI.UI=DarkRPUI.UI or {}
-- Component module intentionally extends the shared DarkRPUI.UI library with named, reusable primitives.
function DarkRPUI.UI.HorizontalCard(parent,title,body,accent,click) local c=DarkRPUI.UI.MakeAnimatedCard(parent,title,body); c:SetTall(72); c.DoClick=click or c.DoClick; c.Accent=accent; return c end
function DarkRPUI.UI.MakeHUDCard(x,y,w,h,title,body,col) DarkRPUI.UI.ShadowedBox(18,x,y,w,h,DarkRPUI.WithAlpha(DarkRPUI.Color("panel"),238),col or DarkRPUI.Color("border"),105); surface.SetDrawColor(col or DarkRPUI.Color("accent")); surface.DrawRect(x,y+10,4,h-20); DarkRPUI.UI.Text(title,"DarkRPUI.Small",x+14,y+9,col or DarkRPUI.Color("accent")); DarkRPUI.UI.Text(body,"DarkRPUI.Tiny",x+14,y+32,DarkRPUI.Color("subtext")) end
