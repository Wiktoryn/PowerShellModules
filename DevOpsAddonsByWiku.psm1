Import-Module VSTeam

function List-Builds{
    param(
        [Parameter (Mandatory = $true)] [String]$projectName,
        [Parameter (Mandatory = $false)] [Int]$top=10
    )
    Write-Host '--------' $projectName -ForegroundColor Blue
    Get-VSTeamBuild -ProjectName $projectName -Top $top | Format-Table @{
        Label = "Build Definition"
        Expression = 
        {
            switch ($_.Result)
            {
                'failed' { $color = "31"; break }
                'succeeded' { $color = '32'; break }
                'canceled' { $color = "33"; break }
               default { $color = "0" }
            }
            $text = $_.BuildDefinition
            if('Microsoft.VisualStudio.Services.TFS' -eq $text)
            { 
                $text =  '(DevOps)'
            }

            $e = [char]27
            "$e[${color}m$($text)${e}[0m"
        }
    }, @{
        Label = "Build Number"
        Expression = 
        {
            switch ($_.Result)
            {
                'failed' { $color = "31"; break }
                'succeeded' { $color = '32'; break }
                'canceled' { $color = "33"; break }
               default { $color = "0" }
            }
            $e = [char]27
            "$e[${color}m$($_.BuildNumber)${e}[0m"
        }
    }, 'Status', @{
        Label = "Result"
        Expression = 
        {
            switch ($_.Result)
            {
                'failed' { $color = "31"; break }
                'succeeded' { $color = '32'; break }
                'canceled' { $color = "33"; break }
               default { $color = "0" }
            }
            $e = [char]27
            "$e[${color}m$($_.Result)${e}[0m"
        } 
    }, @{
            Label = "Requested by"
            Expression = 
            {
                switch ($_.Result)
                {
                    'failed' { $color = "31"; break }
                    'succeeded' { $color = '32'; break }
                    'canceled' { $color = "33"; break }
                   default { $color = "0" }
                }
                $text = $_.RequestedBy
                if('Microsoft.VisualStudio.Services.TFS' -eq $text)
                { 
                    $text =  '(DevOps)'
                }
    
                $e = [char]27
                "$e[${color}m$($text)${e}[0m"
            }
    }, 'StartTime'
}

function List-AllBuilds{
    param(
        [Parameter (Mandatory = $false)] [Int]$top=10
    )
    List-Builds -ProjectName 'Ben Fox' -Top $top
    List-Builds -ProjectName 'Unity Packages' -Top $top
}

function List-Npm {
    param(
        [Parameter (Mandatory = $true)] [String]$feed
    )
    
    $pkgs = Get-VSTeamPackage -feedName $feed

    if(0 -ne $pkgs.Count)
    {
        Write-Host '--------' $feed -ForegroundColor Blue

        $pkgs | ForEach-Object {
            $pkg = $_
            $ver = Get-VSTeamPackageVersion -feedName $feed -packageId $pkg.Id | Select-Object -First 1
            New-Object -TypeName psobject -Property @{
                PublishDate = $ver.PublishDate
                Version     = $ver.Version
                Listed      = $ver.IsListed
                Name        = $pkg.Name
                Description = $ver.Description
            }
        } | Format-Table 'Name', 'Version', 'PublishDate', 'Description'
    }
}

function List-AllNpm {
    List-Npm 'plottwist.all.core'
    List-Npm 'plottwist.all.code'
    List-Npm 'plottwist.all.art'
    List-Npm 'plottwist.all.ld'

    List-Npm 'plottwist.benfox.core'
    List-Npm 'plottwist.benfox.code'
    List-Npm 'plottwist.benfox.art'
    List-Npm 'plottwist.benfox.ld'
}


Export-ModuleMember -Function List-Builds
Export-ModuleMember -Function List-AllBuilds
Export-ModuleMember -Function List-Npm
Export-ModuleMember -Function List-AllNpm
