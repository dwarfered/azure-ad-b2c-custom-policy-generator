$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        
    Creates B2C Identity Experience Framework (IEF) XML policies using an input config.json file.

    .DESCRIPTION
    LocalAccounts with self-service signup disabled.

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
        [string] $Path,
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string] $PolicyName
    )
    process {
        [xml]$xmlDoc = Get-Content -Path $Path
        $filename = $Path.Split('/')[($Path.split('/').Count - 1)]
        if ($PolicyName) {
            $name = $PolicyName
        } else {
            $name = $filename.Split('.xml')[0]
        }
        $xmlDoc.TrustFrameworkPolicy.PolicyId = 'B2C_1A_' + $name
        $xmlDoc.TrustFrameworkPolicy.TenantId = $tenantId
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
$xmlDoc = New-b2cPolicy -Path $path -PolicyName 'Signin'
$xmlDoc.Save("$(Get-Location)/output/Signin.xml")

$trustFrameworkExtensions = 'TrustFrameworkExtensions.xml'
$path = './templates/scenarios/LocalAccounts/signup-only/' + $trustFrameworkExtensions
$xmlDoc = New-b2cPolicy -Path $path
$iefConfig = $xmldoc.GetElementsByTagName('TechnicalProfile') | Where-Object {$_.Id -eq 'login-NonInteractive'}
$iefMetaData = $iefConfig.MetaData
$iefMetaData.Item[0].InnerText = $proxyIdentityExperienceFrameworkAppId
$iefMetaData.Item[1].InnerText = $identityExperienceFrameworkAppId
$iefInputClaims = $iefConfig.InputClaims
$iefInputClaims.InputClaim[0].DefaultValue = $proxyIdentityExperienceFrameworkAppId
$iefInputClaims.InputClaim[1].DefaultValue = $identityExperienceFrameworkAppId
$xmlDoc.Save("$(Get-Location)/output/$trustFrameworkExtensions")

$trustFrameworkLocalization = 'TrustFrameworkLocalization.xml'
$path = $templatesPath + $trustFrameworkLocalization
$xmlDoc = New-b2cPolicy -Path $path
$xmlDoc.Save("$(Get-Location)/output/$trustFrameworkLocalization")

$passwordReset = 'PasswordReset.xml'
$path = $templatesPath + $passwordReset
$xmlDoc = New-b2cPolicy -Path $path
$xmlDoc.Save("$(Get-Location)/output/$passwordReset")

$profileEdit = 'ProfileEdit.xml'
$path = $templatesPath + $profileEdit
$xmlDoc = New-b2cPolicy -Path $path
$xmlDoc.Save("$(Get-Location)/output/$profileEdit")

$trustFrameworkBase = 'TrustFrameworkBase.xml'
$path = $templatesPath + $trustFrameworkBase
$xmlDoc = New-b2cPolicy -Path $path
$xmlDoc.Save("$(Get-Location)/output/$trustFrameworkBase")
