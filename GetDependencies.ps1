$allProjectFiles = Get-ChildItem -Path . -Filter *.csproj -exclude *.UnitTests.csproj, *.Specs.csproj -Recurse | Resolve-Path -Relative

$projects = @()

foreach ($projfile in $allProjectFiles)
{
    
    $projectReferences = Select-Xml -Path $projfile -XPath '/Project/ItemGroup/ProjectReference' | ForEach-Object { $_.Node.Include }
    # write-host $projfile
    # write-host $t
    # write-host 

    $projectReferencesArray = @()
    foreach($projRef in $projectReferences)
    {
        $t = $projRef -split "\\"#[IO.Path]::PathSeparator
        $r = $t[$t.Length-1].replace(".csproj","")
        $projectReferencesArray += $r
    }

    Write-Host $r
    $project = @{
        Project = (Get-Item $projfile).Basename
        References = $projectReferencesArray
    }

    $projects += $project
    
}

$nodes = @()
$links = @()
foreach($p in $projects)
{
    $nodes += @{id = $p.Project}

    Write-Host "proj: " + $p.Project
    foreach($r in $p.References)
    {
        $links += @{
            from=$p.Project
            to=$r
        }
        Write-Host "   ref: " + $r
    }
    Write-Host
}

$root = @{
    nodes = $nodes
    links = $links
}
$json = $root | ConvertTo-Json | Out-File -FilePath .\d3js.json
Write-Host $json;

