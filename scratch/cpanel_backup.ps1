$headers = @{
    'Authorization' = 'cpanel glowbayb:SO0W7YTCUYVLUZ25XZKSDAEHAPFMG41U'
}
$body = @{
    'dir' = 'public_html/wp-content/plugins'
    'file' = 'glowbay-app-api.php'
}
$resp = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/get_file_content' -Method Post -Headers $headers -Body $body
if ($resp.status -eq 1) {
    Write-Output "Successfully retrieved remote glowbay-app-api.php (length: $($resp.data.content.Length))"
    # Now save as backup
    $backupBody = @{
        'dir' = 'public_html/wp-content/plugins'
        'file' = "glowbay-app-api.php.bak_20260920_2205"
        'content' = $resp.data.content
    }
    $saveResp = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/save_file_content' -Method Post -Headers $headers -Body $backupBody
    Write-Output "Backup response: $($saveResp | ConvertTo-Json -Depth 2)"
} else {
    Write-Output "Failed: $($resp | ConvertTo-Json -Depth 2)"
}
