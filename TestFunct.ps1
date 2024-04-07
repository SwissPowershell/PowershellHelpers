# $__TextBoxValue is the variable inside New-UDUInputBox that represent the content of the textbox
$OnClick = {Show-UDToast -Message "Clicked : [$__TextBoxValue]" -TransitionIn bounceInRight -Duration 1000 -Icon (New-UDIcon -Icon 'info')} 
$PageContent = {
    $Splat1 = @{
        id = 'UDUInputBox'
        Avatar = '@'
        Title = 'Search Mailbox'
        Text =  'Please input valid mail'
        PlaceHolder = 'someone@contoso.com'
        ButtonText = 'Search'
        InputValidationRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        OnClick = $OnClick
    }
    New-UDUInputBox @Splat1

    $Splat2 = @{
        id = 'UDUInputBox2'
        Avatar = 'U'
        Title = 'Search Username'
        Text =  'Please input valid User'
        PlaceHolder = 'someone'
        ButtonText = 'Search'
        #InputValidationRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        OnClick = $OnClick
    }
    New-UDUInputBox @Splat2
}

New-UDPage -Url "/TestFunct" -Name "TestFunct" -Content $PageContent -Description "Test UD Functionalities" -Title "Test UD Functionalities" -Icon @{
    id   = 'df351470-ec3d-40df-9c4d-c4c70f0a1a66'
    type = 'icon'
}