## test cache by running https://docs.oracle.com/javase/tutorial/deployment/webstart/examplesIndex.html it should populate the cache dir
Function Set-JavaCacheDir {
    [CMDLetBinding(DefaultParameterSetName='Set')]
    Param(
        [Parameter(
            Mandatory = $False,
            Position = 0,
            ParameterSetName = 'Set'
        )]
        [String] ${CacheDir} = "%Appdata%\..\LocalLow\Sun\Java\Deployment\Cache",
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ParameterSetName = 'Remove'
        )]
        [Switch] ${Remove}
    )
    Function Get-ContentContainsCacheValue {
        [CMDLetBinding()]
        Param(
            [Parameter(
                Mandatory = $True,
                Position = 0
            )]
            [String] ${ToFind},
            [String[]] ${Content}
        )
        ForEach ($Line in $Content) {
            $MatchResult = $Line | Select-String -Pattern $ToFind
            if ($MatchResult) {
                return $MatchResult.Line
                Break
            }
        }
        
    }
    Function Remove-ContentCacheValue {
        [CMDLetBinding()]
        Param(
            [Parameter(
                Mandatory = $True,
                Position = 0
            )]
            [String] ${ToFind},
            [String[]] ${Content}
        )
        $NewContent = @()
        ForEach ($Line in $Content){
            $MatchResult = $Line | Select-String -Pattern $ToFind
            if (-Not $MatchResult) {
                $NewContent += $Line
            }
        }
        return $NewContent
    }
    $ToFind = '^\s*?deployment\.user\.cachedir\s*?=(?<CachePath>.*)$'
    $JavaDeploymentPropertiesPath = "%Appdata%\..\LocalLow\Sun\Java\Deployment"
    # TODO
    # $AltDeploymentPropertiesPath = "%WINDIR%\Sun\Java\Deployment" # Location of deployment.properties for system
    # TODO
    $JavaDeploymentPropertiesFileName = 'deployment.properties'
    $JavaDeploymentPropertiesFullPath = "$($JavaDeploymentPropertiesPath)\$($JavaDeploymentPropertiesFileName)"
    
    Try {
        $JavaDeploymentPropertiesFilePath = Get-Item -Path "$([System.Environment]::ExpandEnvironmentVariables("$JavaDeploymentPropertiesFullPath"))" -ErrorAction Stop | Select-Object -ExpandProperty FullName
    }Catch {
        $JavaDeploymentPropertiesFilePath = $JavaDeploymentPropertiesFullPath
    }
    $JavaDeploymentPropertiesContent = Get-Content -Path $JavaDeploymentPropertiesFilePath
    if ((Test-Path -Path $JavaDeploymentPropertiesFilePath) -eq $False) {
        Throw "There is no file in [$($JavaDeploymentPropertiesFilePath)] the script will exit"
    }Else{
        Write-Host "'$($JavaDeploymentPropertiesFileName)' file fund under [$(Split-Path -Path $JavaDeploymentPropertiesFilePath)]" -ForegroundColor DarkCyan
    }

    if ($Remove -eq $True) {
        $HasKey = $Null -ne (Get-ContentContainsCacheValue -ToFind $ToFind -Content $JavaDeploymentPropertiesContent)
        if ($HasKey -eq $True) {
            Write-Host "Removing Cache dir value from configuration" -ForegroundColor Yellow
            $NewContent = Remove-ContentCacheValue -ToFind $ToFind -Content $JavaDeploymentPropertiesContent
            Set-Content -Value $NewContent -Path $JavaDeploymentPropertiesFilePath -Force | Out-Null
        }Else{
            Write-Host "No Cache value set => Nothing to do" -ForegroundColor Yellow
        }
    }Else{
        if ($CacheDir -like '') {
            Write-Host "Cache Dir cannot be null => Exit" -ForegroundColor Red
            BREAK
        }
        $NewContent = Remove-ContentCacheValue -ToFind $ToFind -Content $JavaDeploymentPropertiesContent
        $CachePath = [System.Environment]::ExpandEnvironmentVariables("$($CacheDir)")
        if ((Test-Path -Path $CachePath) -eq $False) {
            Write-Host "The Cache dir does not exist => Create it..." -ForegroundColor Yellow
            Try {
                $Item = New-Item -Path $CachePath -ItemType Directory -Force -ErrorAction Stop
            }Catch {
                Throw "Unexpected Error ! Unable to create Cache Dir in [$($CachePath)]: $($_.Exception.Message)"
            }
        }Else{
            Try {
                $Item = Get-Item -Path $CachePath -Force -ErrorAction Stop
            }Catch {
                Throw "Unexpected Error ! Unable to retrieve Cache Dir in [$($CachePath)]: $($_.Exception.Message)"
            }
        }
        $CacheDirExpanded = $Item | Select-Object -ExpandProperty FullName
        $ValueToWrite = ([regex]::Escape($CacheDirExpanded)) -Replace '(?<!\\)(?<!\\\\):',"\:"
        $LineToWrite = "deployment.user.cachedir=$($ValueToWrite)"
        $OriginalLine = Get-ContentContainsCacheValue -ToFind $ToFind -Content $JavaDeploymentPropertiesContent
        if ($Null -ne $OriginalLine) {
            if ($OriginalLine -eq $LineToWrite) {
                Write-Host 'The configuration is allready correct => Exit' -ForegroundColor Yellow
                BREAK
            }
        }
        $NewContent += $LineToWrite
        Write-Host "Writing New Value [" -NoNewline -ForegroundColor Yellow
        Write-Host $LineToWrite -NoNewline -ForegroundColor Green
        Write-Host "]" -ForegroundColor Yellow
        Set-Content -Value $NewContent -Path $JavaDeploymentPropertiesFilePath -Force | Out-Null
    }
   
}

Set-JavaCacheDir  # -Remove
