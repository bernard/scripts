# Script zscaler_otp.ps1
# Used for obtaining On Time Password to disable zscaler
# Version: 1.2

param ([string]
    [Parameter(Mandatory=$true)][string]$Usager
)

$user = $Usager 

$apiKEY = "YOUR API KEY"
$apiSecret = "YOUR API SECRET"

$apiURL = https://api-mobile.zscalerthree.net/papi 

$apiEPlogin = "/auth/v1/login"
$apiEPdev = "/public/v1/getDevices"
$apiEPotp = "/public/v1/getOtp"

 
$loginPayload = @{ 
    apiKey = $apiKEY
    secretKey = $apiSecret
    }

 

# Do Login
$url = $apiURL + $apiEPlogin
$loginPayloadJson = $loginPayload | ConvertTo-Json

try {
    $login_response = Invoke-RestMethod -Method 'Post' -Uri $url -ContentType 'application/json' -Body $loginPayloadJson
} catch {
    throw ("Error: " + $_)
}

$headers = @{
    'auth-token' = $login_response.jwtToken
    }

# Do Get Devices List
$url = $apiURL + $apiEPdev + "?username=" + $user

try {
    $device_response = Invoke-RestMethod -Method 'Get' -Uri $url -Headers $headers
} catch {
    throw ("Error: " + $_)
}

 

# Do Get OTP
if ( $device_response.Length -gt 1 ) {
    for ($id = 0; $id -lt $device_response.Length; $id++) {
        $url = $apiURL + $apiEPotp + "?udid=" + $device_response.udid[$id]

        try {
            $otp_response = Invoke-RestMethod -Method 'Get' -Uri $url -Headers $headers
        } catch {
            throw ("Error: " + $_)
        }

        if ( [string]::IsNullOrWhitespace($otp_response.otp) ) {
            $otp_pass = $otp_response.ziaDisableOtp
        } else {
            $otp_pass = $otp_response.otp
        }

        Write-Host "OTP for" $device_response.machineHostname[$id] "Version:" $device_response.agentVersion[$id] "User:" $user "is: " $otp_pass
        #$otp_pass = ''
    }
} else {
        $url = $apiURL + $apiEPotp + "?udid=" + $device_response.udid 

        try {
            $otp_response = Invoke-RestMethod -Method 'Get' -Uri $url -Headers $headers
        } catch {
            throw ("Error: " + $_)
        }        

        if ( [string]::IsNullOrWhitespace($otp_response.otp) ) {
            $otp_pass = $otp_response.ziaDisableOtp
        } else {
            $otp_pass = $otp_response.otp
        }

        Write-Host "OTP for" $device_response.machineHostname "Version:" $device_response.agentVersion "User:" $user "is: " $otp_pass
}

 
