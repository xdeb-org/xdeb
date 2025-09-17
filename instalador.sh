#!/usr/bin/env bash
#
# Author:          Fernando Souza - https://www.youtube.com/@fernandosuporte
# Date:            11/09/2025
# Update:          https://github.com/tuxslack/xdeb
# Script:          instalador.sh
# version:         1.0
# License:         MIT
# Requires:        yad, notify-send, find, rsync, sed

# O script pode funcionar como um "instalador" e "desinstalador" para o conteúdo da 
# pasta atual. Ele copia os arquivos para o diretório raiz do sistema e depois pode 
# removê-los com a opção desinstalar.

# Cria um arquivo de log com os caminhos dos arquivos instalados facilita bastante a 
# desinstalação posterior.


# ✅ Vantagens de usar um log de instalação:

#     Evita apagar arquivos que não pertencem ao pacote.

#     Permite desfazer a instalação com precisão.

#     Pode ser usado para auditoria ou verificação.


# 📦 Como usar

# Dê permissão de execução:

# chmod +x instalador.sh


# Para instalar:

# ./instalador.sh instalar


# Para desinstalar:

# ./instalador.sh desinstalar


clear

# ----------------------------------------------------------------------------------------

# Internacionalização com gettext

export TEXTDOMAIN=xdeb
export TEXTDOMAINDIR=usr/share/locale

# ----------------------------------------------------------------------------------------

# Verifica se yad está instalado

if ! command -v yad &> /dev/null; then

    echo -e "$(gettext "Yad is not installed...\n\nInstall with: sudo xbps-install -Sy yad")"

    exit 1
fi



# Verifica dependências

missing_deps=()

for cmd in notify-send find rsync sed; do

    if ! command -v $cmd &> /dev/null; then

        missing_deps+=("$cmd")

    fi

done



if [ ${#missing_deps[@]} -gt 0 ]; then

        message_template="$(gettext "The following commands are not installed:\n\n%s\n\nPlease install them before continuing.")"
        # shellcheck disable=SC2059
        message=$(printf "$message_template" "${missing_deps[*]}")

    yad --error --title="$(gettext "Missing dependencies")" \
        --text="$message"

    exit 1

fi


# ----------------------------------------------------------------------------------------


# sudo: executa o comando com privilégios de superusuário (necessário se o destino for um diretório protegido como /opt).


# Diretório de destino da instalação
DEST_DIR="/"


# ----------------------------------------------------------------------------------------

# 🛠 Instalador

# Função de instalação

instalar() {

        message_template="$(gettext "Installing files to %s...")"
        # shellcheck disable=SC2059
        message=$(printf "$message_template" "$DEST_DIR")

        echo "$message"

# ----------------------------------------------------------------------------------------

# Verificar se contem arquivos de lock do LibreOffice na pasta usr/share/doc/xdeb antes de 
# instalar.


# Diretório a verificar
DIR="usr/share/doc/xdeb"

# Arquivos de lock encontrados
LOCK_FILES=("$DIR"/.~lock.*#)

# Verifica se há arquivos de lock
if ls "${LOCK_FILES[@]}" &>/dev/null; then

        message_template="$(gettext "Lock file(s) found at %s")"

        # shellcheck disable=SC2059
        message=$(printf "$message_template" "$DIR")

        echo "$message"


    # Finaliza o LibreOffice
    echo -e "\nEnding LibreOffice processes...\n"
    pkill -f libreoffice

    # Aguarda um momento para garantir que os processos sejam encerrados
    sleep 2

    # Tenta remover os arquivos de lock
    for lock in "${LOCK_FILES[@]}"; do
        if [ -e "$lock" ]; then


            message_template="$(gettext "Removendo lock file: %s")"

            # shellcheck disable=SC2059
            message=$(printf "$message_template" "$lock")

            echo "$message"

            rm -f "$lock"

            if [ $? -eq 0 ]; then
                echo "$(gettext "Successfully removed"): $lock"
            else
                echo "$(gettext "Error removing"): $lock"
            fi
        fi
    done

else

    echo -e "\n$(gettext "No lock file found in"): $DIR \n"

fi


# ----------------------------------------------------------------------------------------



# Desinstalação:

# Você pode usar o arquivo desinstalar.txt para remove os arquivos e pasta deste pacote.

find . -type f \
  | grep -v dicas \
  | grep -v "/README.md" \
  | grep -v "/LICENSE" \
  | grep -v "/instalador.sh" \
  | grep -v "/desinstalar.txt" \
  | sed -e 's/^\.//' > desinstalar.txt


# Esse comando:

#     Lista todos os arquivos (find . -type f)

#     Exclui arquivos indesejados como dicas, README.md, LICENSE

#     Remove o ./ do início dos caminhos (sed -e s'/^.//'g)

#     Salva tudo em desinstalar.txt


#  Podemos ajustar o comando para excluir a pasta dicas e os arquivos README.md e LICENSE durante a cópia. O cp por si só não tem opção de exclusão, mas podemos usar o find com cpio ou rsync, que são mais flexíveis.

sudo rsync -av  --exclude='instalador.sh' --exclude='desinstalar.txt' --exclude='dicas/' --exclude='README.md' --exclude='LICENSE' ./ "$DEST_DIR"



    # Você está usando echo para exibir a saída do gettext, mas isso é desnecessário — gettext já imprime o texto diretamente.

    # shellcheck disable=SC2005
    echo -e "\n$(gettext "Installation complete.") \n"
}


# ----------------------------------------------------------------------------------------

# 🧹 Desinstalador

# Função de desinstalação

desinstalar() {

    # sudo rm -rf "$DEST_DIR"


echo -e "\n🧹 $(gettext "Uninstaller") \n"

while read -r file; do

        message_template="$(gettext "Removing file %s...")"
        # shellcheck disable=SC2059
        message=$(printf "$message_template" "$file")

    sudo rm -f "$file"

done < desinstalar.txt

    # shellcheck disable=SC2005
    echo -e "\n$(gettext "Uninstallation complete.") \n"
}

# ----------------------------------------------------------------------------------------

# Verifica argumento

case "$1" in
    instalar|install)
        instalar
        ;;
    desinstalar|uninstall)
        desinstalar
        ;;
    *)

        message_template="$(gettext "Usage: %s {install|uninstall}")"

        # shellcheck disable=SC2059
        message=$(printf "$message_template" "$0")

        echo "$message"

        exit 1

        ;;
esac

# ----------------------------------------------------------------------------------------


exit 0

