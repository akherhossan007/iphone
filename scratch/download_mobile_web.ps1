$headers = @{
    'Authorization' = 'cpanel glowbayb:SO0W7YTCUYVLUZ25XZKSDAEHAPFMG41U'
}

# Fetch header-mobile.php
$bodyHeader = @{
    'dir' = 'public_html/wp-content/themes/glowbayhp'
    'file' = 'header-mobile.php'
}
$respHeader = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/get_file_content' -Method Post -Headers $headers -Body $bodyHeader
if ($respHeader.status -eq 1) {
    Set-Content -Path 'scratch/header-mobile.php' -Value $respHeader.data.content
    Write-Output "Saved scratch/header-mobile.php (length: $($respHeader.data.content.Length))"
}

# Fetch templates/mobile/home.php
$bodyHome = @{
    'dir' = 'public_html/wp-content/themes/glowbayhp/templates/mobile'
    'file' = 'home.php'
}
$respHome = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/get_file_content' -Method Post -Headers $headers -Body $bodyHome
if ($respHome.status -eq 1) {
    Set-Content -Path 'scratch/mobile_home.php' -Value $respHome.data.content
    Write-Output "Saved scratch/mobile_home.php (length: $($respHome.data.content.Length))"
}
