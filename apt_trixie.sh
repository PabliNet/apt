#!/bin/sh

# Función para generar ruta absoluta
binary_absolute () {
    # El binario real de apt que se ejecutará.
    file=${1##*/}; file=${file%%.*}; file=${file%%_*}
    # Si se define APT_SEARCH_CUSTOM, se permite usar rutas personalizadas en $APT_SEARCH
    if [ -z "$APT_SEARCH_CUSTOM" ]; then
        file="/usr/bin/$file"  # Obliga que el ejecutable esté en directorio: /usr/bin
    fi
    command -v "$file" 2> /dev/null || true
}

# Wrapper para apt compatible con POSIX Sh que maneja automáticamente 'sudo'
# para comandos que modifican el sistema.

# El binario real de apt que se ejecutará.
APT_BINARY=$(binary_absolute "$0" || true)

# Comandos de apt que requieren permisos de root. Esta lista cubre las operaciones de escritura.
WITH_SUDO='install remove purge update upgrade full-upgrade dist-upgrade autoremove clean autoclean download hold unhold edit-sources'

# Binario a usar para 'apt search'. Por defecto, usa APT_BINARY, pero respeta $APT_SEARCH.
APT_SEARCH_CMD=${APT_SEARCH:-$APT_BINARY}
[ -z "$APT_SEARCH_CMD" ] && APT_SEARCH_CMD=$APT_BINARY

# Binario a usar para 'apt search'. Por defecto, usa APT_BINARY, pero respeta $APT_SEARCH.
APT_SEARCH_PATH=$(binary_absolute "$APT_SEARCH_CMD" || true)

needs_sudo=0
use_search_cmd=0

# Si no hay argumentos, mostrar ayuda de apt por defecto
if [ $# -eq 0 ]; then
    set -- --help
fi

# 1. Iterar sobre los argumentos para encontrar el comando y determinar si se necesita sudo.
# Esta lógica es crucial para manejar opciones como '--yes' o '--purge' antes del comando.
for arg in "$@"; do
    
    # Caso 1: Encontrar el comando 'search' (manejo especial)
    if [ "$arg" = "search" ]; then
        use_search_cmd=1
        break
    fi

    # Caso 2: Determinar si se necesita sudo (solo si el usuario no es root)
    # La robustez para id -u es buena, asegura un fallback a 1 si el comando falla.
    if [ "$( (id -u 2>/dev/null || echo 1) )" -gt 0 ]; then
        # Se añaden espacios para asegurar una coincidencia exacta de la palabra
        case " $WITH_SUDO " in
            *" $arg "*) needs_sudo=1; break ;;
        esac
    fi

    # Caso 3: Dejar de buscar si se encuentra un argumento que NO es una opción.
    # Esto asume que el primer argumento que no empieza con '-' es el comando o un paquete.
    case "$arg" in
        -*) ;;  # Es una opción (continúa la búsqueda del comando)
        *) break ;; # Es el comando o un paquete (deja de buscar comandos)
    esac
done

# Inicialmente apunta al binario por defecto
target_bin="$APT_BINARY"

# 2. Re-enrutamiento para 'search' y validación
if [ "$use_search_cmd" -eq 1 ]; then
    target_bin=${APT_SEARCH_PATH:-$APT_BINARY}
fi

# 3. Ejecución final

if [ "$needs_sudo" -eq 1 ]; then
    exec /usr/bin/sudo "$target_bin" "$@"
else
    exec "$target_bin" "$@"
fi
