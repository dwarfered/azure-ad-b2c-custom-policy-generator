$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        

    .DESCRIPTION
    
        

    .NOTES
        AUTHOR: https://github.com/dwarfered/b2c-custom-policy-generator
        UPDATED: 23-09-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$tenantId = $config.b2cTenantName
$identityExperienceFrameworkAppId = $config.b2cIdentityExperienceFrameworkAppId
$proxyIdentityExperienceFrameworkAppId = $config.b2cProxyIdentityExperienceFrameworkAppId
$publicPolicyUri = "http://$tenantId/B2C_1A_signin"
$templatesPath = './templates/active-directory-b2c-custom-policy-starterpack-main/SocialAndLocalAccountsWithMfa/'

# Signin.xml
$templateXml = $templatesPath + 'SignUpOrSignin.xml'
$filename = 'Signin.xml'
[xml]$signin = Get-Content -Path $templateXml
$signin.TrustFrameworkPolicy.PolicyId = 'B2C_1A_signin'
$signin.TrustFrameworkPolicy.TenantId = $tenantId
$signin.TrustFrameworkPolicy.BasePolicy.TenantId = $tenantId
$signin.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
$signin.Save("$(Get-Location)/output/$filename")

# TrustFrameworkExtension.xml
$templateXml = $templatesPath + 'TrustFrameworkExtensions.xml'
$filename = $templateXml.Split('/')[($templateXml.split('/').Count -1)]
[xml]$trustFrameworkExtensions = Get-Content -Path $templateXml
$trustFrameworkExtensions.TrustFrameworkPolicy.TenantId = $tenantId
$trustFrameworkExtensions.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
$trustFrameworkExtensions.TrustFrameworkPolicy.BasePolicy.TenantId = $tenantid
# Removal of Facebook
$nodes = $trustFrameworkExtensions.GetElementsByTagName("ClaimsProvider")
$node = $nodes[0];
$node.ParentNode.RemoveChild($node) | Out-Null
# Reference Identity Experience Framework
$ref = $trustFrameworkExtensions.TrustFrameworkPolicy.ClaimsProviders.ClaimsProvider.TechnicalProfiles.TechnicalProfile.MetaData
$ref.Item[0].InnerText = $proxyIdentityExperienceFrameworkAppId
$ref.Item[1].InnerText = $identityExperienceFrameworkAppId
$ref = $trustFrameworkExtensions.TrustFrameworkPolicy.ClaimsProviders.ClaimsProvider.TechnicalProfiles.TechnicalProfile.InputClaims
$ref.InputClaim[0].DefaultValue = $proxyIdentityExperienceFrameworkAppId
$ref.InputClaim[1].DefaultValue = $identityExperienceFrameworkAppId
$trustFrameworkExtensions.Save("$(Get-Location)/output/$filename")

# TrustFrameworkBase.xml
$templateXml = $templatesPath + 'TrustFrameworkBase.xml'
$filename = $templateXml.Split('/')[($templateXml.split('/').Count -1)]
[xml]$trustFrameworkBase = Get-Content -Path $templateXml
$trustFrameworkBase.TrustFrameworkPolicy.TenantId = $tenantId
$trustFrameworkBase.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
$trustFrameworkBase.Save("$(Get-Location)/output/$filename")



