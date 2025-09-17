#!/usr/bin/env bash
#
# Author:          Fernando Souza - https://www.youtube.com/@fernandosuporte
# Date:            09/09/2025
# Update:          https://github.com/tuxslack/xdeb
# Script:          xdeb-gui.sh
# version:         0.1
# License:         MIT
# Requires:        yad, xdeb
#
#
# Update date: 
#
#
# Interface gráfica com yad para conversão de pacotes .deb para .xbps no Void Linux.
#
# Assim, o usuário pode executar tarefas comuns com o xdeb sem precisar digitar os comandos manualmente.
#
# Contem as principais funcionalidades do xdeb organizadas em um menu simples e interativo. Também permite inserir argumentos personalizados para opções como --deps, --arch, etc.
#
#
# Feito especialmente pra quem mora em Tangamandápio ❤️ — e quer evitar a fadiga! - (Jaiminho, o carteiro)
#
# 
#
# https://www.vivaolinux.com.br/dica/Convertendo-pacotes-deb-Debian-para-xbps-Void-Linux/
# https://www.youtube.com/watch?v=uL2FgJLzmCo
# https://youtu.be/uL2FgJLzmCo?t=602
# https://www.vivaolinux.com.br/dica/Instalando-o-softplan-websigner-no-Void-Linux-para-acesso-ao-ESAJ-Chromium



# - Falta validar o pacote .deb no script usando o Void Linux.



# Evite usar 'clear' aqui, pois pode gerar caracteres indesejados em interfaces gráficas (yad).

clear


# Definir um título padrão para janelas criadas com yad

title="xdeb"


# Se dois usuários abrirem o script ao mesmo tempo, ambos escrevem no arquivo de log.

# shellcheck disable=SC2034
log="/tmp/xdeb-gui-$$.log"


rm "$log" 2>/dev/null


# Usando "set -e" a opção 14 o yad não abre.

set -e

# ----------------------------------------------------------------------------------------

# Internacionalização com gettext

export TEXTDOMAIN=xdeb
export TEXTDOMAINDIR=/usr/share/locale

# export TEXTDOMAINDIR=../../share/locale/


# ----------------------------------------------------------------------------------------

# cd ~/

# Incompatibilidade com shell não Bash

# Se alguém usar com /bin/sh, vai falhar (especialmente no Void Linux, onde /bin/sh → dash).

if [ -z "$BASH_VERSION" ]; then

    echo -e "\n$(gettext "This script requires bash. Exiting...")\n"

    exit 1
fi

# ----------------------------------------------------------------------------------------

# 🔧 Requisitos


# Verifica se o yad está instalado

if ! command -v yad &> /dev/null; then

    echo -e "\n$(gettext "Error: yad is not installed. \n\nInstall with: sudo xbps-install -Sy yad\n")"

    exit 1
fi




# Lista de comandos a verificar




# O comando col (usado geralmente para processar backspaces e formatação em man pages e 
# saída de nroff, etc.) faz parte do pacote util-linux no Void Linux.

    if ! command -v "col" &> /dev/null; then

        sudo xbps-install -Sy util-linux | tee -a "$log"

    fi


# Para instalar man pages

# O man verifica a variável de ambiente LANG ou LC_MESSAGES para determinar o idioma.

    if ! command -v "man" &> /dev/null; then

        sudo xbps-install -Sy man-db man-pages less | tee -a "$log"

    fi


comandos=("notify-send.sh" "gettext" "ar")

# Lista para armazenar comandos faltando

faltando=()

# Verifica cada comando

for cmd in "${comandos[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        faltando+=("$cmd")
    fi
done

# Se houver comandos ausentes

if [ ${#faltando[@]} -gt 0 ]; then
    lista_formatada=""
    for cmd in "${faltando[@]}"; do
        lista_formatada+="  - $cmd\n"
    done


message_template="The following commands are not installed:\n\n%s\n\nYou can install them with:\n\n sudo xbps-install -Sy %s"
# shellcheck disable=SC2059
message=$(printf "$message_template" "$lista_formatada" "${faltando[*]}")

# 🔒 Essa abordagem é segura desde que você controle o conteúdo da string (ou confie na origem, como gettext).



    yad --center --width="500" --height="300" \
        --text="$message" \
        --title="$(gettext "Missing dependencies")" \
        --button="$(gettext "Close")":1 \
        --window-icon=dialog-error \
        --no-buttons \
        --timeout="30" \
        --timeout-indicator=top \
        --text-align=center

    exit 1

# else
#    yad --center \
#        --text="$(gettext "Todos os comandos necessários estão instalados.")" \
#        --title="Verificação concluída" \
#        --button="$(gettext "OK")":0 \
#        --window-icon=dialog-information

fi



# Poderia falhar se xdeb estiver em outro local do PATH.

# /usr/local/bin/xdeb

if ! command -v xdeb &>/dev/null; then

  yad --center --error --title="$(gettext "Error")..."  --text "$(gettext "The xdeb script was not found.")"  \
  --buttons-layout=center \
  --button="$(gettext "OK")":0 \
  --width="300" \
  2>/dev/null

  exit 1

fi

# ----------------------------------------------------------------------------------------


selecionar_pacote_deb() {
    local arquivo

    arquivo=$(yad --center \
        --title="$(gettext "Select the .deb package")" \
        --file \
        --file-filter="$(gettext "Debian Packages") | *.deb" \
        --buttons-layout=center \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0 \
        --width="900" \
        --height="800" \
        2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$arquivo" ]; then
        return 1  # Cancelado ou nenhum arquivo selecionado
    fi

    # Validação do .deb usando ar
    if ar t "$arquivo" | grep -q "debian-binary" && \
       ar t "$arquivo" | grep -q "control.tar" && \
       ar t "$arquivo" | grep -q "data.tar"; then

        echo "$arquivo"  # Retorna o caminho do arquivo válido
        return 0

    else
        yad --center --title="$(gettext "Error")" --window-icon=error \
            --text="❌ $(gettext "The selected file does not appear to be a valid .deb package.")" \
            --button="$(gettext "OK")":0
        return 1
    fi
}




#   continue # Se cancelado, volta ao menu principal


# ----------------------------------------------------------------------------------------

# Para evitar SC2059

message_template=$(gettext "The log file will be saved to:

%s

It is recommended to check after each package conversion.")

# shellcheck disable=SC2059
mg=$(printf '%s' "$(printf "$message_template" "$log")")

# Se confia que message_template conterá apenas um %s, e controla ou revisou a tradução, pode manter o código e suprimir o aviso com um comentário shellcheck

notify-send -i dialog-information -t 20000 "xdeb" "$mg\n\n$ sudo mkdir -p /opt/binpkgs\n$ sudo chmod -R 777 /opt/binpkgs"



# ----------------------------------------------------------------------------------------

yad \
--center \
--title="$(gettext "Converting .deb (Debian) packages to .xbps (Void Linux)")" \
--info \
--text="\
$(gettext "🧰 Welcome to the .deb to .xbps package converter!

This wizard was created to make life easier for Void Linux 
users who want to convert Debian packages (.deb) to the format used in 
Void (.xbps).

✅ With this program, you can:

- Convert .deb packages with or without dependencies
- Download libraries (shlibs) automatically
- Add dependencies manually
- Perform various xdeb maintenance tasks
- And much more, all with just a few clicks!

💡 Just follow the steps, choose the desired option from the menu, and select the file or directory when prompted.

Click OK to continue and open the main menu.")
" \
--buttons-layout=center \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "OK")":0 \
2>/dev/null


# ----------------------------------------------------------------------------------------

# Aviso com yad, explicando os riscos de usar xdeb no Void Linux:

# O texto não sendo traduzido para português do Brasil

if ! yad \
--center \
--title="$(gettext "Converting .deb (Debian) packages to .xbps (Void Linux)")" \
--buttons-layout=center \
--button="$(gettext "Exit")":1 \
--button="$(gettext "OK")":0 \
--width="800" \
--height="300" \
--info \
--text="$(gettext '\nIMPORTANT NOTICE:\n\nUsing xdeb to convert .deb packages in Void Linux can cause serious system problems.\nVoid Linux is not compatible with Debian/Ubuntu packages. Libraries, paths, and dependencies may be different or non-existent.\n\nPossible consequences:\n\n- Broken packages and system dependencies\n- Library incompatibility\n- Failures in future updates\n- Compromised system stability\nUse xdeb only in specific cases and with simple, non-critical packages.\n\nRecommendation:\n\nPrefer to install software directly from the official Void repositories (xbps), use Flatpak/AppImage, or compile from source code.\nAre you aware of the risks?')" 2>/dev/null ; then


  # continue  # Se o usuário clicar "Exit" ou fechar a janela, continua
  # continue: significativo apenas em um loop de `for', `while' ou `until'

  exit 1

fi

# ----------------------------------------------------------------------------------------


while true; do

# Verifica se usuário clicou em cancelar ou fechou a janela

# Elimina o uso do $?, como o ShellCheck recomenda.

if ! opcao=$(yad \
    --center  \
    --list \
    --radiolist \
    --title="$(gettext "Converting .deb (Debian) packages to .xbps (Void Linux)")" \
    --text="\n$(gettext "Choose the task you want to perform"):\n" \
    --column="" --column="ID" --column="$(gettext "Options")" \
    TRUE  "1" "$(gettext "Simple package conversion (.deb → .xbps)")" \
    FALSE "2" "$(gettext "Conversion with automatic dependency resolution")" \
    FALSE "3" "$(gettext "Download dependencies (shlibs)")" \
    FALSE "4" "$(gettext "Conversion with shlibs + automatic resolution")" \
    FALSE "5" "$(gettext "Add dependencies manually")" \
    FALSE "6" "$(gettext "Remove temporary files")" \
    FALSE "7" "$(gettext "Remove only repodata (rebuild)")" \
    FALSE "8" "$(gettext "Extract .deb without assembling package")" \
    FALSE "9" "$(gettext "Direct package build from directory")" \
    FALSE "10" "$(gettext "Do not register package in repository")" \
    FALSE "11" "$(gettext "Add -32bit suffix to package")" \
    FALSE "12" "$(gettext "Automatically install after creation")" \
    FALSE "13" "$(gettext "Remove empty directories")" \
    FALSE "14" "$(gettext "Show xdeb version")" \
    FALSE "15" "$(gettext "Show xdeb help")" \
    FALSE "16" "$(gettext "Converts using the most commonly used option (xdeb -Sde)")" \
    FALSE "17" "$(gettext "(xdeb -rb)")" \
    FALSE  "0" "$(gettext "Exit")" \
    --buttons-layout=center \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0 \
    --width="700" --height="600" \
    --hide-column=2 \
    2>/dev/null)  ; then # <- Esconde a coluna de ID

  break

fi


opcao="$(echo "$opcao" | cut -d"|" -f2)"



# ----------------------------------------------------------------------------------------

  case "$opcao" in

    

     "1")  # Conversão simples de pacote (.deb → .xbps)

# Rodar xdeb sem argumentos de opção (apenas passando o .deb) seria o comportamento padrão.


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi



if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  continue # Se cancelado, volta ao menu principal

fi

      # xdeb -Sde "$arquivo"

      # Converte .deb para .xbps sem opções extras

if [ -n "$arquivo" ]; then


  command xdeb "$arquivo" | tee -a "$log"

  if [ "${PIPESTATUS[0]}" -eq 0 ]; then

    yad --center --info --title="$title" --text="$(gettext "Conversion completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  else

    yad --center --error --title="$title" --text="$(gettext "Error converting package.")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  fi

fi

      ;;

     

     "2") # Conversão com resolução automática de dependências


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi


if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")"  --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  continue # Se cancelado, volta ao menu principal

fi


if [ -n "$arquivo" ]; then


  command xdeb -Sd "$arquivo" | tee -a "$log"

  if [ "${PIPESTATUS[0]}" -eq 0 ]; then

    yad --center --info --title="$title" --text="$(gettext "Conversion completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  else

    yad --center --error --title="$title" --text="$(gettext "Error converting package.")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  fi

fi

      ;;



"3") # Download de dependências (shlibs)


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi




if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  continue # Se cancelado, volta ao menu principal

fi

  if [ -n "$arquivo" ]; then


    command xdeb -S "$arquivo" | tee -a "$log"

    if [ "${PIPESTATUS[0]}" -eq 0 ]; then

      yad --center --info --title="$title" --text="$(gettext "Shlibs download completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

    else

      yad --center --error --title="$title" --text="$(gettext "Error downloading shlibs.")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

    fi

  fi

  ;;




"4") # Conversão com shlibs + resolução automática


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi



if [[ "$arquivo" != *.deb ]]; then

  yad --error --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

  continue # Se cancelado, volta ao menu principal

fi

  if [ -n "$arquivo" ]; then


    command xdeb -Sd "$arquivo" | tee -a "$log"

    if [ "${PIPESTATUS[0]}" -eq 0 ]; then

      yad --center --info --title="$title" --text="$(gettext "Conversion with dependencies completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

    else

      yad --center --error --title="$title" --text="$(gettext "Error converting with dependencies.")" --buttons-layout=center --button="$(gettext "OK")":0  2>/dev/null

    fi

  fi

  ;;



"5") # Adicionar dependências manualmente (--deps)


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi


# ✔️ Vantagens:

# Evita SC2037 (erro de sintaxe ao misturar captura e argumentos).

# Evita SC2181 (uso indireto de $?).

# Fica mais legível e idiomático.


if ! deps=$(yad --center --entry \
                --title="$(gettext "Dependencies")" \
                --text="$(gettext "Enter dependencies (e.g. tar>0, gzip, etc.)"):" \
                --buttons-layout=center \
                --button="$(gettext "Cancel")":1 \
                --button="$(gettext "OK")":0 \
                2>/dev/null); then

  continue # volta ao menu se o usuário cancelar

fi



  if [[ "$arquivo" != *.deb ]]; then
    yad --error \
        --title="$title" \
        --text="$(gettext "Please select a valid .deb file.")" \
        --buttons-layout=center \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0
    continue
  fi

  [ -n "$arquivo" ] && [ -n "$deps" ] && \
  xdeb --deps="$deps" "$arquivo" | tee -a "$log" && \
  yad --center \
      --info \
      --title="$title" \
      --text="$(gettext "Conversion completed successfully!")" \
      --buttons-layout=center \
      --button="$(gettext "OK")":0 \
      2>/dev/null

  ;;






    "6") # Remover arquivos temporários (-C)


      command xdeb -C | tee -a "$log"

      if [ "${PIPESTATUS[0]}" -eq 0 ]; then

         yad  --center --info --title="$title" --text="$(gettext "Temporary files removed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

      else

         yad --center --error --title="$title" --text="$(gettext "Error removing temporary files.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

      fi

     ;;





"7") # Remover apenas repodata (rebuild)


  command xdeb -r "$arquivo" | tee -a "$log"

  if [ "${PIPESTATUS[0]}" -eq 0 ]; then

    yad --center --info --title="$title" --text="$(gettext "Repodata removed successfully.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  else

    yad --center --error --title="$title" --text="$(gettext "Error removing repodata.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  fi

  ;;



    "8") # Extrair .deb sem montar pacote (-q)


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi



if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  continue

fi


if [ -n "$arquivo" ]; then

  command xdeb -q "$arquivo" | tee -a "$log"

  if [ "${PIPESTATUS[0]}" -eq 0 ]; then

    yad --center --info --title="$title" --text="$(gettext "Extraction completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  else

    yad --center --error --title="$title" --text="$(gettext "Error extracting package.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  fi

fi
      ;;




"9") # Build de pacote direto de diretório
  
if ! dir=$(yad --center --title="$(gettext "Select the directory with the files")" --file --directory --buttons-layout=center --button="$(gettext "Cancel")":1 --button="$(gettext "OK")":0 2>/dev/null); then

  continue # Se cancelado, volta ao menu principal

fi

  # Verifica se o diretório foi selecionado

  if [ -n "$dir" ]; then


    command xdeb -b "$arquivo" | tee -a "$log"

    if [ "${PIPESTATUS[0]}" -eq 0 ]; then

      yad --center --info --title="$title" --text="$(gettext "Direct build completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

    else

      yad --center --error --title="$title" --text="$(gettext "Error running direct build.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

    fi

  fi

  ;;



"10") # Não registrar pacote no repositório


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi



if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  continue # Se cancelado, volta ao menu principal

fi


  if [ -n "$arquivo" ]; then


    command xdeb -R "$arquivo" | tee -a "$log"

    if [ "${PIPESTATUS[0]}" -eq 0 ]; then

      yad --center --info --title="$title" --text="$(gettext "Conversion completed (no record in repository).")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

    else

      yad --center --error --title="$title" --text="$(gettext "Error converting with -R.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

    fi

  fi

  ;;




    "11") # Adicionar sufixo -32bit ao pacote


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi



if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  continue

fi


if [ -n "$arquivo" ]; then


    command xdeb -m "$arquivo" | tee -a "$log"

  if [ "${PIPESTATUS[0]}" -eq 0 ]; then

    yad --center --info --title="$title" --text="$(gettext "Conversion completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  else

    yad --center --error --title="$title" --text="$(gettext "Error converting package.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  fi

fi

      ;;




    "12") # Instalar automaticamente após criação (-I)


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi



if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  continue

fi


if [ -n "$arquivo" ]; then


    command xdeb -I "$arquivo" | tee -a "$log"

  if [ "${PIPESTATUS[0]}" -eq 0 ]; then

    yad --center --info --title="$title" --text="$(gettext "Installation completed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  else

    yad --center --error --title="$title" --text="$(gettext "Error installing package.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  fi

fi


      ;;




"13") # Remover diretórios vazios


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi


if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  continue # Se cancelado, volta ao menu principal

fi

  if [ -n "$arquivo" ]; then


    command xdeb -e "$arquivo" | tee -a "$log"

    if [ "${PIPESTATUS[0]}" -eq 0 ]; then


      yad --center --info --title="$title" --text="$(gettext "Empty directories removed successfully!")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

    else

      yad --center --error --title="$title" --text="$(gettext "Error removing empty directories.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

    fi

  fi

  ;;




     "14") # Mostrar versão do xdeb

# Desativa temporariamente o comportamento de abortar

# set +e


      versao=$(xdeb -version 2>&1 || echo "" 1>/dev/null)

      msg=$(gettext "xdeb version: %s")

      yad --center --info --title="$title" --text="$(printf '%s\n' "$(printf '%s\n' "$msg" | xargs -I{} printf '{}' "$versao")")" --buttons-layout=center  --button="$(gettext "OK")":0  --width="300" --height="100" 2>/dev/null


# Ativa novamente

# set -e

      ;;




    "15") # Mostrar ajuda do xdeb

       # Remover  H2J3J

       xdeb --help | col -b | sed 's/H2J3J//g' | yad --center  --title="$(gettext "xdeb help")"   --text-info --buttons-layout=center --button="$(gettext "OK")":0  --width="1200" --height="800" 2>/dev/null

       # col -b remove caracteres de backspace e formatação de terminal.


# Se aparecer texto truncado ou com scroll lateral, você pode adicionar fold -s -w 80 para quebrar as linhas longas:

# man xdeb

LANG_DIR=$(echo "$LANG" | cut -d. -f1)


# Verificando se o manual existe

if [ -f "/usr/share/man/${LANG_DIR}/man1/xdeb.1" ]; then
    MANPAGE="/usr/share/man/${LANG_DIR}/man1/xdeb.1"

elif [ -f "/usr/share/man/${LANG_DIR}/man1/xdeb.1.gz" ]; then
    MANPAGE="/usr/share/man/${LANG_DIR}/man1/xdeb.1.gz"

elif [ -f "/usr/share/man/man1/xdeb.1.gz" ]; then
    MANPAGE="/usr/share/man/man1/xdeb.1.gz"

elif [ -f "/usr/share/man/man1/xdeb.1" ]; then
    MANPAGE="/usr/share/man/man1/xdeb.1"

else

    echo -e "\n❌ $(gettext "Man page for xdeb not found.")\n"

    notify-send -i dialog-information -t 20000 "xdeb" "$(gettext "Man page for xdeb not found.")"

    continue

fi



man -l "$MANPAGE" 2>/dev/null | col -b | fold -s -w 80  | yad --center \
    --title="$(gettext "xdeb manual")" \
    --text-info \
    --buttons-layout=center \
    --button="$(gettext "OK")":0 \
    --width="900" --height="800" 2>/dev/null

      ;;




"16") # Converte usando a opção mais usada (xdeb -Sde)


if ! arquivo=$(selecionar_pacote_deb); then
    continue  # Volta ao menu principal se cancelado
fi



if [[ "$arquivo" != *.deb ]]; then

  yad --error --title="$title" --text="$(gettext "Please select a valid .deb file.")" --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null

  continue # Se cancelado, volta ao menu principal

fi

  if [ -n "$arquivo" ]; then



command xdeb -Sde "$arquivo" | tee -a "$log"
if [ "${PIPESTATUS[0]}" -eq 0 ]; then
    yad --center --info --title="$title" \
        --text="$(gettext "Conversion with dependencies completed successfully!")" \
        --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null
else
    yad --center --error --title="$title" \
        --text="$(gettext "Error converting with dependencies.")" \
        --buttons-layout=center --button="$(gettext "OK")":0 2>/dev/null
fi



  fi

  ;;

"17") #

      xdeb -rb | tee -a "$log"

      continue # Se cancelado, volta ao menu principal
  ;;


    "0" | "") # Sair

      # Ignorar o aviso SC2005 do ShellCheck (permitir o uso de echo "$(gettext ...)")

      # shellcheck disable=SC2005

      echo "$(gettext "Leaving...")"

      break

      ;;

  esac

# ----------------------------------------------------------------------------------------

done



exit 0


