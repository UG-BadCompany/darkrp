B4DUI = B4DUI or {}; B4DUI.Anim=B4DUI.Anim or {}; function B4DUI.Animate(key,target,speed) B4DUI.Anim[key]=B4DUI.Lerp(B4DUI.Anim[key] or target,target,speed or 12); return B4DUI.Anim[key] end
