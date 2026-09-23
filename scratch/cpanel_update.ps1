$headers = @{
    'Authorization' = 'cpanel glowbayb:SO0W7YTCUYVLUZ25XZKSDAEHAPFMG41U'
}
$body = @{
    'dir' = 'public_html/wp-content/plugins'
    'file' = 'glowbay-app-api.php'
}
$resp = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/get_file_content' -Method Post -Headers $headers -Body $body
$content = $resp.data.content

# 1. Update get_home_feed to add no-cache headers
$targetHome = 'public function get_home_feed(WP_REST_Request $request) {'
$replaceHome = @"
public function get_home_feed(WP_REST_Request `$request) {
        if (!headers_sent()) {
            header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
            header('Pragma: no-cache');
            header('Expires: 0');
        }
"@

if ($content.Contains($targetHome)) {
    $content = $content.Replace($targetHome, $replaceHome)
    Write-Output "Injected no-cache headers into get_home_feed"
} else {
    Write-Output "Could not find targetHome"
}

# 2. Update get_products to add no-cache headers and support category_id / brand_id
$targetProducts = 'public function get_products(WP_REST_Request $request) {'
$replaceProducts = @"
public function get_products(WP_REST_Request `$request) {
        if (!headers_sent()) {
            header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
            header('Pragma: no-cache');
            header('Expires: 0');
        }
"@

if ($content.Contains($targetProducts)) {
    $content = $content.Replace($targetProducts, $replaceProducts)
    Write-Output "Injected no-cache headers into get_products"
} else {
    Write-Output "Could not find targetProducts"
}

$targetCat = '$category = sanitize_text_field($request->get_param(''category''));'
$replaceCat = '$category = sanitize_text_field($request->get_param(''category_id'') ?: $request->get_param(''category''));'

if ($content.Contains($targetCat)) {
    $content = $content.Replace($targetCat, $replaceCat)
    Write-Output "Updated category param handling in get_products"
}

$targetBrand = '$brand = sanitize_text_field($request->get_param(''brand''));'
$replaceBrand = '$brand = sanitize_text_field($request->get_param(''brand_id'') ?: $request->get_param(''brand''));'

if ($content.Contains($targetBrand)) {
    $content = $content.Replace($targetBrand, $replaceBrand)
    Write-Output "Updated brand param handling in get_products"
}

# Save updated content to server
$saveBody = @{
    'dir' = 'public_html/wp-content/plugins'
    'file' = 'glowbay-app-api.php'
    'content' = $content
}
$saveResp = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/save_file_content' -Method Post -Headers $headers -Body $saveBody
Write-Output "Save status: $($saveResp.status)"
if ($saveResp.status -ne 1) {
    Write-Output "Errors: $($saveResp.errors | ConvertTo-Json)"
}
