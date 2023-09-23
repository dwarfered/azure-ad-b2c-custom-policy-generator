$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        
    Creates B2C Identity Experience Framework (IEF) XML policies using an input config.json file.

    .DESCRIPTION
    LocalAccounts template.

    .NOTES
        AUTHOR: https://github.com/dwarfered/b2c-custom-policy-generator
        UPDATED: 23-09-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json
$tenantId = $config.b2cTenantName
$identityExperienceFrameworkAppId = $config.b2cIdentityExperienceFrameworkAppId
$proxyIdentityExperienceFrameworkAppId = $config.b2cProxyIdentityExperienceFrameworkAppId
$templatesPath = './templates/active-directory-b2c-custom-policy-starterpack-main/LocalAccounts/'

function New-b2cPolicy {
    [CmdletBinding()]
    [OutputType([System.Xml.XmlDocument])]
    param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string] $Path
    )
    process {
        [xml]$xmlDoc = Get-Content -Path $Path
        $filename = $Path.Split('/')[($Path.split('/').Count - 1)]
        $name = $filename.Split('.xml')[0]
        $xmlDoc.TrustFrameworkPolicy.PolicyId = 'B2C_1A_' + $name
        $xmlDoc.TrustFrameworkPolicy.TenantId = $tenantId
        Write-Host $name
        if ($name -ne 'TrustFrameworkBase') {
            $xmlDoc.TrustFrameworkPolicy.BasePolicy.TenantId = $tenantId
        }
        $publicPolicyUri = "http://$tenantId/B2C_1A_$name"
        $xmlDoc.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
        $xmlDoc
    }
}

$signupsignin = 'SignUpOrSignin.xml'
$path = $templatesPath + $signupsignin
$xmlDoc = New-b2cPolicy $path
$xmlDoc.Save("$(Get-Location)/output/$signupsignin")

$trustFrameworkExtensions = 'TrustFrameworkExtensions.xml'
$path = $templatesPath + $trustFrameworkExtensions
$xmlDoc = New-b2cPolicy $path
$ref = $xmlDoc.TrustFrameworkPolicy.ClaimsProviders.ClaimsProvider.TechnicalProfiles.TechnicalProfile.MetaData
$ref.Item[0].InnerText = $proxyIdentityExperienceFrameworkAppId
$ref.Item[1].InnerText = $identityExperienceFrameworkAppId
$ref = $xmlDoc.TrustFrameworkPolicy.ClaimsProviders.ClaimsProvider.TechnicalProfiles.TechnicalProfile.InputClaims
$ref.InputClaim[0].DefaultValue = $proxyIdentityExperienceFrameworkAppId
$ref.InputClaim[1].DefaultValue = $identityExperienceFrameworkAppId
$xmlDoc.Save("$(Get-Location)/output/$trustFrameworkExtensions")

$trustFrameworkLocalization = 'TrustFrameworkLocalization.xml'
$path = $templatesPath + $trustFrameworkLocalization
$xmlDoc = New-b2cPolicy $path
$xmlDoc.Save("$(Get-Location)/output/$trustFrameworkLocalization")

$passwordReset = 'PasswordReset.xml'
$path = $templatesPath + $passwordReset
$xmlDoc = New-b2cPolicy $path
$xmlDoc.Save("$(Get-Location)/output/$passwordReset")

$profileEdit = 'ProfileEdit.xml'
$path = $templatesPath + $profileEdit
$xmlDoc = New-b2cPolicy $path
$xmlDoc.Save("$(Get-Location)/output/$profileEdit")

$trustFrameworkBase = 'TrustFrameworkBase.xml'
$path = $templatesPath + $trustFrameworkBase
$xmlDoc = New-b2cPolicy $path
$xmlDoc.Save("$(Get-Location)/output/$trustFrameworkBase")
