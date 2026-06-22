net.Receive('VoxUI.Admin.Notify', function()
    local ok = net.ReadBool()
    local msg = net.ReadString()
    if notification and notification.AddLegacy then
        notification.AddLegacy(msg, ok and NOTIFY_GENERIC or NOTIFY_ERROR, 5)
    end
    surface.PlaySound(ok and 'buttons/button15.wav' or 'buttons/button10.wav')
end)

concommand.Add('vox_admin', function()
    local frame = vgui.Create('vox.Frame')
    frame:SetSize(ScrW() * .62, ScrH() * .68)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle('Vox Admin')

    local body = frame:Add('DPanel')
    body:Dock(FILL)
    body:DockPadding(16, 16, 16, 16)
    body.Paint = function(_, w, h)
        local c = vox:Config('colors')
        draw.RoundedBox(8, 0, 0, w, h, c.primary)
        surface.SetDrawColor(c.accent)
        surface.DrawRect(0, 0, 3, h)
        draw.SimpleText('Admin dashboard • players • inspector • logs • movement • punishment • server • economy settings', 'DermaDefaultBold', 18, 14, c.lightgray)
    end
end)
