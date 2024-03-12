
#https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
#https://www.w3.org/TR/SVG/paths.html#PathElement

Enum OrganicIconType {
    All
    Administration
    CoreBanking
    GlobalMarkets
    WealthManagement
    Finance
}
Enum IconSize {
    Value1 = 16
    Value2 = 24
    Value3 = 32
    Value4 = 48
    Value5 = 64
    Value6 = 72
    Value7 = 128
    Value8 = 256
}
Class OrganicHelper {
    static [void] GetVertexFromPath($svgPathData){
        $bitmap = New-Object System.Drawing.Bitmap 200, 200
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Parse the SVG path
        $commands = $svgPathData -split 'Z'
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        
        foreach ($command in $commands) {
            $verts = @()
            $codes = @()
            $elements = $command.Trim().Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
        
            $currentPoint = New-Object System.Drawing.PointF(0, 0)
        
            foreach ($element in $elements) {
                $command = $element.Substring(0, 1)
                $coords = $element.Substring(1) -split '[,]'
                
                switch ($command) {
                    "m" {
                        $currentPoint = New-Object System.Drawing.PointF([float]$coords[0], [float]$coords[1])
                        $codes += [System.Drawing.Drawing2D.GraphicsPath]::PathTypeStart
                        $verts += $currentPoint
                    }
                    "L" {
                        $currentPoint = New-Object System.Drawing.PointF([float]$coords[0], [float]$coords[1])
                        $codes += [System.Drawing.Drawing2D.GraphicsPath]::PathTypeLine
                        $verts += $currentPoint
                    }
                    "c" {
                        $codes += [System.Drawing.Drawing2D.GraphicsPath]::PathTypeBezier
                        for ($i = 0; $i -lt $coords.Count; $i += 6) {
                            $startX = $currentPoint.X
                            $startY = $currentPoint.Y
                            $endX = $startX + [float]$coords[$i + 4]
                            $endY = $startY + [float]$coords[$i + 5]
                            $currentPoint = New-Object System.Drawing.PointF($endX, $endY)
                            $verts += New-Object System.Drawing.PointF($startX, $startY)
                            $verts += New-Object System.Drawing.PointF(([float]$coords[$i]), ([float]$coords[$i + 1]))
                            $verts += New-Object System.Drawing.PointF(([float]$coords[$i + 2]), ([float]$coords[$i + 3]))
                            $verts += New-Object System.Drawing.PointF($endX, $endY)
                        }
                    }
                    "h" {
                        $codes += [System.Drawing.Drawing2D.GraphicsPath]::PathTypeLine
                        $currentPoint = New-Object System.Drawing.PointF($currentPoint.X + [float]$coords[0], $currentPoint.Y)
                        $verts += $currentPoint
                    }
                }
            }
        
            $path.AddPath($verts, $codes)
        }
        
        # Draw the path
        $graphics.DrawPath([System.Drawing.Pens]::Black, $path)
        
        # Save the bitmap
        $bitmap.Save("c:\temp\temp.png", [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Cleanup
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}
Class OrganicIcon {
    [OrganicIconType] ${Type} = [OrganicIconType]::Administration
    [String] ${Text}
    [String] ${BorderPath}
    [String] ${ContentPath}
    [String] ${TextColor}
    [String] ${BorderColor}
    [String] ${ContentColor}
    [String] ${FontFamily}
    [int32] ${FontSize}
    [int32] ${FontWeight}
    [Double] ${xTranslate}
    [Double] ${yTranslate}
    [System.Xml.XmlDocument] ${xmlDoc}
    OrganicIcon(){}
    OrganicIcon([string] $Text) {
        $this.Text = $Text
        $this.set()
    }
    OrganicIcon([string] $Text, [OrganicIconType] $Type) {
        $this.Text = $Text
        $this.Type = $Type
        $this.set()
        $this.buildSVG()
    }
    hidden [Void] set() {
        Switch ($this.Type) {
            'Administration' {
                $this.ContentPath = 'M2.38,53.87c-4.41,54.05,15.11,65.21,50.33,65.22,42.07.02,73.55,1.38,73.54-62.65,0-42.16-31.61-47.56-59.65-47.53-28.05.03-61.24,8.47-64.22,44.96Z'
                $this.BorderPath = 'M58.41,120.85c-1.04,0-2.09,0-3.15,0h-2.56c-20.35,0-33.07-3.96-41.24-12.83C1.9,97.63-1.55,80.38.63,53.73h0C3.07,23.74,26.5,7.21,66.59,7.15h.29c16.19,0,36.3,1.66,48.95,14.29,8.07,8.06,12.17,19.83,12.17,34.99,0,25.03-4.63,41.32-14.59,51.27-12.62,12.6-32.22,13.14-55,13.14ZM4.13,54.01c-2.09,25.61,1.06,42.01,9.92,51.63,7.45,8.08,19.37,11.69,38.66,11.7h2.56c23.4.04,43.5.05,55.67-12.11,9.13-9.12,13.56-25.08,13.56-48.79,0-14.19-3.75-25.13-11.14-32.51-11.74-11.72-30.96-13.27-46.47-13.27h-.29c-26.89.03-59.55,7.58-62.47,43.35h0Z'
                $this.TextColor = '#d6d6d6'
                $this.BorderColor = '#d6d6d6'
                $this.ContentColor = '#1e1e1e'
                $this.FontFamily = 'Ubuntu-Medium, Ubuntu'
                $this.FontSize = 42
                $this.FontWeight = 500
                $this.xTranslate = [Double]::parse(30.36)
                $this.yTranslate = [Double]::parse(79.56)
                Break
            }
            'CoreBanking' {
                $this.ContentPath = 'M1.85,54.18c-1.28,45.81,8.22,62.85,50.47,62.85s73.94-3.93,73.94-60.24c0-40.59-31.69-45.83-59.86-45.83S3.02,12.28,1.85,54.18Z'
                $this.BorderPath = 'M52.32,118.77c-19.9,0-32.36-3.68-40.39-11.95C2.75,97.39-.68,82.12.11,54.13H.11C1.37,9.23,40.5,9.23,66.4,9.23c28.68,0,61.6,5.41,61.6,47.57,0,57.41-32.8,61.97-75.68,61.97ZM3.59,54.23c-.75,26.95,2.38,41.48,10.83,50.17,7.33,7.54,19.02,10.9,37.9,10.9,42.28,0,72.2-4.2,72.2-58.5,0-38.85-29.38-44.09-58.12-44.09C33.91,12.71,4.66,15.88,3.59,54.23h0Z'
                $this.TextColor = '#f7b26e'
                $this.BorderColor = '#f7b26e'
                $this.ContentColor = '#1e1e1e'
                $this.FontFamily = 'Ubuntu-Medium, Ubuntu'
                $this.FontSize = 42
                $this.FontWeight = 500
                $this.xTranslate = [Double]::parse(21.87)
                $this.yTranslate = [Double]::parse(78.4)
                Break
            }
            'GlobalMarkets' {
                $this.ContentPath = 'M52.54,119.48c53.74,1.08,73.73-7.42,73.68-45.14-.05-37.72-4.69-66-70.74-65.92C7.86,8.49,1.75,36.78,1.78,61.93c.03,25.14,1.61,56.57,50.76,57.56Z'
                $this.BorderPath = 'M60.77,121.35c-2.65,0-5.39-.03-8.26-.09h0C.07,120.21.03,85.14,0,61.93c-.01-10.48.94-25.74,9.32-37.21C18.19,12.59,33.29,6.68,55.48,6.65h.28c66.85,0,72.2,29.34,72.24,67.69.02,15.67-3.4,26.34-10.77,33.57-9.69,9.51-25.84,13.44-56.46,13.44ZM52.58,117.71c34.53.7,52.53-2.88,62.16-12.34,6.64-6.51,9.72-16.37,9.7-31.02-.05-37.55-5.02-64.14-68.68-64.14h-.28c-20.97.03-35.13,5.46-43.29,16.61C4.51,37.32,3.54,51.1,3.56,61.92c.03,28.88,3.81,54.87,49.02,55.78h0Z'
                $this.TextColor = '#81db62'
                $this.BorderColor = '#81db62'
                $this.ContentColor = '#1e1e1e'
                $this.FontFamily = 'Ubuntu-Medium, Ubuntu'
                $this.FontSize = 42px
                $this.FontWeight = 500
                $this.xTranslate = [Double]::parse(26.87)
                $this.yTranslate = [Double]::parse(80.66)
                Break
            }
            'WealthManagement' {
                $this.ContentPath = 'M126.15,73.82c1.28-45.81-8.22-62.85-50.47-62.85S1.74,14.89,1.74,71.2c0,40.59,31.69,45.83,59.86,45.83s63.38-1.31,64.55-43.21Z'
                $this.BorderPath = 'M61.6,118.77c-28.68,0-61.6-5.41-61.6-47.57C0,13.79,32.8,9.23,75.68,9.23c19.9,0,32.36,3.68,40.39,11.95,9.18,9.44,12.6,24.7,11.82,52.69h0c-1.26,44.9-40.39,44.9-66.29,44.9ZM75.68,12.71C33.41,12.71,3.48,16.9,3.48,71.2c0,38.85,29.38,44.09,58.12,44.09,32.49,0,61.74-3.17,62.82-41.52.75-26.95-2.38-41.48-10.83-50.17-7.33-7.54-19.02-10.9-37.9-10.9Z'
                $this.TextColor = '#69daf5'
                $this.BorderColor = '#69daf5'
                $this.ContentColor = '#1e1e1e'
                $this.FontFamily = 'Ubuntu-Medium, Ubuntu'
                $this.FontSize = 42
                $this.FontWeight = 500
                $this.xTranslate = [Double]::parse(19.29)
                $this.yTranslate = [Double]::parse(79.71)
                Break
            }
            'Finance' {
                $this.BorderPath = 'M75.46,8.52C21.72,7.44,1.73,15.94,1.78,53.66c.05,37.72,4.69,66,70.74,65.92,47.62-.06,53.73-28.35,53.7-53.5-.03-25.14-1.61-56.57-50.76-57.56Z'
                $this.ContentPath = 'M72.25,121.35C5.4,121.35.05,92.01,0,53.66c-.02-15.67,3.4-26.34,10.77-33.57,10.53-10.33,28.66-14.08,64.73-13.35,52.44,1.05,52.48,36.13,52.51,59.34.01,10.48-.94,25.74-9.32,37.21-8.87,12.13-23.97,18.04-46.15,18.07h-.28ZM67.45,10.21c-29.38,0-45.33,3.72-54.19,12.42-6.64,6.51-9.72,16.37-9.7,31.02.05,37.55,5.01,64.14,68.68,64.14h.28c20.97-.03,35.13-5.46,43.28-16.61,7.68-10.5,8.65-24.28,8.64-35.1-.03-28.88-3.81-54.88-49.02-55.78-2.76-.06-5.42-.08-7.97-.08Z'
                $this.TextColor = '#ff6969'
                $this.BorderColor = '#ff6969'
                $this.ContentColor = '#1e1e1e'
                $this.FontFamily = 'Ubuntu-Medium, Ubuntu'
                $this.FontSize = 42
                $this.FontWeight = 500
                $this.xTranslate = [Double]::parse(24.86)
                $this.yTranslate = [Double]::parse(77.99)
                Break
            }
            default {
                Throw "Unknown type [$($this.Type)]"
            }
        }
    }
    hidden [void] buildSVG(){
        # Create a new XML document
        $this.xmlDoc = New-Object System.Xml.XmlDocument

        # Create the XML declaration
        $xmlDeclaration = $this.xmlDoc.CreateXmlDeclaration('1.0', 'UTF-8', $null)
        $this.xmlDoc.AppendChild($xmlDeclaration)

        # Create the root SVG element
        $svgElement = $this.xmlDoc.CreateElement('svg')
        $svgElement.SetAttribute('id', 'Calque')
        $svgElement.SetAttribute('data-name', 'Calque')
        $svgElement.SetAttribute('xmlns', 'http://www.w3.org/2000/svg')
        $svgElement.SetAttribute('viewBox', '0 0 128 128')

        $defsElement = $this.xmlDoc.CreateElement('defs')
        $styleElement = $this.xmlDoc.CreateElement('style')
        $styleElement.InnerText = @"

.text {
    font-family: $($this.FontFamily);
    font-size: $($this.fontsize)px;
    font-weight: $($this.FontWeight);
}

.text, .border {
    fill: $($this.BorderColor);
}

.content {
    fill: $($this.ContentColor);
}

.content, .border {
    stroke-width: 0px;
}
"@
        $defsElement.AppendChild($styleElement)
        $svgElement.AppendChild($defsElement)

        $gElement = $this.xmlDoc.CreateElement('g')
        $contentElement = $this.xmlDoc.CreateElement('path')
        $contentElement.SetAttribute('class', 'content')
        $contentElement.SetAttribute('d', $this.ContentPath)
        $gElement.AppendChild($contentElement)

        $borderElement = $this.xmlDoc.CreateElement('path')
        $borderElement.SetAttribute('class', 'border')
        $borderElement.SetAttribute('d', $this.BorderPath)
        $gElement.AppendChild($borderElement)

        $svgElement.AppendChild($gElement)

        $textElement = $this.GetTextElement()
        $svgElement.AppendChild($textElement)
        $this.xmlDoc.AppendChild($svgElement)
    }
    hidden [System.Xml.XmlElement] GetTextElement(){
        $textElement = $this.xmlDoc.CreateElement('text')
        $textElement.SetAttribute('class', 'text')
        $textElement.SetAttribute('transform', "translate($($this.xTranslate) $($this.yTranslate))")
        $tspanElement = $this.xmlDoc.CreateElement('tspan')
        $tspanElement.SetAttribute('x', '0')
        $tspanElement.SetAttribute('y', '0')
        $tspanElement.InnerText = $this.Text
        $textElement.AppendChild($tspanElement)
        return $textElement
    }
    [void] SaveSVG($Path){
        $this.xmlDoc.Save($Path)
    }
    [void] SavePNG($Path){
        $BorderVertex = [OrganicHelper]::GetVertexFromPath($this.BorderPath)
    }
}

Function New-ExampleFunction {
    [CMDLetBinding()]
    Param(

    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now ; Write-Verbose "Entering : $($MyInvocation.MyCommand)"
        #endregion Function initialisation DO NOT REMOVE
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($MyInvocation.MyCommand)"
        #endregion Function Processing DO NOT REMOVE
    }
    END {
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue;$TimeUnits = [ORDERED] @{TotalDays = "$($TimeSpentinFunc.TotalDays) D.";TotalHours = "$($TimeSpentinFunc.TotalHours) h.";TotalMinutes = "$($TimeSpentinFunc.TotalMinutes) min.";TotalSeconds = "$($TimeSpentinFunc.TotalSeconds) s.";TotalMilliseconds = "$($TimeSpentinFunc.TotalMilliseconds) ms."}
        ForEach ($Unit in $TimeUnits.GetEnumerator()) {if ($TimeSpentinFunc.($Unit.Key) -gt 1) {$TimeSpentString = $Unit.Value;break}};if (-not $TimeSpentString) {$TimeSpentString = "$($TimeSpentinFunc.Ticks) Ticks"}
        Write-Verbose "Ending : $($MyInvocation.MyCommand) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing DO NOT REMOVE
        #region outputing

        #endregion outputing
    }
}

Function New-PortalIcon {
    [CMDLetBinding()]
    Param(
        [OrganicIconType] ${IconType} = [OrganicIconType]::All,
        [String] ${Text} = 'Tax',
        [String] ${Name} = 'Tax',
        [ValidateSet(0,16,24,32,48,64,72,128,256)]
        [int32] ${Size} = 0,
        [String] ${OutPath} = 'C:\Temp'
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now ; Write-Verbose "Entering : $($MyInvocation.MyCommand)"
        #endregion Function initialisation DO NOT REMOVE
        $Process = $True
        if ($Process) {
            if ($Size -eq 0) {
                ForEach($desiredSize in @(16,24,32,48,64,72,128,256)) {
                    New-PortalIcon -IconType $IconType -Text $Text -Size $desiredSize -Name $Name
                }
                $Process = $False
            }
        }
        if ($Process) {
            if ($IconType -eq [OrganicIconType]::All) {
                $AllIconType = [Enum]::GetValues([OrganicIconType]) | Where-Object {$_ -ne [OrganicIconType]::All}
                ForEach ($desiredIconType in $AllIconType){
                    New-PortalIcon -IconType $desiredIconType -Text $Text -Size $Size -Name $Name
                }
                $Process = $False
            }
        }
        if ($Process){
            Add-Type -AssemblyName System.Drawing
            Add-Type -AssemblyName System.Windows.Forms
        }
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($MyInvocation.MyCommand)"
        #endregion Function Processing DO NOT REMOVE
        if ($Process){
            $iconDefinition = [OrganicIcon]::new($Text,$IconType)
            $pngFileName = "$($OutPath)\$($IconType.ToString())_$($Text)_$($Name).png"
            $tempFileName = [System.IO.Path]::GetTempFileName()
            $svgFileName = $tempFileName -replace '\.tmp$','.svg'
            $iconDefinition.SaveSVG($svgFileName)
            $iconDefinition.SavePNG($pngFileName)
            # $iconDefinition.xmlDoc.Save($svgFileName)
            # Write-Verbose "SVG Image temporary saved to: $($svgFileName)"
            # Convert-SvgToPng -svgFilePath $svgFileName -pngFilePath $pngFilePath
        }
    }
    END {
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue;$TimeUnits = [ORDERED] @{TotalDays = "$($TimeSpentinFunc.TotalDays) D.";TotalHours = "$($TimeSpentinFunc.TotalHours) h.";TotalMinutes = "$($TimeSpentinFunc.TotalMinutes) min.";TotalSeconds = "$($TimeSpentinFunc.TotalSeconds) s.";TotalMilliseconds = "$($TimeSpentinFunc.TotalMilliseconds) ms."}
        ForEach ($Unit in $TimeUnits.GetEnumerator()) {if ($TimeSpentinFunc.($Unit.Key) -gt 1) {$TimeSpentString = $Unit.Value;break}};if (-not $TimeSpentString) {$TimeSpentString = "$($TimeSpentinFunc.Ticks) Ticks"}
        Write-Verbose "Ending : $($MyInvocation.MyCommand) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing DO NOT REMOVE
        #region outputing
        #endregion outputing
    }
}

function Convert-SvgToPng2 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$svgFilePath,

        [Parameter(Mandatory=$true)]
        [string]$pngFilePath,

        [int]$width = 300,
        [int]$height = 300
    )

    # Read the SVG file content
    $svgContent = Get-Content -Path $svgFilePath -Raw

    # Parse the SVG content to extract vertex data
    # (This is a simplified example and may not handle all SVG features)
    $vertices = @()
    $matcheresults = [regex]::Matches($svgContent, '<path d="(.*?)"')
    foreach ($match in $matcheresults) {
        $pathData = $match.Groups[1].Value
        $vertices += Convert-SvgPathData $pathData
    }

    # Create a blank bitmap
    $bitmap = New-Object System.Drawing.Bitmap $width, $height

    # Draw the SVG vertices onto the bitmap
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::Black)

    foreach ($vertex in $vertices) {
        $graphics.DrawLines($pen, $vertex)
    }

    # Save the bitmap as PNG
    $bitmap.Save($pngFilePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Dispose resources
    $graphics.Dispose()
    $bitmap.Dispose()
}

function Convert-SvgPathData2 {
    param(
        [string]$pathData
    )

    # Split path data into individual commands
    $commands = $pathData -split '([MLZ])' | Where-Object { $_ -ne '' }

    # Initialize list to store vertices
    $vertices = @()

    # Parse commands and extract vertices
    $x = $y = 0
    foreach ($command in $commands) {
        switch ($command[0]) {
            'M' { 
                $coords = $command.Substring(1).Split(',')
                $x = [double]$coords[0]
                $y = [double]$coords[1]
            }
            'L' { 
                $coords = $command.Substring(1).Split(',')
                $x1 = [double]$coords[0]
                $y1 = [double]$coords[1]
                $vertices += @([System.Drawing.PointF]::new($x, $y), [System.Drawing.PointF]::new($x1, $y1))
                $x = $x1
                $y = $y1
            }
        }
    }

    return ,$vertices
}

function Convert-SvgToPng {
    param(
        [Parameter(Mandatory=$true)]
        [string]$svgFilePath,

        [Parameter(Mandatory=$true)]
        [string]$pngFilePath
    )

    # Read SVG file content
    $svgContent = Get-Content -Path $svgFilePath

    # Create a blank bitmap
    $width = 128  # SVG width
    $height = 128  # SVG height
    $bitmap = New-Object System.Drawing.Bitmap $width, $height

    # Create graphics object
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::Black)

    # Parse SVG content and draw shapes
    foreach ($line in $svgContent) {
        if ($line -match 'class="content" d="([^"]+)"') {
            $pathData = $Matches[1]
            $commands = $pathData -split "([A-Za-z])" | Where-Object { $_ -match "[A-Za-z]" }
            $points = @()
            $currentPoint = [System.Drawing.PointF]::Empty
    
            foreach ($command in $commands) {
                $parameters = $pathData -split "[A-Za-z]" | Where-Object { $_ -ne "" }
                $x = [float]($parameters[0] -replace '[^\d.-]', '')
                $y = [float]($parameters[1] -replace '[^\d.-]', '')
    
                if ($command -eq "M" -or $command -eq "L") {
                    $currentPoint = New-Object System.Drawing.PointF $x, $y
                    $points += $currentPoint
                }
            }
    
            $graphics.DrawPolygon($pen, $points)
        }
    }

    # Save bitmap as PNG
    $bitmap.Save($pngFilePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Clean up resources
    $graphics.Dispose()
    $bitmap.Dispose()
}

function Convert-SvgPath {
    param(
        [string]$d
    )

    $pathData = $d.Trim()
    $pathCommands = $pathData -split "([A-Za-z])" | Where-Object { $_ -match "[A-Za-z]" }

    $points = @()
    $currentPoint = [System.Drawing.PointF]::Empty

    foreach ($command in $pathCommands) {
        $command = $command.Trim()

        switch ($command.ToLower()) {
            "m" {
                # Move to command
                $parameters = $pathData -split "[A-Za-z]" | Where-Object { $_ -ne "" } | Select-Object -First 2
                $x = [float]$parameters[0]
                $y = [float]$parameters[1]
                $currentPoint = New-Object System.Drawing.PointF $x, $y
                $points += $currentPoint
            }
            "l" {
                # Line to command
                $parameters = $pathData -split "[A-Za-z]" | Where-Object { $_ -ne "" } | Select-Object -First 2
                $x = [float]$parameters[0]
                $y = [float]$parameters[1]
                $currentPoint = New-Object System.Drawing.PointF $x, $y
                $points += $currentPoint
            }
            default {
                # Other commands not handled in this example
                Write-Host "Unhandled command: $command"
            }
        }
    }

    return $points
}
# Example usage:
# Convert-SvgToPng -svgFilePath "path/to/input.svg" -pngFilePath "path/to/output.png"
