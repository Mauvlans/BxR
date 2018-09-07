# ***************************************************************************
#
# Purpose: Boot X-Ray ActiveTraceProfileController.json Post Deployment Modification
#
# ------------- DISCLAIMER -------------------------------------------------
# This script code is provided as is with no guarantee or waranty concerning
# the usability or impact on systems and may be used, distributed, and
# modified in any way provided the parties agree and acknowledge the 
# Microsoft or Microsoft Partners have neither accountabilty or 
# responsibility for results produced by use of this script.
#
# We will not provide any support through any means.
# ------------- DISCLAIMER -------------------------------------------------
#
# ***************************************************************************
# Example:
#   powershell.exe -file SetBootXRayTraceLevel.ps1 -ScanLevel_M 20, -ScanLevel_L 20, -ScanLevel_H 60, -ScanLevel_N 0, -TraceFreq 7
#
param (
    [int32] $ScanLevel_M,
    [int32] $ScanLevel_L,
    [int32] $ScanLevel_H,
    [int32] $ScanLevel_N,
    [int32] $TraceFreq
)
$ScanLevel = $ScanLevel_M + $ScanLevel_L + $ScanLevel_H + $ScanLevel_N
If ($ScanLevel -gt 100 ) {Write-Host "Total Percentage greater than 100"}
Else {
    $a = Get-Content 'C:\ProgramData\Microsoft Services BootXRay\BxrR\Profiles\ActiveTraceProfileController.json' -raw | ConvertFrom-Json
    #$a = Get-Content 'ActiveTraceProfileController.json' -raw | ConvertFrom-Json
    $a.MaxTraceFrequencyDays = $TraceFreq
    $a.WeightedProfileUsage | ForEach-Object {if ($_.ProfileName -eq 'MediumTrace-UploadTrace-NoLocalProcessing') {$_.Weight = $ScanLevel_M}}
    $a.WeightedProfileUsage | ForEach-Object {if ($_.ProfileName -eq 'LightTrace-UploadTrace-NoLocalProcessing') {$_.Weight = $ScanLevel_L}}
    $a.WeightedProfileUsage | ForEach-Object {if ($_.ProfileName -eq 'HeavyTrace-UploadTrace-NoLocalProcessing') {$_.Weight = $ScanLevel_H}}
    $a.WeightedProfileUsage | ForEach-Object {if ($_.ProfileName -eq 'NoTrace') {$_.Weight = $ScanLevel_N}}
    $a | ConvertTo-Json -Depth 20 | set-content 'ActiveTraceProfileController.json'
}
