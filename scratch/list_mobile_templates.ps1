$headers = @{
    'Authorization' = 'cpanel glowbayb:SO0W7YTCUYVLUZ25XZKSDAEHAPFMG41U'
}
$body = @{
    'dir' = 'public_html/wp-content/themes/glowbayhp/templates/mobile'
}
$resp = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/list_files' -Method Post -Headers $headers -Body $body
if ($resp.status -eq 1) {
    Write-Output "Files in templates/mobile:"
    foreach ($f in $resp.data) {
        Write-Output " - $($f.file) (size: $($f.size))"
    }
} else {
    Write-Output "Failed to list templates/mobile: $($resp.errors | ConvertTo-Json)"
}

# Also list theme root
$bodyTheme = @{
    'dir' = 'public_html/wp-content/themes/glowbayhp'
}
$respTheme = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/list_files' -Method Post -Headers $headers -Body $bodyTheme
if ($respTheme.status -eq 1) {
    Write-Output "`nFiles in themes/glowbayhp:"
    foreach ($f in $respTheme.data) {
        if ($f.file -match 'header|home|index|front') {
            Write-Output " - $($f.file) (size: $($f.size))"
        }
    }
}
