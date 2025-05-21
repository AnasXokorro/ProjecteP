#!/bin/bash

# Script para crear un plugin sencillo de WordPress llamado PluginAnas
# Uso: ./create-plugin-anas.sh /ruta/destino

# Verificar si se proporcionó un directorio destino
if [ -z "$1" ]; then
    echo "Error: Debes especificar un directorio destino."
    echo "Uso: $0 /ruta/destino"
    exit 1
fi

# Definir rutas y nombres
DESTINO="$1"
PLUGIN_DIR="${DESTINO}/plugin-anas"
INCLUDES_DIR="${PLUGIN_DIR}/includes"
ASSETS_DIR="${PLUGIN_DIR}/assets"
CSS_DIR="${ASSETS_DIR}/css"
JS_DIR="${ASSETS_DIR}/js"
ADMIN_DIR="${INCLUDES_DIR}/admin"
FRONTEND_DIR="${INCLUDES_DIR}/frontend"

# Crear estructura de directorios
echo "Creando estructura de directorios..."
mkdir -p "${PLUGIN_DIR}"
mkdir -p "${INCLUDES_DIR}"
mkdir -p "${ADMIN_DIR}"
mkdir -p "${FRONTEND_DIR}"
mkdir -p "${ASSETS_DIR}"
mkdir -p "${CSS_DIR}"
mkdir -p "${JS_DIR}"
mkdir -p "${PLUGIN_DIR}/languages"

# Crear archivo principal del plugin
echo "Creando archivo principal del plugin..."
cat > "${PLUGIN_DIR}/plugin-anas.php" << 'EOL'
<?php
/**
 * Plugin Name: PluginAnas
 * License: GPL v2 o posterior
 */

// Prevenir acceso directo
if (!defined('ABSPATH')) {
    exit;
}

// Definir constantes del plugin
define('PLUGIN_ANAS_VERSION', '1.0.0');
define('PLUGIN_ANAS_PATH', plugin_dir_path(__FILE__));
define('PLUGIN_ANAS_URL', plugin_dir_url(__FILE__));
define('PLUGIN_ANAS_BASENAME', plugin_basename(__FILE__));

// Incluir archivos necesarios
require_once PLUGIN_ANAS_PATH . 'includes/class-plugin-anas.php';
require_once PLUGIN_ANAS_PATH . 'includes/functions.php';

// Registrar hooks de activación, desactivación y desinstalación
register_activation_hook(__FILE__, 'plugin_anas_activate');
register_deactivation_hook(__FILE__, 'plugin_anas_deactivate');

/**
 * Función que se ejecuta al activar el plugin
 */
function plugin_anas_activate() {
    // Añadir opciones por defecto
    add_option('plugin_anas_option_texto', 'Este contenido fue añadido por PluginAnas');
    add_option('plugin_anas_mostrar_creditos', true);
    
    // Limpiar el caché de permalinks
    flush_rewrite_rules();
}

/**
 * Función que se ejecuta al desactivar el plugin
 */
function plugin_anas_deactivate() {
    // Limpiar el caché de permalinks
    flush_rewrite_rules();
}

/**
 * Iniciar el plugin
 */
function plugin_anas_init() {
    // Cargar archivos de traducción
    load_plugin_textdomain('plugin-anas', false, dirname(PLUGIN_ANAS_BASENAME) . '/languages');
    
    // Instanciar la clase principal
    $plugin = new Plugin_Anas();
    $plugin->iniciar();
}
add_action('plugins_loaded', 'plugin_anas_init');
EOL

# Crear clase principal del plugin
echo "Creando clase principal del plugin..."
cat > "${INCLUDES_DIR}/class-plugin-anas.php" << 'EOL'
<?php
/**
 * Clase principal del plugin
 */
class Plugin_Anas {
    
    /**
     * Constructor
     */
    public function __construct() {
        // Inicializar propiedades si es necesario
    }
    
    /**
     * Iniciar el plugin y registrar hooks
     */
    public function iniciar() {
        // Cargar módulos
        $this->cargar_admin();
        $this->cargar_frontend();
        
        // Registrar assets
        add_action('wp_enqueue_scripts', array($this, 'registrar_assets_frontend'));
        add_action('admin_enqueue_scripts', array($this, 'registrar_assets_admin'));
    }
    
    /**
     * Cargar funcionalidades de admin
     */
    private function cargar_admin() {
        require_once PLUGIN_ANAS_PATH . 'includes/admin/class-admin.php';
        $admin = new Plugin_Anas_Admin();
        $admin->init();
    }
    
    /**
     * Cargar funcionalidades de frontend
     */
    private function cargar_frontend() {
        require_once PLUGIN_ANAS_PATH . 'includes/frontend/class-frontend.php';
        $frontend = new Plugin_Anas_Frontend();
        $frontend->init();
    }
    
    /**
     * Registrar assets para el frontend
     */
    public function registrar_assets_frontend() {
        // Registrar y encolar CSS
        wp_register_style(
            'plugin-anas-css',
            PLUGIN_ANAS_URL . 'assets/css/frontend.css',
            array(),
            PLUGIN_ANAS_VERSION
        );
        wp_enqueue_style('plugin-anas-css');
        
        // Registrar y encolar JavaScript
        wp_register_script(
            'plugin-anas-js',
            PLUGIN_ANAS_URL . 'assets/js/frontend.js',
            array('jquery'),
            PLUGIN_ANAS_VERSION,
            true
        );
        wp_enqueue_script('plugin-anas-js');
        
        // Pasar variables al script
        wp_localize_script(
            'plugin-anas-js',
            'pluginAnasVars',
            array(
                'ajaxurl' => admin_url('admin-ajax.php'),
                'nonce' => wp_create_nonce('plugin-anas-nonce')
            )
        );
    }
    
    /**
     * Registrar assets para el admin
     */
    public function registrar_assets_admin($hook) {
        // Solo cargar en las páginas del plugin
        if (strpos($hook, 'plugin-anas') === false) {
            return;
        }
        
        // Registrar y encolar CSS
        wp_register_style(
            'plugin-anas-admin-css',
            PLUGIN_ANAS_URL . 'assets/css/admin.css',
            array(),
            PLUGIN_ANAS_VERSION
        );
        wp_enqueue_style('plugin-anas-admin-css');
        
        // Registrar y encolar JavaScript
        wp_register_script(
            'plugin-anas-admin-js',
            PLUGIN_ANAS_URL . 'assets/js/admin.js',
            array('jquery'),
            PLUGIN_ANAS_VERSION,
            true
        );
        wp_enqueue_script('plugin-anas-admin-js');
    }
}
EOL

# Crear archivo de funciones
echo "Creando archivo de funciones..."
cat > "${INCLUDES_DIR}/functions.php" << 'EOL'
<?php
/**
 * Funciones de utilidad para PluginAnas
 */

// Prevenir acceso directo
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Obtiene el texto personalizado del plugin
 * 
 * @return string Texto personalizado
 */
function plugin_anas_get_custom_text() {
    return get_option('plugin_anas_option_texto', 'Este contenido fue añadido por PluginAnas');
}

/**
 * Verifica si se deben mostrar los créditos
 * 
 * @return bool True si se deben mostrar los créditos
 */
function plugin_anas_show_credits() {
    return get_option('plugin_anas_mostrar_creditos', true);
}

/**
 * Agrega el texto personalizado al contenido
 * 
 * @param string $content Contenido original
 * @return string Contenido modificado
 */
function plugin_anas_add_custom_text_to_content($content) {
    if (!is_singular() || is_admin()) {
        return $content;
    }
    
    $custom_text = plugin_anas_get_custom_text();
    $custom_html = '<div class="plugin-anas-custom-text">' . esc_html($custom_text) . '</div>';
    
    return $custom_html . $content;
}
EOL

# Crear clase de administración
echo "Creando clase de administración..."
cat > "${ADMIN_DIR}/class-admin.php" << 'EOL'
<?php
/**
 * Clase para la administración del plugin
 */
class Plugin_Anas_Admin {
    
    /**
     * Inicializar funcionalidades de admin
     */
    public function init() {
        // Añadir menú de administración
        add_action('admin_menu', array($this, 'add_admin_menu'));
        
        // Registrar settings
        add_action('admin_init', array($this, 'register_settings'));
        
        // Añadir enlace de configuración en la página de plugins
        add_filter('plugin_action_links_' . PLUGIN_ANAS_BASENAME, array($this, 'add_settings_link'));
    }
    
    /**
     * Añadir menú de administración
     */
    public function add_admin_menu() {
        add_options_page(
            __('Configuración de PluginAnas', 'plugin-anas'),
            __('PluginAnas', 'plugin-anas'),
            'manage_options',
            'plugin-anas-settings',
            array($this, 'render_settings_page')
        );
    }
    
    /**
     * Registrar settings
     */
    public function register_settings() {
        // Registrar settings
        register_setting(
            'plugin_anas_settings',
            'plugin_anas_option_texto',
            array(
                'type' => 'string',
                'sanitize_callback' => 'sanitize_text_field',
                'default' => 'Este contenido fue añadido por PluginAnas',
            )
        );
        
        register_setting(
            'plugin_anas_settings',
            'plugin_anas_mostrar_creditos',
            array(
                'type' => 'boolean',
                'sanitize_callback' => array($this, 'sanitize_checkbox'),
                'default' => true,
            )
        );
        
        // Añadir sección
        add_settings_section(
            'plugin_anas_section_general',
            __('Configuración General', 'plugin-anas'),
            array($this, 'render_section_general'),
            'plugin_anas_settings'
        );
        
        // Añadir campos
        add_settings_field(
            'plugin_anas_option_texto',
            __('Texto personalizado', 'plugin-anas'),
            array($this, 'render_option_texto'),
            'plugin_anas_settings',
            'plugin_anas_section_general'
        );
        
        add_settings_field(
            'plugin_anas_mostrar_creditos',
            __('Mostrar créditos', 'plugin-anas'),
            array($this, 'render_option_mostrar_creditos'),
            'plugin_anas_settings',
            'plugin_anas_section_general'
        );
    }
    
    /**
     * Sanitizar checkbox
     */
    public function sanitize_checkbox($input) {
        return (isset($input) && true == $input) ? true : false;
    }
    
    /**
     * Renderizar la sección general
     */
    public function render_section_general() {
        echo '<p>' . __('Configura las opciones generales de PluginAnas.', 'plugin-anas') . '</p>';
    }
    
    /**
     * Renderizar campo de texto personalizado
     */
    public function render_option_texto() {
        $value = get_option('plugin_anas_option_texto', 'Este contenido fue añadido por PluginAnas');
        echo '<input type="text" name="plugin_anas_option_texto" value="' . esc_attr($value) . '" class="regular-text">';
        echo '<p class="description">' . __('Este texto se mostrará antes del contenido de tus entradas y páginas.', 'plugin-anas') . '</p>';
    }
    
    /**
     * Renderizar campo de mostrar créditos
     */
    public function render_option_mostrar_creditos() {
        $value = get_option('plugin_anas_mostrar_creditos', true);
        echo '<input type="checkbox" name="plugin_anas_mostrar_creditos" value="1" ' . checked(1, $value, false) . '>';
        echo '<p class="description">' . __('Muestra un pequeño crédito en el pie de página.', 'plugin-anas') . '</p>';
    }
    
    /**
     * Renderizar página de configuración
     */
    public function render_settings_page() {
        if (!current_user_can('manage_options')) {
            return;
        }
        ?>
        <div class="wrap">
            <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
            <form action="options.php" method="post">
                <?php
                settings_fields('plugin_anas_settings');
                do_settings_sections('plugin_anas_settings');
                submit_button();
                ?>
            </form>
        </div>
        <?php
    }
    
    /**
     * Añadir enlace de configuración en la página de plugins
     */
    public function add_settings_link($links) {
        $settings_link = '<a href="' . admin_url('options-general.php?page=plugin-anas-settings') . '">' . __('Configuración', 'plugin-anas') . '</a>';
        array_unshift($links, $settings_link);
        return $links;
    }
}
EOL

# Crear clase de frontend
echo "Creando clase de frontend..."
cat > "${FRONTEND_DIR}/class-frontend.php" << 'EOL'
<?php
/**
 * Clase para la funcionalidad del frontend
 */
class Plugin_Anas_Frontend {
    
    /**
     * Inicializar funcionalidades del frontend
     */
    public function init() {
        // Añadir texto personalizado al contenido
        add_filter('the_content', 'plugin_anas_add_custom_text_to_content');
        
        // Añadir créditos al pie de página si está habilitado
        if (plugin_anas_show_credits()) {
            add_action('wp_footer', array($this, 'add_footer_credits'));
        }
    }
    
    /**
     * Añadir créditos al pie de página
     */
    public function add_footer_credits() {
        echo '<div class="plugin-anas-footer-credits">';
        echo esc_html__('Potenciado por PluginAnas', 'plugin-anas');
        echo '</div>';
    }
}
EOL

# Crear archivo de desinstalación
echo "Creando archivo de desinstalación..."
cat > "${PLUGIN_DIR}/uninstall.php" << 'EOL'
<?php
/**
 * Desinstalación del plugin
 */

// Si no se ha llamado desde WordPress, salir
if (!defined('WP_UNINSTALL_PLUGIN')) {
    exit;
}

// Eliminar opciones
delete_option('plugin_anas_option_texto');
delete_option('plugin_anas_mostrar_creditos');

// Si es una instalación multisitio, recorrer todos los sitios
if (is_multisite()) {
    global $wpdb;
    
    $blog_ids = $wpdb->get_col("SELECT blog_id FROM $wpdb->blogs");
    
    foreach ($blog_ids as $blog_id) {
        switch_to_blog($blog_id);
        
        // Eliminar opciones
        delete_option('plugin_anas_option_texto');
        delete_option('plugin_anas_mostrar_creditos');
        
        restore_current_blog();
    }
}
EOL

# Crear CSS para el frontend
echo "Creando CSS para el frontend..."
cat > "${CSS_DIR}/frontend.css" << 'EOL'
/**
 * Estilos para el frontend
 */
.plugin-anas-custom-text {
    background-color: #f8f9fa;
    border-left: 4px solid #0073aa;
    padding: 15px;
    margin-bottom: 20px;
    font-style: italic;
}

.plugin-anas-footer-credits {
    text-align: center;
    font-size: 12px;
    color: #666;
    margin-top: 20px;
    padding: 10px 0;
}
EOL

# Crear CSS para el admin
echo "Creando CSS para el admin..."
cat > "${CSS_DIR}/admin.css" << 'EOL'
/**
 * Estilos para el admin
 */
.wrap.plugin-anas-admin {
    max-width: 800px;
}

.plugin-anas-header {
    margin-bottom: 20px;
    padding-bottom: 20px;
    border-bottom: 1px solid #ddd;
}

.plugin-anas-header h1 {
    color: #0073aa;
}
EOL

# Crear JavaScript para el frontend
echo "Creando JavaScript para el frontend..."
cat > "${JS_DIR}/frontend.js" << 'EOL'
/**
 * JavaScript para el frontend
 */
(function($) {
    'use strict';
    
    // Cuando el DOM esté listo
    $(document).ready(function() {
        // Añadir clase al hacer clic en el texto personalizado
        $('.plugin-anas-custom-text').on('click', function() {
            $(this).toggleClass('highlighted');
        });
    });
    
})(jQuery);
EOL

# Crear JavaScript para el admin
echo "Creando JavaScript para el admin..."
cat > "${JS_DIR}/admin.js" << 'EOL'
/**
 * JavaScript para el admin
 */
(function($) {
    'use strict';
    
    // Cuando el DOM esté listo
    $(document).ready(function() {
        // Código JS para la página de administración
        console.log('PluginAnas admin script loaded');
    });
    
})(jQuery);
EOL

# Crear archivo README
echo "Creando archivo README..."
cat > "${PLUGIN_DIR}/README.txt" << 'EOL'
=== PluginAnas ===
Contributors: tu_usuario
Donate link: https://ejemplo.com/donar
Tags: personalización, contenido
Requires at least: 5.0
Tested up to: 6.4
Stable tag: 1.0.0
Requires PHP: 7.2
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Un plugin sencillo para WordPress con funcionalidades básicas.

== Descripción ==

PluginAnas es un plugin ligero que te permite añadir texto personalizado al principio de tus entradas y páginas, así como mostrar un pequeño crédito en el pie de página.

Características principales:
* Añade texto personalizable al principio del contenido
* Muestra un crédito personalizable en el pie de página
* Panel de administración sencillo e intuitivo
* Ligero y optimizado

== Instalación ==

1. Sube la carpeta `plugin-anas` al directorio `/wp-content/plugins/`
2. Activa el plugin a través del menú 'Plugins' en WordPress
3. Configura las opciones en 'Ajustes > PluginAnas'

== Preguntas frecuentes ==

= ¿Cómo puedo cambiar el texto personalizado? =

Ve a 'Ajustes > PluginAnas' y modifica el campo "Texto personalizado".

= ¿Puedo desactivar el crédito del pie de página? =

Sí, ve a 'Ajustes > PluginAnas' y desmarca la casilla "Mostrar créditos".

== Capturas de pantalla ==

1. La página de configuración del plugin.
2. Ejemplo del texto personalizado en una entrada.

== Changelog ==

= 1.0.0 =
* Versión inicial

== Actualización ==

No se requieren instrucciones especiales para actualizar.
EOL

# Establecer permisos
echo "Estableciendo permisos..."
find "${PLUGIN_DIR}" -type d -exec chmod 755 {} \;
find "${PLUGIN_DIR}" -type f -exec chmod 644 {} \;

echo ""
echo "¡Plugin PluginAnas creado exitosamente en ${PLUGIN_DIR}!"
echo ""
echo "Para instalarlo en WordPress:"
echo "1. Comprime la carpeta plugin-anas en un archivo ZIP"
echo "2. Ve a tu WordPress > Plugins > Añadir nuevo > Subir plugin"
echo "3. Selecciona y sube el archivo ZIP"
echo "4. Activa el plugin"
echo ""
echo "O copia la carpeta plugin-anas directamente al directorio wp-content/plugins/ de tu instalación WordPress"
