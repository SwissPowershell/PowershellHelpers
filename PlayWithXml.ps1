[xml] $Content = Get-Content -Path "C:\Users\cyber\OneDrive\PC_Docs\Bureau\AVX_XML\Notepadplusplus_YGI_Test_AppVentix_Deployment_Config_003.appd"
$ContentrootNode = $xmlDoc.DocumentElement
if ($ContentrootNode.HasAttributes) {
    # Iterate through each attribute of the root element
    foreach ($attribute in $rootNContentrootNodeode.Attributes) {
        # Get the name and value of each attribute
        $attributeName = $attribute.Name
        $attributeValue = $attribute.Value
        
        # Output the attribute name and value
        Write-Host "Attribute Name: $attributeName, Value: $attributeValue"
    }
}
$UserXMLPath = "C:\Users\cyber\OneDrive\PC_Docs\Bureau\AVX_XML\UserConfiguration2.xml"
$nsManager = New-Object System.Xml.XmlNamespaceManager($Content.NameTable)
$nsManager.AddNamespace("ns", "http://schemas.microsoft.com/appv/2010/deploymentconfiguration")
$userConfigElement = $Content.SelectSingleNode("//ns:UserConfiguration", $nsManager)

$UserXML = New-Object System.Xml.XmlDocument

# Create the root element
$rootNode = $UserXML.CreateElement("UserConfiguration")
# Add namespaces
$rootNode.SetAttribute("xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
$rootNode.SetAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
$rootNode.SetAttribute("xmlns", "http://schemas.microsoft.com/appv/2010/userconfiguration")
# Add attributes
$rootNode.SetAttribute("PackageId", "48b74edb-fddf-4bf6-a1e6-dd15dd6b32f7") ## !! Replace with the actual package ID
$rootNode.SetAttribute("DisplayName", "(App-V Default)")
foreach ($childNode in $userConfigElement.ChildNodes) {
    $importedNode = $UserXML.ImportNode($childNode, $true)
    $newNode = $importedNode.Clone()
    $rootNode.AppendChild($newNode) | out-null
}
$UserXML.AppendChild($rootNode) | out-null
$UserXML.Save($UserXMLPath)
# removing the xml namespace herited from the original XMLDoc is not straightforward do it the dirty way
[XML] $CleanedContent = (Get-Content -path $UserXMLPath -raw) -replace ' xmlns="http://schemas.microsoft.com/appv/2010/deploymentconfiguration"',''
$CleanedContent.Save($UserXMLPath) # do not judge me
