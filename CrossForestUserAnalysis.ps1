#############################################################
# Query User Profile Disk Directory                     #   #
# Report UPD Owners in remote domains                  #    #
# Report if UPD Owner is Disabled.                    #     #
######################################################      #
# Alex Tester                                         #     #
# 2/17/2017                                            #    #
# Future Additions/Plans:                               #   #
# 1. Add Try/Catch for users in other domains/deleted    #  #
# 2. Paramaterize inputs/individual collection targeting  # #
# 3. Purge inactive profiles after query                   ## 
#############################################################
# Not a function, but a few useful samples I was able to find in my notes.
# Also, this sadly doesn't include the get-aduser switch for remote domains.
# Never made a copy of completed, more simplified version


$UPDir=""
$QueryDir=""
$UserArray=""
$SIDArray=""
$UPDArray=""
$UPD=""
$SID=""
$SIDObj=""
$RDAppCollection=""
$UserArr=@()
$UsrResults=@()
$DisabledDetails=@()
$DisabledResults=@()
$NonTranslatedDetails=@()
$NonexistentDetails=@()


#List of SIDs, or names of user profile disks from filesystem to skip checking
$SID_IGNORE=@("template")


#Working location to write/read from and generate our final results
#Do not append a backslash to this path
#Filename is the name of the RDAppCollection.csv

$LogPath=("C:\WorkInProgress\UPDAudit")

# Name of the application collection we are targeting. This name 
# corresponds to the folder where UPDs are located


$RDAppCollections=@(Get-Content C:\WorkInProgress\UPDAudit\Collections.txt)

ForEach ($RDAppCollection in $RDAppCollections)
{
#$RDAppCollection=("acctapps")

#User Profile Disk Root Path for Collections we are interested in
#STOP MAKING YOUR SHIT TOUCH PRODUCTION. GATHER A FUCKING LIST BEFOREHAND, OR A SAFER WAY
$RDSShare=""
#Also, $RDSShare needs to be defined
$UPDir=("$RDSShare\$RDAppCollection")

$QueryDir=(Get-ChildItem $UPDir | select name)

$UserArray=[System.Collections.ArrayList]@()
$SIDArray=[System.Collections.ArrayList]@()
$UPDArray=[System.Collections.ArrayList]@()

$results=[System.Collections.ArrayList]@()

    #THIS NEEDS A FUCKING ALL CAPS COMMENT TO REMOVE LATER.
    #DID WE ALREADY RESOLVE THIS SID? LETS NOT DO IT AGAIN IN EACH COLLECTION.

ForEach ($UPD in $QueryDir){
  $sid = $UPD.Name
  $sid = $sid.Substring(5,$sid.Length-10)
  
  #if ($sid -ne "template")
  #CHANGE 3.8.2017 
  #DEFINE $SID_IGNORE IGNORE LIST AND REPLACE "TEMPLATE"
  if ($sid -ne $SID_IGNORE)
    {
 

    $UPDArray.Add($UPD.Name)
    $SIDArray.Add($SID)
  #Translate SID to Username
  
    Try {
  $SIDObj = new-object security.principal.securityidentifier $SID
  $User = ( $SIDObj.translate([security.principal.ntaccount]) )
        }

    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
        Write-Warning "Unable to translate SID for $User"
        $NonTranslatedDetails = @{            
                UserName             = $User             
                Enabled              = "SID NOT TRANSLATE"
                #SID NOT TRANSLATE ISNT SOMETHING WE WANT TO SEE. CONTINUE A FEW MORE CHECKS WITH THIS USER FIRST
                #IGNORE COMMON/SYSTEM/ADMIN SIDs
 #AT THE END WE SHOULD SEE NO "SID NOT TRANSLATE"
 #BE CONFIDENT THEY NOT EXIST.             

  }
       $DisabledResults+= New-Object PSObject -Property $NonTranslatedDetails
       #Add more SID VALIDATIONS (SIDHISTORY DAWG)
  }
  # Catch{} 

  #this might have been commented out?
  
  $UserArray.Add($User.Value)
        $Details = @{            
                UserName             = $User.value             
                UserSID              = $SID               
                UPDPath              = $UPD.Name
       
        }                           
        $Results+=New-Object PSObject -Property $Details 
    }
}
  

$Results | select username, usersid, updpath | Export-Csv $LogPath\$RDAppCollection.csv



$ImportedInfo=Import-Csv -Delimiter "," -Header @("UserName","UserSID","UPDPath") -Path $LogPath\$RDAppCollection.csv

#Use two backslashes because backslask = regex escape character
#Also, using a filter where SID like $x is more logical way of separating users in remote domains
$OutString = $ImportedInfo.UserName -replace "DOMAIN1\\",""
$OutString = $OutString -replace "DOMAIN2\\",""
$OutString = $OutString -replace "DOMAIN3\\",""
$OutString = $OutString -replace "DOMAIN4\\",""
$OutString = $OutString -replace "DOMAIN5\\",""
$OutString.Trim()
ForEach ($Usr in $OutString){
  Try{ 
      $UsrObj=Get-ADUser $Usr | select name, enabled, sid
      if ($UsrObj.Enabled -eq $False)
        {
     
        $DisabledDetails = @{            
                UserName             = $Usr             
                Enabled              = $UsrObj.enabled   
                SID                  = $UsrObj.SID

                            }
       $DisabledResults+= New-Object PSObject -Property $DisabledDetails 
      }                            
           
#That got messy
     }
  
  Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
  {
  Write-Warning "AD User $Usr Not Found"
        $NonexistentDetails = @{            
                UserName             = $Usr             
                Enabled              = "NOT EXIST"             

                               }
       #$DisabledResults+= New-Object PSObject -Property $NonexistentDetails 
        $NonexistentResults+= New-Object PSObject -Property $NonexistentDetails 
  }
  catch{} 
}

$DisabledResults | Out-File $LogPath\$RDAppCollection-DisksToPurge.txt
$NonexistentResults | Out-File $LogPath\$RDAppCollection-Nonexistent.txt

#Clear variables before moving to next collection. 3.4.2017
$DisabledDetails=""
$DisabledResults=""
$NonexistentDetails=""
$NonexistentResults=""
}
#Clean your room when you're done
#Remove-Item $LogPath\$RDAppCollection.csv
