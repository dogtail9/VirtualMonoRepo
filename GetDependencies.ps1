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

    $type = "none"

    $content = Get-Content -Path $projfile -Raw
    if($content.Contains("Microsoft.NET.Sdk.Web"))
    {
      $type = "Web"
    }
    elseif ($content.Contains("Microsoft.NET.Sdk")) {
      $type = "Library"
    }

    $project = @{
        Project = (Get-Item $projfile).Basename
        Type = $type
        References = $projectReferencesArray
    }

    $projects += $project
    
}

$nodes = @()
$links = @()
foreach($p in $projects)
{
    $nodes += @{
      id = $p.Project
      type = $p.Type
    }

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
$root | ConvertTo-Json | Out-File -FilePath .\d3js.json