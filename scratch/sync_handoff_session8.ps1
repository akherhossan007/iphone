$headers = @{
    'Authorization' = 'cpanel glowbayb:SO0W7YTCUYVLUZ25XZKSDAEHAPFMG41U'
}
$body = @{
    'dir' = 'glowbay-docs'
    'file' = 'HANDOFF.md'
}
$resp = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/get_file_content' -Method Post -Headers $headers -Body $body
if ($resp.status -eq 1) {
    $existing = $resp.data.content
    $updateEntry = @"

### Session 8 Update (2026-09-20): Lazada-Grade Header & 1:1 Mobile Web Home Parity
- Rebuilt app header to match Lazada flagship style: Wishlist (Heart with live item counter), Notifications (Bell), and Shopping Cart (Bag with live counter).
- Omitted hamburger drawer menu per explicit user instruction.
- Upgraded floating search capsule with animated hints, Camera (Visual Search), and Mic (Voice Search).
- Brought Flutter Home Screen into 1:1 visual parity with Mobile Web UI (`templates/mobile/home.php`):
  - Dual CTA action buttons under Hero Carousel ("Shop Authentic" & "Track Order") + 3 trust pills.
  - 100% Secure Pre-Order 3-step royal navy banner (`#0B1933` to `#1E1B4B`).
  - Added Trending Now 2-column product grid (`_trendingProducts`).
  - Added Weekly Deals 2-column product grid (`_weeklyDeals`).
  - Added Mid Sourcing Studio Showcase Card (Malaysian quality seal & quick search triggers).
  - Added Instagram Community Showcase (`@glowbaybd`) with authentic unboxing cards.
  - Added Beauty Tips & Skincare Guides with horizontal educational cards.
  - Added Homepage FAQ Accordion (3 collapsible Q&As on authenticity, advance booking, and delivery duration).
- Re-compiled optimized release APK (`78.3 MB`) deployed to `D:\Glowbay App\GlowBay-App-Release.apk`.
"@
    $newContent = $existing + "`n" + $updateEntry
    $saveBody = @{
        'dir' = 'glowbay-docs'
        'file' = 'HANDOFF.md'
        'content' = $newContent
    }
    $saveResp = Invoke-RestMethod -Uri 'https://ultra.webfastdns.com:2083/execute/Fileman/save_file_content' -Method Post -Headers $headers -Body $saveBody
    Write-Output "Handoff sync status: $($saveResp.status)"
} else {
    Write-Output "Failed to read HANDOFF.md: $($resp.errors | ConvertTo-Json)"
}
