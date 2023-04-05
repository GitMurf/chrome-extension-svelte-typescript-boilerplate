# Read the JSON file and convert it to a PowerShell object
$packageJsonObj = Get-Content -Path package.json -Raw | ConvertFrom-Json

# Add the strings 'Dependencies' and 'Dev Dependencies' to an array to loop through later
$depTypes = @('dependencies', 'devDependencies')

# Loop through each dependency type and print its name and value
foreach ($depType in $depTypes) {
  Write-Host ""
  Write-Host "********** $depType **********"
  Write-Host ""

  foreach ($dep in $packageJsonObj.$depType.psobject.properties) {
    $npmInstallSaveType = if ($depType -eq 'dependencies') { '--save' } else { '--save-dev' }
    $getLatestVersion = npm view $dep.Name versions --json | ConvertFrom-Json | Select-Object -Last 1
    $getLatestStableVersion = npm view $dep.Name version
    $curVerNum = $dep.Value -replace '^([^\d]*)', ''
    Write-Host ""
    Write-Host "$($dep.Name)"
    Write-Host "`tCurrent Version: $curVerNum"
    if ($curVerNum -ne $getLatestStableVersion) {
      Write-Host "`t`tLatest *STABLE* Version: $getLatestStableVersion"
      Write-Host "`t`tTo install latest *STABLE*: npm install $($dep.Name)@latest $npmInstallSaveType"
    }
    else {
      Write-Host "`t`tCurrent Version '$curVerNum' is the latest *STABLE* version already"
    }
    if ($curVerNum -ne $getLatestVersion -and $getLatestVersion -ne $getLatestStableVersion) {
      Write-Host ""
      Write-Host "`t`tLatest *PRE-RELEASE* Version: $getLatestVersion"
      Write-Host "`t`tTo install latest *PRE-RELEASE*: npm install $($dep.Name)@$getLatestVersion $npmInstallSaveType"
    }
    else {
      Write-Host ""
      Write-Host "`t`tCurrent Version '$curVerNum' is the latest *PRE-RELEASE* version already"
    }
  }
  Write-Host ""
}
