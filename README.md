# AlexWayfer's Site

## Tech stack

*   [**Ruby** scripts](https://www.ruby-lang.org/)
*   [**Kramdown** render](https://kramdown.gettalong.org/)
*   [**IcoMoon** icons](https://icomoon.io/)
*   [**Rollup** JS](https://rollupjs.org/)

-----

## Development setup

1.  Install [`rbenv`](https://github.com/rbenv/rbenv).
2.  Install [`nodenv`](https://github.com/nodenv/nodenv).
3.  Clone this repository and checkout to directory.
4.  Set the [`EDITOR` environment variable][1] (`nano`, `vim`, `mcedit`, `micro`, etc.).
5.  Run `exe/setup.sh` to install Ruby (with gems), Node (with modules) and fill configs.

[1]: https://en.wikibooks.org/wiki/Guide_to_Unix/Environment_Variables#EDITOR

## Compile

Run `exe/compile.rb`.

## Deploy

Edit and run `exe/deploy.sh`.

## Production setup (optional)

*   Set correct timezone
*   Add UNIX-user for project: `adduser <%= @app_name %>`
*   Make symbolic link of project directory to `/var/www/<%= @app_name %>`
*   Install and configure `nginx` (with symbolic links from `config/nginx.conf`)
*   Install `letsencrypt` and generate certificates
    *   Including `openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096`

-----

## Update external resources

### [IcoMoon](https://icomoon.io/)

1.  Go to [IcoMoon App](https://icomoon.io/app/)
2.  Upload project
    1.  Click `Manage Projects` button
    2.  Click `Import Project` button
    3.  Upload `assets/icomoon/selection.json` file
    4.  Click `Load` button
3.  Modify the set of icons
    1.  Enter keyword (like `car` or `man`) into search field
    2.  Select desired icons
4.  Update icons
    1.  Click `Generate SVG & More` button
    2.  Check names and other settings
    3.  Click `Download` button
    4.  Run `toys icomoon extract %path_to_downloaded_archive%`
5.  Repeat these steps with the final `assets/icomoon/selection.json` file,
    because of there is a difference (in `setIdx` and `iconIdx` fields) between
    original `selection.json` file with freshly added icons and
    generated `selection.json` file with the same icons.
