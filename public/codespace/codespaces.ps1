<#
.SYNOPSIS
Creates a codespace in the main branch of a specified GitHub repository.

.DESCRIPTION
The `New-Codespace` function creates a new codespace in the main branch of a specified GitHub repository using the GitHub CLI (`gh`).

.PARAMETER RepoWithOwner
The repository name with the owner in the format 'owner/repo'.

.EXAMPLE
New-Codespace -RepoWithOwner 'octodemo/mushy-chainsaw'
This example creates a codespace in the main branch of the 'octodemo/mushy-chainsaw' repository.

.NOTES
Requires GitHub CLI (gh) to be installed and authenticated.
#>
function New-DemoCodespace {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$RepoWithOwner,
        [Parameter(Position=1)][string]$DisplayName
    )

    "Creating codespace in the main branch of $RepoWithOwner" | Write-Verbose

    $ghCommand = "gh cs create -b main -m 'standardLinux32gb' -R $RepoWithOwner"
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('DisplayName')) {
        $ghCommand += " --display-name '$DisplayName'"
    }

    $result = Invoke-Expression $ghCommand

    $result | Write-Verbose

    return $result
} Export-ModuleMember -Function 'New-DemoCodespace'


function Get-DemoCodespaces {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$owner = 'octodemo'
    )

    "Getting codespaces in the $RepoWithOwner repository" | Write-Verbose

    $json = gh cs list --json name,displayName,owner,repository

    $json | Write-Verbose

    $codespaces = $json | ConvertFrom-Json -Depth 10

    $result = $codespaces | Where-Object { $_.repository -Like "$owner/*" } | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.name
            DisplayName = $_.displayName
            Owner = $_.owner
            Repository = $_.repository
        }
    }

    $result | Write-Verbose

    return $result
} Export-ModuleMember -Function 'Get-DemoCodespaces'