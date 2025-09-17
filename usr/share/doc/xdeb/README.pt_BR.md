### Atenção: Ignorar mensagens de erro em negrito pode bagunçar o seu sistema. Isso é resultado de uma verificação de erro ausente em xbps. Não culpe o script por isso.

# xdeb
xdeb é um script de shell script para converter pacotes deb(ian) para o formato xbps.

## Uso

### Convertendo pacotes
A conversão criará arquivos no seu diretório de trabalho atual. Consulte [as instruções de instalação](#Instalação) para obter mais informações.

1. Instalar dependências: `xbps-install binutils tar curl xbps xz gettext yad`
2. Baixar xdeb: `curl -LO github.com/xdeb-org/xdeb/releases/latest/download/xdeb`
3. Definir bit executável: `chmod 0744 xdeb`
4. Converter: `./xdeb -Sedf <name>_<version>_<arch>.deb`
5. Instalar: `xbps-install -R ./binpkgs <name>`

### Instalação
Copie o script para `/usr/local/bin/` e defina `XDEB_PKGROOT=${HOME}/.config/xdeb` para evitar bagunçar seu diretório de trabalho atual.
Os binários serão então exportados para `${XDEB_PKGROOT-.}/binpkgs`.

### Bandeiras
Resumindo: basta usar `-Sedf` (sincronizar lista de dependências, remover diretórios vazios, habilitar resolução de dependências, resolver conflitos = não danificar o sistema)

As opções também podem ser definidas por meio de variáveis ​​de ambiente:
```
export XDEB_OPT_DEPS=true
export XDEB_OPT_SYNC=true
export XDEB_OPT_INSTALL=true
export XDEB_OPT_FIX_CONFLICT=true
export XDEB_OPT_WARN_CONFLICT=true
```

Mais informações:
```sh
uso: xdeb [-S] [-d] [-Sd] [--deps] ... ARQUIVO
  -d                          Resolução automática de dependências
  -S                          Baixa o arquivo shlibs para dependências automáticas
  -c                          Como -C, excluindo shlibs e binpkgs
  -r                          Remove o arquivo repodata (Use para reconstruir)
  -R                          Não registra o pacote no pool do repositório.
  -q                          Extrai .deb apenas para o diretório dest, não compila
  -C                          Remove todos os arquivos criados por este script
  -b                          Compila diretamente do diretório dest sem um arquivo .deb
  -e                          Remove diretórios vazios do pacote
  -m                          Adiciona o sufixo de -32 bits ao nome do pacote
  -i                          Não avisa se o pacote pode danificar o sistema
  -f                          Tenta corrigir certos conflitos de arquivo (obsoleto)
  -F                          Não tenta corrigir certos conflitos de arquivo
  -I                          Instala o pacote automaticamente
  --deps=...                  Pacotes que devem ser adicionados como dependências
  --not-deps=...              Pacotes que não devem ser usados ​​como dependências
  --arch=...                  Arquitetura do pacote
  --name=...                  Nome do pacote
  --version=...               Versão do pacote
  --revision=... --rev=...    Revisão do pacote
  --post-extract=...          Arquivo com comandos pós-extração (ex.: /dev/stdin)
  --help | -h                 Mostrar página de ajuda

exemplo:
  xdeb -Cq                     Remover todos os arquivos e sair
  xdeb -Sd ARQUIVO             Sincronizar lista de dependências e criar pacote
  xdeb --deps='tar>0' ARQUIVO  Adicionar tar como dependência manual e criar pacote
```

#### Dependências Automáticas
Usar o recurso de dependência automática permite a conversão confiável de quase todos os pacotes deb.

Use `-Sd` para sincronizar [a lista de dependências](https://raw.githubusercontent.com/void-linux/void-packages/master/common/shlibs) e compilar com a resolução de dependências habilitada.
Execuções subsequentes não requerem `-S` e o xdeb não requer internet. Apenas certifique-se de sincronizá-lo de vez em quando.

#### Multilib
A flag `-m` (multilib) adiciona o sufixo `-32bit` ao pacote e às dependências.
Exemplo com arquitetura de host `x86_64`:
```sh
./xdeb -Sedfm --arch=x86_64 ~/Downloads/Simplenote-linux-1.16.0-beta1-i386.deb
```
**`/lib` will not be rewritten to `/lib32`**

#### Conflitos de arquivo
Devido à ausência de uma verificação, o gerenciador de pacotes xbps pode interromper o sistema caso um pacote contenha um arquivo que já esteja presente no sistema.
Como solução alternativa, o xdeb exibe avisos para arquivos conflitantes; **não os ignore**.
**Isso só funciona ao instalar pacotes na mesma máquina em que foram convertidos!**

Atualizar um pacote pode exibir vários avisos desnecessários. Desative usando `-i` (s**i**lência).

##### Resolução de conflitos
Os conflitos podem ser resolvidos automaticamente (`-f`) ou manualmente.

1. Pacote de construção: `xdeb ...`
2. Observe os avisos
3. Corrigir arquivos (Exemplo: remover): `rm -rf ${XDEB_PKGROOT-.}/destdir/usr/lib`
4. Crie o pacote sem conflitos: `./xdeb -rb`

#### Usando dependências manuais
Convertendo `Minecraft.deb` com dependência manual `oracle-jre` (Versão 8 ou posterior):
```sh
$ ./xdeb -Sedr --deps='oracle-jre>=8' ~/Downloads/Minecraft.deb
[+] Shlibs sincronizados
[+] Arquivos extraídos
[+] Dependências resolvidas (oracle-jre>=8 alsa-lib>=1.0.20_1 atk>=1.26.0_1
cairo>=1.8.6_1 dbus-libs>=1.2.10_1 expat>=2.0.0_1 fontconfig>=2.6.0_1
gdk-pixbuf>=2.22.0_1 glib>=2.18.0_1 glibc>=2.29_1 gtk+>=2.16.0_1 gtk+3>=3.0.0_1
libcups>=1.5.3_1 libgcc>=4.4.0_1 libstdc++>=4.4.0_1 libuuid>=2.18_1
libX11>=1.2_1 libxcb>=1.2_1 libXcomposite>=0.4.0_1 libXcursor>=1.1.9_1
libXdamage>=1.1.1_1 libXext>=1.0.5_1 libXfixes>=4.0.3_1 libXi>=1.2.1_1
libXrandr>=1.3.0_1 libXrender>=0.9.4_1 libXScrnSaver>=1.1.3_1 libXtst>=1.0.3_1
nspr>=4.8_1 nss>=3.12.4_1 pango>=1.24.0_1 zlib>=1.2.3_1)
índice: adicionado `minecraft-launcher-2.1.17627_1' (x86_64).
índice: 1 pacotes registrados.
[+] Pronto. Instalar usando `xbps-install -R binpkgs minecraft-launcher-2.1.17627_1`

$ sudo xbps-install -R ./binpkgs minecraft-launcher-2.1.17417_1

Nome               Ação    Versão             Nova versão          Tamanho do download
GConf              install   -                 3.2.6_9                - 
minecraft-launcher install   -                 2.1.17417_1            - 

Tamanho necessário no disco:      198MB
Espaço disponível no disco:       276GB

Você quer continuar? [S/n] n
```
Adicione `>0` para corresponder a qualquer versão (por exemplo, `--deps='tar>0 base-system>0 curl>0'`)


#### Ignorando dependências

Ao converter pacotes para aplicativos baseados em Electron, o `xdeb` pode
adicionar erroneamente `musl` como dependência. Isso pode ser resolvido usando a flag 
`--not-deps` para colocar certas dependências na lista negra:

```
$ ./xdeb -Sedf --not-deps="musl" ~/Downloads/gitkraken-amd64.deb
I Shlibs sincronizados
I Arquivos extraídos
W Não foi possível encontrar dependência para libcrypto.so.1.0.0
W Não foi possível encontrar dependência para libcrypto.so.1.1
W Não foi possível encontrar dependência para libcrypto.so.10
W Não foi possível encontrar dependência para libssl.so.1.0.0
W Não foi possível encontrar dependência para libssl.so.1.1
W Não foi possível encontrar dependência para libssl.so.10
I Dependências resolvidas (alsa-lib>=1.0.20_1 at-spi2-atk>=2.6.0_1 at-spi2-core>=1.91.91_1 atk>=1.26.0_1 cairo>=1.8.6_1 dbus-libs>=1.2.10_1 e2fsprogs-libs>=1.41.5_1 expat>=2.0.0_1 glib>=2.80.0_1 glibc>=2.39_1 gtk+3>=3.0.0_1 libX11>=1.2_1 libXcomposite>=0.4.0_1 libXdamage>=1.1.1_1 libXext>=1.0.5_1 libXfixes>=4.0.3_1 libXrandr>=1.3.0_1 libcups>=1.5.3_1 libcurl>=7.75.0_2 libdrm>=2.4.6_1 libgbm>=9.0_1 libgcc>=4.4.0_1 libstdc++>=4.4.0_1 libxcb>=1.2_1 libxkbcommon>=0.2.0_1 libxkbfile>=1.0.5_1 mit-krb5-libs>=1.8_1 nspr>=4.8_1 nss>=3.12.4_1 pango>=1.24.0_1 zlib>=1.2.3_1)
índice: ignorando `gitkraken-9.13.0_1' (x86_64), já registrado.
índice: 1 pacotes registrados.
I Instalar usando `xbps-install -R ./binpkgs gitkraken-9.13.0_1`
```

## Justificativa

- A equipe VoidLinux se recusa a lançar mais navegadores baseados em Chromium.
- Aplicações baseadas em elétrons, como [Simplenote](https://simplenote.com/)
- Aplicativos proprietários como [Discord](https://discord.gg) ou [Minecraft](https://minecraft.net).

A construção manual de pacotes é trabalhosa e exigiria aprender o sistema de construção, clonar o repositório [void-packages](https://github.com/void-linux/void-packages) (~150 MB), etc.<br>
Este script lida com tudo automaticamente e sem precisar acessar a internet por padrão.

