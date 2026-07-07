[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function ConvertTo-CanonicalJson {
    param([hashtable]$Object)
    return ($Object.GetEnumerator() | Sort-Object Name | ForEach-Object {
        '"' + $_.Name + '":"' + [string]$_.Value + '"'
    }) -join ","
}

function New-ToySignature {
    param(
        [hashtable]$Claim,
        [string]$Secret
    )

    $hmac = [System.Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($Secret))
    try {
        $message = ConvertTo-CanonicalJson -Object $Claim
        $hash = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($message))
        return [Convert]::ToBase64String($hash)
    }
    finally {
        $hmac.Dispose()
    }
}

function New-LicenseClaim {
    param(
        [string]$Tier,
        [string]$Secret
    )

    $claim = @{
        subject = "clean-lab-user"
        tier = $Tier
        issuedAt = "2026-07-08T00:00:00Z"
    }

    return [PSCustomObject]@{
        claim = $claim
        signature = New-ToySignature -Claim $claim -Secret $Secret
    }
}

function Test-LicenseClaim {
    param(
        [pscustomobject]$Envelope,
        [string]$Secret
    )

    $expected = New-ToySignature -Claim $Envelope.claim -Secret $Secret
    return [bool]($expected -eq $Envelope.signature)
}

function New-RuntimeStateFromClaim {
    param(
        [pscustomobject]$Envelope,
        [string]$Secret
    )

    $verified = Test-LicenseClaim -Envelope $Envelope -Secret $Secret
    return [ordered]@{
        verified = $verified
        tier = $Envelope.claim.tier
        canUseStudio = ($verified -and $Envelope.claim.tier -eq "Studio")
        source = "verified-claim-at-login"
    }
}

function Invoke-VulnerableStudioCanary {
    param(
        [hashtable]$RuntimeState,
        [hashtable]$RendererMessage
    )

    # Vulnerable anti-pattern: renderer/runtime state can override the command gate.
    if ($RendererMessage.ContainsKey("canUseStudio")) {
        $RuntimeState.canUseStudio = [bool]$RendererMessage.canUseStudio
        $RuntimeState.source = "renderer-message"
    }

    if ($RuntimeState.canUseStudio) {
        return "STUDIO_CANARY_REACHED"
    }
    return "DENIED"
}

function Invoke-HardenedStudioCanary {
    param(
        [pscustomobject]$Envelope,
        [string]$Secret,
        [hashtable]$RendererMessage
    )

    # Hardened pattern: renderer message is ignored for authorization.
    $verified = Test-LicenseClaim -Envelope $Envelope -Secret $Secret
    $hasStudioEntitlement = ($verified -and $Envelope.claim.tier -eq "Studio")

    if ($hasStudioEntitlement) {
        return "STUDIO_CANARY_REACHED"
    }
    return "DENIED"
}

function Copy-RuntimeState {
    param([System.Collections.IDictionary]$RuntimeState)

    $copy = @{}
    foreach ($key in $RuntimeState.Keys) {
        $copy[$key] = $RuntimeState[$key]
    }
    return $copy
}

$secret = "toy-vendor-secret-not-production"
$trialEnvelope = New-LicenseClaim -Tier "Trial" -Secret $secret
$studioEnvelope = New-LicenseClaim -Tier "Studio" -Secret $secret

$trialRuntime = New-RuntimeStateFromClaim -Envelope $trialEnvelope -Secret $secret
$benignRendererMessage = @{}
$maliciousRendererMessage = @{ canUseStudio = $true }

$rows = @()

$rows += [PSCustomObject]@{
    Scenario = "Trial claim, vulnerable command, benign renderer"
    ClaimTier = "Trial"
    RendererSaysStudio = "false"
    Result = Invoke-VulnerableStudioCanary -RuntimeState (Copy-RuntimeState -RuntimeState $trialRuntime) -RendererMessage $benignRendererMessage
}

$rows += [PSCustomObject]@{
    Scenario = "Trial claim, vulnerable command, renderer claims Studio"
    ClaimTier = "Trial"
    RendererSaysStudio = "true"
    Result = Invoke-VulnerableStudioCanary -RuntimeState (Copy-RuntimeState -RuntimeState $trialRuntime) -RendererMessage $maliciousRendererMessage
}

$rows += [PSCustomObject]@{
    Scenario = "Trial claim, hardened command, renderer claims Studio"
    ClaimTier = "Trial"
    RendererSaysStudio = "true"
    Result = Invoke-HardenedStudioCanary -Envelope $trialEnvelope -Secret $secret -RendererMessage $maliciousRendererMessage
}

$rows += [PSCustomObject]@{
    Scenario = "Studio claim, hardened command, benign renderer"
    ClaimTier = "Studio"
    RendererSaysStudio = "false"
    Result = Invoke-HardenedStudioCanary -Envelope $studioEnvelope -Secret $secret -RendererMessage $benignRendererMessage
}

Write-Output "# Safe Studio Entitlement Canary Demo"
Write-Output ""
Write-Output "This is a toy model. It does not touch Plasticity and does not enable any real Studio feature."
Write-Output ""
Write-Output "| Scenario | Claim tier | Renderer says Studio | Result |"
Write-Output "| --- | --- | --- | --- |"
foreach ($row in $rows) {
    Write-Output ("| {0} | {1} | {2} | {3} |" -f $row.Scenario, $row.ClaimTier, $row.RendererSaysStudio, $row.Result)
}
Write-Output ""
Write-Output "Interpretation:"
Write-Output ""
Write-Output '- In the vulnerable flow, a Trial claim reaches `STUDIO_CANARY_REACHED` when mutable renderer state is trusted.'
Write-Output '- In the hardened flow, the same renderer message is ignored and the command checks the signed claim at execution time.'
Write-Output '- The real product invariant should be: Studio commands must never execute unless dispatcher/native code validates immutable signed Studio entitlement.'
