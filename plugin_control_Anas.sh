#!/bin/bash

# Script bàsic per activar/desactivar plugins WP per línia de comandes
# Ús:
#   ./wp_plugin_control.sh activar panas
#   ./wp_plugin_control.sh desactivar panas

COMANDO=$1
PLUGIN=$2

if [ -z "$COMANDO" ] || [ -z "$PLUGIN" ]; then
  echo "Ús: $0 activar|desactivar plugin-slug"
  exit 1
fi

WP_CLI=$(which wp)
if [ -z "$WP_CLI" ]; then
  echo "Error: wp-cli no està instal·lat o no està a PATH."
  exit 1
fi

case "$COMANDO" in
  activar)
    wp plugin activate "$PLUGIN"
    ;;
  desactivar)
    wp plugin deactivate "$PLUGIN"
    ;;
  *)
    echo "Comando no reconegut: $COMANDO"
    echo "Ús: $0 activar|desactivar plugin-slug"
    exit 1
    ;;
esac
