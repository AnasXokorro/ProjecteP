#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 /ruta/destino"
    exit 1
fi

DEST="$1"
DIR="${DEST}/panas"
INCLUDES="${DIR}/includes"
ASSETS="${DIR}/assets"
CSS="${ASSETS}/css"
JS="${ASSETS}/js"
IMAGES="${ASSETS}/images"

mkdir -p "$DIR" "$INCLUDES" "$CSS" "$JS" "$IMAGES"

# Plugin principal
cat > "$DIR/panas.php" <<'EOL'
<?php
/*
Plugin Name: PAnas
Description: Plugin creat per Anas Chatt que mostra una compte enrere configurable.
Version: 1.2
Author: Anas Chatt
Text Domain: panas
*/

if (!defined('ABSPATH')) exit;

define('ACPL1_VERSION', '1.2');
define('ACPL1_PATH', plugin_dir_path(__FILE__));
define('ACPL1_URL', plugin_dir_url(__FILE__));

require_once ACPL1_PATH . 'includes/functions.php';

add_action('plugins_loaded', 'acpl1_init');
function acpl1_init() {
    add_action('admin_menu', 'acpl1_admin_menu');
    add_action('admin_init', 'acpl1_register_settings');
    add_action('wp_enqueue_scripts', 'acpl1_enqueue_assets');

    add_filter('the_title', 'acpl1_filter_title', 10, 2);
    add_filter('the_content', 'acpl1_filter_content');
}

function acpl1_admin_menu() {
    add_options_page('PAnas Configuració', 'PAnas', 'manage_options', 'acpl1-settings', 'acpl1_settings_page');
}

function acpl1_register_settings() {
    register_setting('acpl1_options_group', 'acpl1_show_countdown');
    register_setting('acpl1_options_group', 'acpl1_countdown_target');
    register_setting('acpl1_options_group', 'acpl1_show_prefix');
}

function acpl1_settings_page() {
    $show_countdown = get_option('acpl1_show_countdown', 0);
    $countdown_target = get_option('acpl1_countdown_target', '');
    $show_prefix = get_option('acpl1_show_prefix', 0);
    ?>
    <div class="wrap">
        <h1>PAnas Configuració</h1>
        <form method="post" action="options.php">
            <?php settings_fields('acpl1_options_group'); ?>
            <table class="form-table">
                <tr valign="top">
                    <th>Mostrar compte enrere al frontend</th>
                    <td><input type="checkbox" name="acpl1_show_countdown" value="1" <?php checked($show_countdown, 1); ?>></td>
                </tr>
                <tr valign="top">
                    <th>Data i hora objectiu</th>
                    <td>
                        <input type="datetime-local" name="acpl1_countdown_target" value="<?php echo esc_attr($countdown_target); ?>" style="max-width:300px;">
                        <p class="description">Format: AAAA-MM-DDThh:mm (ex: 2025-06-30T18:00)</p>
                    </td>
                </tr>
                <tr valign="top">
                    <th>Afegir prefix als títols</th>
                    <td><input type="checkbox" name="acpl1_show_prefix" value="1" <?php checked($show_prefix, 1); ?>></td>
                </tr>
            </table>
            <?php submit_button(); ?>
        </form>
    </div>
    <?php
}

function acpl1_enqueue_assets() {
    wp_enqueue_style('acpl1-style', ACPL1_URL . 'assets/css/style.css', [], ACPL1_VERSION);
    wp_enqueue_script('acpl1-js', ACPL1_URL . 'assets/js/script.js', ['jquery'], ACPL1_VERSION, true);

    // Pasem la data/hora objectiu a JS (en ISO 8601)
    $target = get_option('acpl1_countdown_target', '');
    $show = get_option('acpl1_show_countdown', 0);
    wp_localize_script('acpl1-js', 'acpl1_vars', [
        'countdown_target' => $target,
        'show_countdown' => $show,
    ]);
}

function acpl1_filter_title($title, $id) {
    if (!is_admin() && get_option('acpl1_show_prefix')) {
        return 'PAnas: ' . $title;
    }
    return $title;
}

function acpl1_filter_content($content) {
    if (!is_admin() && get_option('acpl1_show_countdown')) {
        $div = '<div class="acpl1-datetime">';
        $svg = '<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="#3b82f6"><circle cx="12" cy="12" r="10" stroke="none"/><path d="M12 7v5l4 2" stroke="#fff" stroke-width="2" stroke-linecap="round"/></svg>';
        $div .= $svg;
        $div .= '<div><strong>Temps restant:</strong><br/><span id="acpl1-countdown">Carregant...</span></div>';
        $div .= '</div>';
        return $div . $content;
    }
    return $content;
}

// Desinstal·lació
register_uninstall_hook(__FILE__, 'acpl1_uninstall');
function acpl1_uninstall() {
    delete_option('acpl1_show_countdown');
    delete_option('acpl1_countdown_target');
    delete_option('acpl1_show_prefix');
}
EOL

# includes/functions.php (buit)
cat > "$INCLUDES/functions.php" <<'EOL'
<?php
// Funcions addicionals possibles
EOL

# CSS frontend (igual que abans)
cat > "$CSS/style.css" <<'EOL'
.acpl1-datetime {
    background: #dbeafe;
    border: 4px solid #3b82f6;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 30px;
    display: flex;
    align-items: center;
    gap: 20px;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    color: #1e40af;
    font-size: 18px;
    box-shadow: 0 0 15px rgba(59,130,246,0.5);
}

.acpl1-datetime svg {
    flex-shrink: 0;
}

#acpl1-countdown {
    font-weight: 700;
    font-size: 1.5em;
    margin-top: 6px;
    display: inline-block;
}
EOL

# JS frontend actualitzat per fer la compte enrere
cat > "$JS/script.js" <<'EOL'
(function($){
    function updateCountdown(){
        var targetStr = acpl1_vars.countdown_target;
        if(!acpl1_vars.show_countdown || !targetStr){
            $('#acpl1-countdown').text('No configurat');
            return;
        }
        var target = new Date(targetStr);
        var now = new Date();
        var diff = target - now;

        if(diff <= 0){
            $('#acpl1-countdown').text('Temps acabat!');
            return;
        }

        var days = Math.floor(diff / (1000 * 60 * 60 * 24));
        var hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
        var minutes = Math.floor((diff / (1000 * 60)) % 60);
        var seconds = Math.floor((diff / 1000) % 60);

        var text = days + ' dia' + (days !== 1 ? 's' : '') + ', ' +
                   ('0'+hours).slice(-2) + ':' +
                   ('0'+minutes).slice(-2) + ':' +
                   ('0'+seconds).slice(-2);
        $('#acpl1-countdown').text(text);
    }

    $(document).ready(function(){
        updateCountdown();
        setInterval(updateCountdown, 1000);
    });
})(jQuery);
EOL

# CSS admin senzill
cat > "$CSS/admin.css" <<'EOL'
.wrap h1 {
    color: #2563eb;
    font-family: Arial, sans-serif;
}
form input[type="checkbox"], form input[type="datetime-local"] {
    transform: scale(1.3);
    margin-top: 3px;
}
form input[type="datetime-local"] {
    transform: scale(1);
    margin-top: 0;
    font-size: 16px;
    padding: 4px 8px;
    max-width: 250px;
}
form table.form-table th {
    font-weight: bold;
}
EOL

chmod -R 755 "$DIR"

echo "Plugin PAnas creat a $DIR"
