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

function Add-IssueDemo {
    [CmdletBinding()]
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

        $result = gh issue create -t $Title -b $Body -l $Labels -R $RepoWithOwner

        $result | Write-Verbose

        return $result
    }
} Export-ModuleMember -Function Add-IssueDemo

function Remove-IssueDemo {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$RepoWithOwner
    )

    "Removing issues from $RepoWithOwner" | Write-Verbose

    $issues = Get-IssueDemo -RepoWithOwner $RepoWithOwner

    foreach ($i in $issues) {

        "Removing issue {0}" -f $i.Url | Write-Verbose

        $issueNumber = $i.number
        $result = gh issue delete $issueNumber -R $RepoWithOwner --yes

        $result | write-verbose

        Write-Output $result
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