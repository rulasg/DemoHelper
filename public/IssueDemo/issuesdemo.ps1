<#
.SYNOPSIS
Retrieves issues from a specified GitHub repository.

.DESCRIPTION
The Get-IssueDemo function uses the GitHub CLI to list issues from a specified repository.
It converts the JSON response to PowerShell objects and formats the output.

.PARAMETER RepoWithOwner
The repository name with the owner in the format 'owner/repo'.

.EXAMPLE
Get-IssueDemo -RepoWithOwner 'microsoft/vscode'
This example retrieves issues from the 'microsoft/vscode' repository.

.NOTES
Requires GitHub CLI (gh) to be installed and authenticated.
#>
function Get-IssueDemo {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$RepoWithOwner
    )

    "Getting issues from $RepoWithOwner" | Write-Verbose

    $issuesJson = gh issue list -R $RepoWithOwner --json number,title,body,labels,number,url

    $issues = $issuesJson | ConvertFrom-Json -Depth 10

    "Found {0} issues in $RepoWithOwner" -f $issues.Count | Write-Verbose

    foreach ($i in $issues) {
        $labels = Get-Labels -Labels $i.labels
    
        $ret = $ret | ForEach-Object {
            [PSCustomObject]@{
                Number = if ($null -eq $i.number) { [string]::Empty } else { $i.number }
                Title  = if ($null -eq $i.title) { [string]::Empty } else { $i.title }
                Body   = if ($null -eq $i.body) { [string]::Empty } else { $i.body }
                Labels = if ($null -eq $labels) { [string]::Empty } else { $labels }
                Url    = if ($null -eq $i.url) { [string]::Empty } else { $i.url }
            }
        }

        Write-Output $ret
    }

} Export-ModuleMember -Function Get-IssueDemo

<#
.SYNOPSIS
Adds a new issue to a specified GitHub repository.

.DESCRIPTION
The `Add-IssueDemo` function creates a new issue in a specified GitHub repository using the GitHub CLI (`gh`).

.PARAMETER Title
The title of the issue.

.PARAMETER Body
The body content of the issue.

.PARAMETER Labels
Comma-separated labels to assign to the issue.

.PARAMETER RepoWithOwner
The repository to which the issue will be added, in the format `owner/repo`.

.EXAMPLE
PS> Add-IssueDemo -Title "Bug Report" -Body "There is a bug in the application." -Labels "bug,urgent" -RepoWithOwner "user/repo"

This command creates a new issue in the specified repository with the given title, body, and labels.

.NOTES
Requires the GitHub CLI (`gh`) to be installed and authenticated.
#>
function Add-IssueDemo {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipelineByPropertyName)][string]$Title,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Body,
        [Parameter(ValueFromPipelineByPropertyName)][string]$Labels,

        [Parameter()][string]$RepoWithOwner
    )

    begin{
        "Adding issue to $RepoWithOwner" | Write-Verbose
    }

    process {

        if ($PSCmdlet.ShouldProcess("Add", "gh issue create -t $Title -b <MultilineContet> -l $Labels -R $RepoWithOwner")) {
            $result = gh issue create -t $Title -b $Body -l $Labels -R $RepoWithOwner
            
            $result | Write-Verbose
            
            return $result
        }
        
    }
} Export-ModuleMember -Function Add-IssueDemo

<#
.SYNOPSIS
Removes all issues from a specified GitHub repository.

.DESCRIPTION
The `Remove-IssueDemo` function deletes all issues from a specified GitHub repository using the GitHub CLI (`gh`).

.PARAMETER RepoWithOwner
The repository from which the issues will be removed, in the format `owner/repo`.

.EXAMPLE
PS> Remove-IssueDemo -RepoWithOwner "user/repo"

This command removes all issues from the specified repository.

.NOTES
Requires the GitHub CLI (`gh`) to be installed and authenticated.
#>
function Remove-IssueDemo {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position=0)][string]$RepoWithOwner
    )

    "Removing issues from $RepoWithOwner" | Write-Verbose

    $issues = Get-IssueDemo -RepoWithOwner $RepoWithOwner

    foreach ($i in $issues) {

        if ($PSCmdlet.ShouldProcess("Remove", "gh issue delete $issueNumber -R $RepoWithOwner --yes")) {
            "Removing issue {0}" -f $i.Url | Write-Verbose

            $issueNumber = $i.number
            $result = gh issue delete $issueNumber -R $RepoWithOwner --yes

            $result | write-verbose

            Write-Output $result
        }
    }
} Export-ModuleMember -Function Remove-IssueDemo

function Get-Labels {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][object] $Labels
    )

    process {

        $names = $Labels.Name

        $names = $names | Where-Object { $_ -notmatch '\s' }

        $ret = $names -join ","

        return $ret

    }
}