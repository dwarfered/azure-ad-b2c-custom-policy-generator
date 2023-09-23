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
$templatesPath = './templates/active-directory-b2c-custom-policy-starterpack-main/SocialAndLocalAccountsWithMfa/'

# Signin.xml
$templateXml = $templatesPath + 'SignUpOrSignin.xml'
$filename = 'Signin.xml'
[xml]$signin = Get-Content -Path $templateXml
$signin.TrustFrameworkPolicy.PolicyId = 'B2C_1A_signin'
$signin.TrustFrameworkPolicy.TenantId = $tenantId
$signin.TrustFrameworkPolicy.BasePolicy.TenantId = $tenantId
$publicPolicyUri = "http://$tenantId/B2C_1A_signin"
$signin.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
$signin.Save("$(Get-Location)/output/$filename")

# TrustFrameworkExtension.xml
$templateXml = $templatesPath + 'TrustFrameworkExtensions.xml'
$filename = $templateXml.Split('/')[($templateXml.split('/').Count -1)]
[xml]$trustFrameworkExtensions = Get-Content -Path $templateXml
$trustFrameworkExtensions.TrustFrameworkPolicy.TenantId = $tenantId
$publicPolicyUri = "http://$tenantId/B2C_1A_TrustFrameworkExtensions"
$trustFrameworkExtensions.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
$trustFrameworkExtensions.TrustFrameworkPolicy.BasePolicy.TenantId = $tenantid
# Removal of Facebook References
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

# TrustFrameworkLocalization.xml
$templateXml = $templatesPath + 'TrustFrameworkLocalization.xml'
$filename = $templateXml.Split('/')[($templateXml.split('/').Count -1)]
[xml]$trustFrameworkLocalization = Get-Content -Path $templateXml
$trustFrameworkLocalization.TrustFrameworkPolicy.TenantId = $tenantId
$publicPolicyUri = "http://$tenantId/B2C_1A_TrustFrameworkLocalization"
$trustFrameworkLocalization.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
$trustFrameworkLocalization.TrustFrameworkPolicy.BasePolicy.TenantId = $tenantid
$trustFrameworkLocalization.Save("$(Get-Location)/output/$filename")

# TrustFrameworkBase.xml
$templateXml = $templatesPath + 'TrustFrameworkBase.xml'
$filename = $templateXml.Split('/')[($templateXml.split('/').Count -1)]
[xml]$trustFrameworkBase = Get-Content -Path $templateXml
$trustFrameworkBase.TrustFrameworkPolicy.TenantId = $tenantId
$publicPolicyUri = "http://$tenantId/B2C_1A_TrustFrameworkBase"
$trustFrameworkBase.TrustFrameworkPolicy.PublicPolicyUri = $publicPolicyUri
# Removal of Facebook References
$nodes = $trustFrameworkBase.GetElementsByTagName("ClaimsProvider")
$node = $nodes[0];
$node.ParentNode.RemoveChild($node) | Out-Null
$trustFrameworkBase.Save("$(Get-Location)/output/$filename")
$nodes = $trustFrameworkBase.GetElementsByTagName("UserJourney")
$node = $nodes[0].OrchestrationSteps.OrchestrationStep[0].ClaimsProviderSelections.ClaimsProviderSelection[0]
$node.ParentNode.RemoveChild($node) | Out-Null
$node = $nodes[0].OrchestrationSteps.OrchestrationStep[1].ClaimsExchanges.ClaimsExchange[0]
$node.ParentNode.RemoveChild($node) | Out-Null
$node = $nodes[1].OrchestrationSteps.OrchestrationStep[0].ClaimsProviderSelections.ClaimsProviderSelection[0]
$node.ParentNode.RemoveChild($node) | Out-Null
$node = $nodes[1].OrchestrationSteps.OrchestrationStep[1].ClaimsExchanges.ClaimsExchange[0]
$node.ParentNode.RemoveChild($node) | Out-Null
$trustFrameworkBase.Save("$(Get-Location)/output/$filename")


