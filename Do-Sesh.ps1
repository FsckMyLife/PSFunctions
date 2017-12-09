function Do-Sesh {
  <#
  .SYNOPSIS
  Creates new PSSession and enters in one command. Not all that useful.
  .DESCRIPTION
  Literally just new-pssession and enter-pssession rolled into one
  .EXAMPLE
  Do-Sesh -Server hostname
  .EXAMPLE
  Do-Sesh Computer1
  .PARAMETER Server
  The destination accepting your request.
  #>


  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
      HelpMessage='What computer name would you like to target?')]
    [Alias('host')]
    [ValidateLength(3,30)]
    [string[]]$Server
  )

  process {
  New-PSSession $Server| Enter-PSSession
    }

}
    