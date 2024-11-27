function Test_Issuedemo_Cicle {

    Assert-SkipTest

    $repoDestination = "octodemo/animated-train"
    $repoSource = "rulasg/dotnet-api-demo"

    Remove-IssueDemo -RepoWithOwner $repoDestination -Verbose
    $result = Get-IssueDemo -RepoWithOwner $repoDestination
    Assert-Count -Expected 0 -Presented $result


    $issues = Get-IssueDemo -RepoWithOwner $repoSource -Verbose
    Assert-Count -Expected 8 -Presented $issues

    $result = $issues | Add-IssueDemo -RepoWithOwner $repoDestination -Verbose

    Assert-count -Expected 8 -Presented $result

}