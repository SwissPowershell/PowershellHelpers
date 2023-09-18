
# Default Vars
# [String] $LORepository = 'LO.WKS.Packaging.PowershellModules'
Function Get-IsElevated {([System.Security.Principal.WindowsPrincipal]($([System.Security.Principal.WindowsIdentity]::GetCurrent()))).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)}
[Boolean] $IsAdmin = Get-IsElevated

# rewrite the default color for host Warning and verbose as in some host they are less visible
$Host.PrivateData.WarningForegroundColor = [System.ConsoleColor]::Yellow
$Host.PrivateData.VerboseForegroundColor = [System.ConsoleColor]::Cyan

# Welcome page
Function Show-WelcomePage {
    $MainColor = [ConsoleColor]::Yellow
    $AltColor = [ConsoleColor]::Green
    $CurrentUser = $Env:USERNAME.Replace('admin','').Replace('wks','')
    $UserName = "$($CurrentUser.Substring(0,1).ToUpper())$($CurrentUser.Substring(1))"
    $ComputerName = $Env:COMPUTERNAME
    #MainTitle
    $WelcomeText = "Welcome [] on []"
    $WelcomeArray = $WelcomeText.Split("[]") | Where-object {$_} | ForEach-Object {$_.Trim()}
    #NameValueSplitter
    $NameValueSplitter = " : "
    #SubTitles (Names)
    $RunAsUsertitle = "User Name"
    $PSVersionTitle = "PS Version"
    $HostNameTitle = "Host Name"
    $HostVersionTitle = "Host Version"
    # $RepositoryTitle = "`$LoRepository"
    $Names = @($RunAsUsertitle,$PSVersionTitle,$HostNameTitle,$HostVersionTitle)
    #SubTitles (Values)
    if ($IsAdmin) {
        $RunAsUser = "$($Env:USERNAME.Substring(0,1).ToUpper())$($Env:USERNAME.Substring(1)) (ELEVATED)"
    }Else{
        $RunAsUser = "$($Env:USERNAME.Substring(0,1).ToUpper())$($Env:USERNAME.Substring(1))"
    }
    $PSVersion = $PSVersionTable.PSVersion.ToString()
    $HostObject = Get-Host
    $HostName = $HostObject | Select-Object -ExpandProperty Name
    $HostVersion = ($HostObject | Select-Object -ExpandProperty Version).ToString()
    $Values = @($RunAsUser,$PSVersion,$HostName,$HostVersion)
    #Borders
    $TopLeft     = [char]0x2554
    $HLineTop    = [char]0x2550
    $TopRight    = [char]0x2557
    $VLineLeft   = [char]0x2551
    $VLineRight  = [char]0x2551
    $BottomLeft  = [char]0x255a
    $BottomRight = [char]0x255d
    $HLineBottom = [char]0x2550
    #Length
    $MainTitleLength = $WelcomeText.Length + $UserName.Length + $ComputerName.Length
    $NamesMaxLength = $Names | Sort-Object -Property Length | Select-Object -Last 1 | Select-Object -ExpandProperty Length
    $ValuesMaxLength = $Values | Sort-Object -Property Length | Select-Object -Last 1 | Select-Object -ExpandProperty Length
    $NameValueLongerLine = $NamesMaxLength + $ValuesMaxLength + $NameValueSplitter.length
    #Define wich from Title or namevalue is longer
    $NameValueExtraMargin = 0
    $TitleExtraMargin = 0
    $LengthDifference = $MainTitleLength - $NameValueLongerLine
    if ($LengthDifference -ge 0) {
        #Main Title is the longer
        $NameValueExtraMargin = $LengthDifference
        $MaxInLineLength = $MainTitleLength
    }Elseif ($LengthDifference -lt 0){
        #Name Value are the longer
        $TitleExtraMargin = [Math]::Abs($LengthDifference)
        $MaxInLineLength = $NameValueLongerLine
    }
    #Margin
    $Margin = 2 #Margin before any text
    $InLineMargin = 4 #Margin between border and text
    $MarginText = "$(' ' * $Margin)"
    $InLineMarginText = "$(' ' * $InLineMargin)"
    #Build the bars
    $BarLength = $InLineMargin + $MaxInLineLength + $InLineMargin
    $TopBar = "$($MarginText)$($TopLeft.ToString())$($HLineTop.ToString() * $BarLength)$($TopRight.ToString())"
    $EmptyBar = "$($MarginText)$($VLineLeft.ToString())$(' ' * $BarLength)$($VLineRight.ToString())"
    $BottomBar = "$($MarginText)$($BottomLeft.ToString())$($HLineBottom.ToString() * $BarLength)$($BottomRight.ToString())"
    # Build The Title
    $TitleLeft = "$($MarginText)$($VLineLeft.ToString())$($InLineMarginText)$($WelcomeArray[0]) ["
    $TitleCenter = "] $($WelcomeArray[1]) ["
    $TitleRight = "]$(' ' * $TitleExtraMargin)$($InLineMarginText)$($VLineRight.ToString())"
    # Write Everything
    Clear-Host
    Write-Host ''
    Write-Host $TopBar -ForegroundColor $MainColor
    Write-Host $EmptyBar -ForegroundColor $MainColor
    #title
    Write-Host $TitleLeft -ForegroundColor $MainColor -NoNewLine
    Write-Host $UserName -ForegroundColor $AltColor -NoNewline
    Write-Host $TitleCenter -ForegroundColor $MainColor -NoNewline
    Write-Host $ComputerName -ForegroundColor $AltColor -NoNewline
    Write-Host $TitleRight -ForegroundColor $MainColor
    Write-Host $EmptyBar -ForegroundColor $MainColor
    For ($i = 0;$i -lt $Names.count;$i++) {
        if ($i -eq ($Names.Count -1)) {
            Write-Host $EmptyBar -ForegroundColor $MainColor
        }
        Write-Host "$($MarginText)$($VLineLeft.toString())$($InLineMarginText)$("{0,-$($NamesMaxLength)}" -f $Names[$i])$($NameValueSplitter)" -ForegroundColor $MainColor -NoNewline
        Write-Host "$("{0,-$($ValuesMaxLength)}" -f $Values[$i])" -ForegroundColor $AltColor -NoNewLine
        Write-Host "$(' ' * $NameValueExtraMargin)$($InLineMarginText)$($VLineRight.ToString())" -ForegroundColor $MainColor
    }
    Write-Host $EmptyBar -ForegroundColor $MainColor
    Write-Host $BottomBar -ForegroundColor $MainColor
    Write-Host ''
}
# Change the prompt for something more sexy
Function Global:Prompt {
    # You can input any special char you want
    [String] $MySpecialChar = [Char]9829
    $DefaultColor = 'Yellow'
    $AdminColor = 'DarkCyan'
    $VarColor = 'Green'
    $SpecialCharColor = 'Red'

    $CurrentDirectory = $(Get-Location)
    Write-Host 'PS [' -ForegroundColor $DefaultColor -NoNewline
    if ($IsAdmin -eq $True){
        Write-Host 'Elevated' -ForegroundColor $AdminColor -NoNewline
        Write-Host '] [' -ForegroundColor $DefaultColor -NoNewline
    }
    Write-Host $($Env:UserName) -ForegroundColor $VarColor -NoNewline
    Write-Host '] ' -ForegroundColor $DefaultColor -NoNewline
    Write-Host $MySpecialChar -ForegroundColor $SpecialCharColor -NoNewline
    Write-Host ' [' -ForegroundColor $DefaultColor -NoNewline
    Write-Host $(Convert-Path $CurrentDirectory) -ForegroundColor $VarColor -NoNewline
    Write-Host ']' -ForegroundColor $DefaultColor -NoNewline
    Write-Host '>' -ForegroundColor $DefaultColor -NoNewline
    Return ' '
}

# Show Welcome page
Show-WelcomePage
