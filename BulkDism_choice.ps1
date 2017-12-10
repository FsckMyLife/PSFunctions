#Server 2016 requires WMF5


#Cleanup before we even begin
Get-WindowsImage -Mounted  | Dismount-WindowsImage -discard
Start-Sleep -s 10



$WIMCSV=@(Import-Csv -Path "\\notmythinkpad\C$\Scripts\WIMtest.csv")
$choice = ""
while ($choice -notmatch "[y|n]"){
    write-warning "Confirm purging all child items of:"
    $WIMCSV.MntPth
    $choice = read-host "Do you want to continue? (Y/N)"
    }

if ($choice -eq "y"){   
    foreach ($Wim in $WIMCSV){
        [string]$ImgPth=$WIM.ImgPth
        [string]$MntPth=$WIM.MntPth
        [string]$Desc=$WIM.Description
        [string]$SvcPth=$WIM.SvcPth
        [int]$Index=$WIM.Index
        $MntPth=Join-Path -Path $MntPth -ChildPath $Desc
        $MntPth=Join-Path -Path $MntPth -ChildPath $Index
        $ImgPthTst=test-path $ImgPth
        if ($ImgPthTst -eq $true) {
            Write-Host "Image present. Begin $ImgPth"
            try{
                Remove-Item $MntPth
                New-Item -Path $MntPth -ItemType Directory
                Write-Host "Good to go"
                Mount-WindowsImage -ImagePath $ImgPth -Index $Index -Path $MntPth
                Add-WindowsPackage -Path $MntPth -PackagePath $SvcPth -PreventPending
                }
            catch [System.Net.WebException],[System.Exception]{
                Write-Host $_.Exception.message
    }
            finally{
                Write-Host "cleaning up Vars..."
                [string]$ImgPth=""
                [string]$MntPth=""
                [int]$Index=""
                $ImgPthTst=""
                Write-Host "cleaning up Mount directory"
                Start-Sleep -s 10 #Give yourself time while testing
    ####            DISCARDING CHANGES FOR TESTING
                Get-WindowsImage -Mounted  | Dismount-WindowsImage -Save
                }
        }
        elseif ($ImgPthTst -eq $false){
    Write-Warning "Image not exist! $ImgPth"
    $FailedImg+=New-Object -Property $WIM
    }
        }
    }
   else {
   write-host "Cancelled due to user keystroke"
   }