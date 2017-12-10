#Check image and ascertain target index value
$SrcPth="X:\Windows\sources"
dism /Get-WimInfo /WimFile:"$SrcPth\install.esd"

[int]$Index="1"

dism /export-image /SourceImageFile:"$SrcPth\install.esd" /SourceIndex:$Index /DestinationImageFile:"$SrcPth\install.wim" /Compress:max /CheckIntegrity