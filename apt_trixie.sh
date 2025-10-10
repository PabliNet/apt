#!/bin/sh

# Wrapper para apt compatible con POSIX Sh que maneja automáticamente 'sudo'
# para comandos que modifican el sistema.

# El binario real de apt que se ejecutará.
APT_BINARY=${0##*/}; APT_BINARY=${APT_BINARY%%.*}; APT_BINARY=${APT_BINARY%%_*}

main() {
    # Terminar inmediatamente si un comando falla (e) o si una variable no está definida (u)
    set -eu
    
    # Comandos de apt que requieren permisos de root. Esta lista cubre las operaciones de escritura.
    WITH_SUDO='install remove purge update upgrade full-upgrade dist-upgrade autoremove clean autoclean download hold unhold edit-sources'

    # Binario a usar para 'apt search'. Por defecto, usa APT_BINARY, pero respeta $APT_SEARCH.
    APT_SEARCH_CMD=${APT_SEARCH:-$APT_BINARY}

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
        # Si es 'search', usamos el comando de búsqueda (que puede ser un nombre simple como 'apt-cache').
        target_bin_name="$APT_SEARCH_CMD"
        
        # Resolvemos la ruta completa del binario usando command -v (POSIX).
        # Esto maneja automáticamente si el usuario escribió la ruta completa o solo el nombre.
        resolved_path=$(command -v "$target_bin_name") || resolved_path=""

        if [ -z "$resolved_path" ]; then
            # El comando no se encontró en el PATH o no es ejecutable.
            # Lógica de traducción basada en $LANG (POSIX-compatible)
            # FALLBACK: El binario personalizado no se encontró o no es ejecutable.
            # Emitimos una advertencia y continuamos usando el binario por defecto ($target_bin = $APT_BINARY).
            case "$LANG" in
                es*|ES*)
                    printf "Advertencia: El binario de búsqueda personalizado en la variable \033[1mAPT_SEARCH\033[0m no se encuentra o no es ejecutable. Usando el binario por defecto: %s.\n" "$APT_BINARY" >&2 ;;
                *)
                    printf "Warning: Custom search binary in the \033[1mAPT_SEARCH\033[0m variable was not found or is not executable. Using default binary: %s.\n" "$APT_BINARY" >&2 ;;
            esac
            # target_bin mantiene su valor inicial de $APT_BINARY.
        else
            # ÉXITO: Si se encontró la ruta, la usamos de forma explícita para el exec final.
            target_bin="$resolved_path"
        fi
    fi

    # 3. Ejecución final
    
    if [ "$needs_sudo" -eq 1 ]; then
        # Si se necesita sudo, llamamos a sudo y al binario determinado (APT_BINARY o el resuelto).
        exec /usr/bin/sudo "$target_bin" "$@"
        
    else
        # Ejecutamos el binario de solo lectura (APT_BINARY por defecto) o el binario de búsqueda (resuelto).
        exec "$target_bin" "$@"
    fi
}

main "$@"

