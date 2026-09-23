$r = Invoke-RestMethod -Uri 'https://glowbaybd.com/wp-json/glowbay-app/v1/home'
Write-Host "Home feed status: $($r.success)"
Write-Host "Banners count: $($r.data.banners.Count)"
Write-Host "Flash sale active: $($r.data.flash_sale.is_active)"

$p = Invoke-RestMethod -Uri 'https://glowbaybd.com/wp-json/glowbay-app/v1/products?per_page=2'
Write-Host "Products status: $($p.success)"
Write-Host "Returned products count: $($p.data.products.Count)"
Write-Host "Total products in store: $($p.data.total)"
Write-Host "Latest product title: $($p.data.products[0].title)"
