#!/usr/bin/env bash

sudo -u wproot tee /var/www/wordpress.devops.constanta.ua/currency.php > /dev/null <<'EOF'
<?php
    $url = "https://api.privatbank.ua/p24api/pubinfo";
    $json = file_get_contents($url);
    file_put_contents('currency.json', $json);
?>
EOF

whereis php
sudo tee /etc/cron.d/wproot-currency > /dev/null <<'EOF'
0 6 * * * wproot /usr/bin/php /var/www/wordpress.devops.constanta.ua/currency.php
# */5 * * * * wproot /usr/bin/php /var/www/wordpress.devops.constanta.ua/currency.php
EOF