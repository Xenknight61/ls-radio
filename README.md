# ls-radio

- /rconnect (channel) the radio is connected
- /rleave   leaves the radio

- Don't forget to add the radio as item
- Volume down setting for tokovoip users
- tokovoip_script/src/c_main.lua - add the code below

```
function setVolumeDown()
    if radioVolume <= -20 then
        radioVolume = -20
    else
        radioVolume = radioVolume - 1
    end
    TriggerEvent("TokoVoip:setRadioVolume",radioVolume)
    exports['mythic_notify']:DoHudText('inform', "Volume" .. radioVolume)
end
RegisterNetEvent("TokoVoip:DownVolume");
AddEventHandler("TokoVoip:DownVolume", setVolumeDown);
exports("setRadioVolumeDown", setVolumeDown);

function setVolumeUp()
    if radioVolume >= 0 then
        radioVolume = 0
    else
        radioVolume = radioVolume + 1
    end
    TriggerEvent("TokoVoip:setRadioVolume",radioVolume)
    exports['mythic_notify']:DoHudText('inform', "Volume" .. radioVolume)
end
RegisterNetEvent("TokoVoip:UpVolume");
AddEventHandler("TokoVoip:UpVolume", setVolumeUp);
exports("setRadioVolumeUp", setVolumeUp);
```
