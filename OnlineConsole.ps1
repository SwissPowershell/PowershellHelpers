# Function to handle incoming requests

function Get-Request($context) {
    $request = $context.Request
    $response = $context.Response

    # Read the command from the request body
    $command = $null
    if ($request.HasEntityBody) {
        $stream = $request.InputStream
        $encoding = $request.ContentEncoding
        $reader = New-Object System.IO.StreamReader $stream, $encoding
        $command = $reader.ReadToEnd()

        # Parse form data
        $formData = ConvertFrom-StringData $command
        $command = $formData['command']
        
        # URL-decode the command
        $command = [System.Web.HttpUtility]::UrlDecode($command)
    }
    write-output $Command
    # Execute the PowerShell command
    if ([String]::IsNullOrEmpty($command) -eq $false) {
        try {
            $result = Invoke-Expression -Command $command
            $output = $result | Out-String

            # Append the output to the history
            $output = "<span class='command'>PS&gt; $command</span>`n$output`n`n"
        }
        catch {
            $output = "Error: $_"    
        }
    }
    else {
        # $output = "Error: No command provided"
        $output = "<span class='command'>PS&gt;</span>`n`n`n"
    }

    # Build the dark-themed HTML response
    $htmlResponse = @"
<!DOCTYPE html>
<html>
<head>
    <title>PowerShell Console running on [$($Env:COMPUTERNAME)] as [$($env:Username)]</title>
    <style>
        body {
            background-color: #1E1E1E;
            color: #D4D4D4;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        h1, h2 {
            color: #61AFEF;
        }
        textarea, input {
            background-color: #2E2E2E;
            color: #D4D4D4;
            border: 1px solid #3E3E3E;
            padding: 5px;
        }
        pre {
            background-color: #2E2E2E;
            color: #D4D4D4;
            padding: 10px;
            white-space: pre-wrap;
        }
        .command {
            color: #61AFEF;
            font-family: 'Monaco', 'Consolas', 'Liberation Mono', monospace;
        }
    </style>
</head>
<body>
    <h1>PowerShell Console running on [$($Env:COMPUTERNAME)] as [$($env:Username)]</h1>
    <form action="/" method="post">
        <label for="command">Enter PowerShell Command:</label><br>
        <textarea name="command" rows="4" cols="50"></textarea><br>
        <input type="submit" value="Execute">
    </form>
    <h2>Command Output:</h2>
    <pre>$($output)</pre>
</body>
</html>
"@

    $htmlBytes = [Text.Encoding]::UTF8.GetBytes($htmlResponse)

    # Send the HTML response
    $response.OutputStream.Write($htmlBytes, 0, $htmlBytes.Length)
    $response.Close()
}
function Write-HostOverride {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [Object]$Object,

        [Parameter(Position = 1)]
        [ConsoleColor]$ForegroundColor,

        [Switch]$NoNewline
    )
    $Object = "HOST: $($Object)"
    # Check if -NoNewline is specified and adjust behavior accordingly
    if ($NoNewline) {
        Write-Output -NoEnumerate -InputObject "$Object"
    } else {
        Write-Output $Object
    }
}

function Write-VerboseOverride {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [Object]$Message
    )

    # Redirect Write-Verbose to Write-Output with custom prefix
    Write-Output "VERBOSE: $Message"
}
function Write-ErrorOverride {
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [Object]$Message
    )

    # Redirect Write-Verbose to Write-Output with custom prefix
    Write-Output "ERROR: $Message"
}
# Create an alias for Write-Host
New-Alias -Name 'Write-Host' -Value 'Write-HostOverride'
New-Alias -Name 'Write-Verbose' -Value 'Write-VerboseOverride'
New-Alias -Name 'Write-Error' -Value 'Write-ErrorOverride'

$ErrorActionPreference = 'Stop'

# Start the HTTP listener
$ListenerPrefix = 'http://localhost:8080/'
# $ListenerPrefix = "http://$($Env:ComputerName):8080/" to register an other url than localhost you need to be admin and run the following command
# $securityIdentifier = 'NT AUTHORITY\Authenticated Users'  # Replace any valid user
# netsh http add urlacl url=$listenerPrefix user=$securityIdentifier

# after starting the site you can remove the urlacl using
# netsh http delete urlacl $listenerPrefix

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($ListenerPrefix)
$listener.Start()

Write-Host "Listening for requests on $($ListenerPrefix)"

# Continuous loop to handle incoming requests
while ($true) {
    $context = $listener.GetContext()
    Get-Request -context $context
}

# Stop the listener (this code won't be reached in the continuous loop)
$listener.Stop()
