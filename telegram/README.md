# tg-send

To set it up:

* Set up a bot with [@botfather](https://t.me/botfather)
* Talk to your bot (say "Hello"! Or "/start", you grinch).
* Fill in your bot API token and user id in tg-send.
* If you don't know your user id, get it with `curl https://api.telegram.org/bot$token/getUpdates`
* `chmod +x tg-end` if necessary. Then `./tg-send -h` and have fun.

## Example use

### smartd

To send a warning via telegram when your disks fail, add this to your `/etc/smartd.conf`:

    DEVICESCAN -m christian@example.org -M exec /usr/local/bin/smartdnotify

And this in your `/usr/local/bin/smartdnotify`:

    #!/bin/bash

    # Send email
    echo "$SMARTD_FULLMESSAGE" | mail -s "$SMARTD_FAILTYPE" "$SMARTD_ADDRESS"
    /usr/local/bin/tg-send -ul -s "$SMARTD_FAILTYPE" -m "$SMARTD_FULLMESSAGE"

You can see more variables that are available with `man 5 smartd.conf`.

To test this, add `-M test` to the line with DEVICESCAN.

### certbot

Certbot is [Let's Encrypt](https://letsencrypt.org)'s certificate renewal tool. I call this once per week:

    /usr/bin/certbot --non-interactive --email christian@example.org --domains example.org --agree-tos --webroot --webroot-path /var/www/example.org/ certonly --post-hook "/bin/systemctl reload nginx" --deploy-hook "/usr/local/bin/tg-send -l -s \"Certificate renewal\" -m \"$RENEWED_DOMAINS: new certificate has been issued by Let's Encrypt.\""

