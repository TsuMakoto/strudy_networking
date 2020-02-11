# nginxを勉強する！ with マスタリングNginx

webエンジニアとしてせめてnginxくらい知っておきたいので、勉強します。

今はdockerで簡単にnginxの環境が構築できるので、その恩恵に預かろうと思います。

```shell
docker run -it --rm nginx:1.17-alpine ash

```

これで、nginxの環境が構築できます。本書を進めていきましょう！

## ちょっと不便なので、いくつか

vimとgitを入れときましょう。

`apk update && apk add vim git`

## 設定ファイルのフォーマット

Nginxの設定フォーマットは以下のようになってます。

```nginx
<section> {
  <directive> <parameter>;
}
```
このフォーマットにしたがって、設定ファイルを書いていくこととします。

## Nginxのグローバル設定

グローバル設定は前項のフォーマットとは例外になってる項目です。

ディレクティブを設定するために用いられ、userやworker_processesなどの設定を行います。



```julia
using CSV
CSV.read("directive/global.csv")
```

    thread = 1 warning: parsed expected 2 columns, but didn't reach end of line on data row: 3. Ignoring any extra columns on this row





<table class="data-frame"><thead><tr><th></th><th>ディレクティブ</th><th> 説明</th></tr><tr><th></th><th>String</th><th>String</th></tr></thead><tbody><p>6 rows × 2 columns</p><tr><th>1</th><td>user</td><td> ワーカーロセスを実行するユーザー名とグループ名が設定される。グループ名が省略された場合、グループ名はユーザー名と同一とみなされる。</td></tr><tr><th>2</th><td>worker_processes</td><td> 起動されるワーカープロセス数を示す。ワーカープロセスがクライアントからのコネクションすべてを処理する。適切な値はサーバー環境、ディスクサブシステム、ネットワークインフラなどに依存するが、経験則としては、CPUネックの場合はプロセッサコア数と同等に、I/Oネックの場合はプロセッサコア数を1.5から2倍した値に設定するのがよい。</td></tr><tr><th>3</th><td>error_log</td><td> error_logはすべてのエラーが書き込まれるファイルを指定する。(debug</td></tr><tr><th>4</th><td>pid</td><td> メインプロセスのプロセスIDが書き込まれるファイルを示す。</td></tr><tr><th>5</th><td>use</td><td> useディレクティブは利用するコネクション処理方式を示し、コンパイル時のディフォルト血を上書きする。</td></tr><tr><th>6</th><td>worker_connection</td><td> ワーカープロセスが同時にオープン可能なコネクションの最大数を設定する。</td></tr></tbody></table>



本書で取り扱われている例の設定を紹介しよう。

```nginx
# nginxを「www」ユーザーで実行させる
user www;

# 負荷がCPUネックで12コアのシステム
worker_processes 12;

# エラーログのパスを明示的に指定する
error_log /var/log/nginx/error.log;

# pidファイルのパスも明示的に指定する
pid /var/run/nginx.pid;

# 「event」モジュール用のコンテキストを設定
events {
    # Solarisベースのシステムにおいて、デフォルトのコネクション処理機構を
    # 用いた場合、時間の経過とともに、nginxが新規リクエストに対するレスポ
    # ンスを行わなくなってしまうことを確認した。そのため、次善の作として
    # 別の機構に切り替える。
    use /dev/poll;
    
    # この数値とworker_porocessesの数値は、IPアドレス：ポート番号のペアで、
    # 同時に受付可能な可能なコネクション数を示す。
    worker_connections 2048;
}

```

## インクルードファイルの利用
可読性を高めるためや、再利用可能にするため、nginxの設定をファイルに分けるということができます。

`include /opt/local/etc/nginx/mime.types;`

複数のファイルを指定するために、ワイルドカードを用いることも可能です。

`include /opt/local/etc/nginx/vhost/*.conf`

フルパスが指定されなかった場合、Nginxはメインの設定ファイルからの相対パスを検索します。

## HTTPサーバセクション
HTTPサーバーセクション（httpコンテキスト）はNginxのビルドの際にHTTPモジュールを無効化（--without-http）しない限り利用できます。

### クライアントディレクティブ

このディレクティブはさまざまなクライアントの種類やクライアントからのコネクションそのものを制御します。


```julia
CSV.read("directive/http_client.csv")
```




<table class="data-frame"><thead><tr><th></th><th>ディレクティブ</th><th> 説明</th></tr><tr><th></th><th>String</th><th>String</th></tr></thead><tbody><p>13 rows × 2 columns</p><tr><th>1</th><td>chunked_transfer_encoding</td><td>クライアントへのレスポンスの際に、HTTP/1.1標準のチャンク転送エンコードを無効にする</td></tr><tr><th>2</th><td>client_body_buffer_size</td><td>クライアントからのリクエストボディを読み取る際のバッファサイズを指定する。デフォルトはページサイズの２倍。リクエストボディが これを超える場合はテンポラリファイルに書き込まれる。</td></tr><tr><th>3</th><td>client_body_in_file_only</td><td>本ディレクティブにより、Nginxはクライアントからのリクエストボディに追加の処理を行う場合に用いる。本ディレクティブをonにする。 本ディレクティブをonにすることで、クライアントからのリクエストボディが強制的にファイルに保存される。</td></tr><tr><th>4</th><td>client_body_in_single_buffer</td><td>本ディレクティブにより、Nginxはクライアントからのリクエストボディ全体を強制的に単一のバッフォに保存するため、コピー操作が提言される</td></tr><tr><th>5</th><td>client_body_temp_path</td><td>クライアントからのリクエストボディを保存するパスを設定する</td></tr><tr><th>6</th><td>client_body_timeout</td><td>クライアントからのリクエストボディを読み取る際のタイムアウト値を指定する</td></tr><tr><th>7</th><td>client_header_buffer_size</td><td>クライアントからのリクエストヘッダのバッファサイズ。デフォルトの1KBを超えるサイズが必要となった際に設定する</td></tr><tr><th>8</th><td>client_max_body_size</td><td>クライアントからのリクエストボディの最大長。これを超えた場合、413(Request Entiry Too Large)エラーがブラウザに返却される</td></tr><tr><th>9</th><td>keepalive_disable</td><td>ブラウザからのキープアライブリクエストを無効にする</td></tr><tr><th>10</th><td>keepalive_requests</td><td>単一のキープアライブコネクションからクローズされるまでに発行可能なリクエスト数を指定する</td></tr><tr><th>11</th><td>large_client_header_buffers</td><td>クライアントからのリクエストヘッダの最大数と最大サイズを指定する</td></tr><tr><th>12</th><td>msie_padding</td><td>Internet Explore(MSIE)クライアントが400以上のステータスでレスポンスを返却する際に、レスポンスのサイズを512バイト以上 にするためにコメントを追加する機能を有効にする</td></tr><tr><th>13</th><td>msie_refresh</td><td>MSIEクライアントに対して、リダイレクトを送信する代わりにリフレッシュを送信する機構を有効にする</td></tr></tbody></table>



### ファイルI/Oディレクティブ
このディレクティブは、Nginxが静的なファイルを配信する方法と、ファイルディスクリプタを管理する方法を制御します。

> ファイルディスクリプタとは、プログラムからファイルを操作する際、操作対象のファイルを識別・同定するために割り当てられる番号。
> OSにアクセスを依頼する際にファイルを指定するのに用いられる整数値である。
> 主にUNIX系OSで用いられる仕組みで、Windowsではファイルハンドル（file handle）がほぼこれに相当する仕組みを提供する。



```julia
CSV.read("directive/file_io.csv")
```




<table class="data-frame"><thead><tr><th></th><th>ディレクティブ</th><th> 説明</th></tr><tr><th></th><th>String</th><th>String</th></tr></thead><tbody><p>11 rows × 2 columns</p><tr><th>1</th><td>aio</td><td>非同期ファイルI/Oの使用を有効にする。これは、最近のFreeBSDおよびLinuxディストリビューションのすべてで利用できる。FreeBSDの場合、 aioはsendfuke用のデータをあらかじめロードしておくために用いられることがある。Linuxの場合directioも有効にする必要があるため、 sendfileが自動的に無効となる。</td></tr><tr><th>2</th><td>directio</td><td>パラメータで指定されたサイズより大きいファイルを配信する際に、OS固有のフラグや関数を有効にする。これはLinuxでaioを用いる際に 必須である。</td></tr><tr><th>3</th><td>directio_alignment</td><td>directioで用いるアラインメントを設定する。デフォルオ値の512で通常は十分だが、LinuxでXFSを用いる際は、この値を4Kに増やしておく ことを推奨する</td></tr><tr><th>4</th><td>open_file_cache</td><td>オープン中のファイルディスクリプタ、ディレクトリ検索結果、ファイル検索結果のエラーを格納するキャッシュを設定する</td></tr><tr><th>5</th><td>open_file_cache_errors</td><td>open_file_cacheによるファイル検索ケッアエラーのキャッシュを有効にする</td></tr><tr><th>6</th><td>open_file_cache_min_uses</td><td>ファイルディスクリプタをオープンしたままキャッシュ内に保持し続ける上で、open_file_cacheのinactiveパラメータで指定 された時間内に最低何回の使用を必要とするかを設定する。</td></tr><tr><th>7</th><td>open_file_cache_valid</td><td>open_file_cache内のエントリの有効性をチェックする時間感覚を設定する</td></tr><tr><th>8</th><td>postpone_output</td><td>Nginxがクライアントに送信するデータの最小サイズを指定する。他の要因がなければ、この値を超えるまではいかなるデータも 送信されない</td></tr><tr><th>9</th><td>read_ahead</td><td>可能な場合、カーネルはsizeパラメータで指定したサイズまでファイルをあらかじめ読み取っておく。本パラメータは現在のとこFreeBSDと Linuxでのみサポートされている。(Linuxにおいてsizeパラメータは無視される)</td></tr><tr><th>10</th><td>sendfile</td><td>sendfile(2)を用いることで、あるファイルディスクリプタから別のファイルディスクリプタへのデータの直接コピーを可能とする</td></tr><tr><th>11</th><td>sendfile_max_chunk</td><td>ワーカプロセスが待機してしまうことを避けるため、1回のsendfile(2) 呼び出しでコピー可能なデータの最大サイズを指定する</td></tr></tbody></table>



### ハッシュディレクティブ
ハッシュ関連のディレクティブは、Nginxが個々の変数に割り当てる静的なメモリ領域の範囲を制御します。


```julia
CSV.read("directive/hash.csv")
```




<table class="data-frame"><thead><tr><th></th><th>ディレクティブ</th><th> 説明</th></tr><tr><th></th><th>String</th><th>String</th></tr></thead><tbody><p>5 rows × 2 columns</p><tr><th>1</th><td>server_names_hash_bucket_size</td><td>server_nameハッシュテーブルを保持するエントリのサイズを指定する</td></tr><tr><th>2</th><td>server_names_hash_max_size</td><td>server_nameハッシュテーブルの最大エントリ数を指定する</td></tr><tr><th>3</th><td>types_hash_bucket_size</td><td>typesハッシュテーブルの最大エントリ雛を指定する</td></tr><tr><th>4</th><td>variables_hash_bucket_size</td><td>その他の変数を保持するエントリ野サイズを指定する</td></tr><tr><th>5</th><td>variables_hash_maz_size</td><td>その他の変数の保持するハッシュテーブルの最大エントリ数を指定する</td></tr></tbody></table>



### ソケットディレクティブ
Nginxが生成するTCPソケットに関するさまざまなオプションを設定します。


```julia
CSV.read("directive/socket.csv")
```

    thread = 1 warning: parsed expected 2 columns, but didn't reach end of line on data row: 5. Ignoring any extra columns on this row





<table class="data-frame"><thead><tr><th></th><th>ディレクティブ</th><th> 説明</th></tr><tr><th></th><th>String</th><th>String</th></tr></thead><tbody><p>8 rows × 2 columns</p><tr><th>1</th><td>lingering_close</td><td>クライアントからのコネクションをクローズする際に、追加で送信されたデータへの対応を制御する</td></tr><tr><th>2</th><td>lingering_time</td><td>本ディレクティブは、lingering_closeディレクティブが有効になっているコネクションで、通過で送信されたデータを処理するために コネクションをオープンしておく時間を指定する</td></tr><tr><th>3</th><td>ligering_timeout</td><td>本ディレクティブも、lingering_closeと組み合わせる事で、Nginxがコネクションをクローズする前に、追加されたデータを待ち受ける時間を 指定する</td></tr><tr><th>4</th><td>reset_timedout_connection</td><td>本ディレクティブが有効な場合、タイム会うとしたコネクションは即座にリセットされ、関連するメモリがすべて開放される。デフォルトでは、 ソケットがFIN_WAIT1の状態のまま残る。キープアライブコネクションは、常にデフォルトの動作を行う</td></tr><tr><th>5</th><td>send_lowat</td><td>0以外の場合、Nginxはクライアントとのソケットにおける送信処理の回数を最小化しようとする。Linux</td></tr><tr><th>6</th><td>send_timeout</td><td>書き込み処理に対するクライアントからのレスポンスのタイムアウト値を設定する</td></tr><tr><th>7</th><td>tcp_nodelay</td><td>キープアライブコネクションに対するTCP_NODELAYオプションの有効化、無効化を制御する</td></tr><tr><th>8</th><td>tcp_nopush</td><td>sendfileを使っている場合のみ有効である。有効かすることで、可能な限り最大サイズのパケットを用いてファイルを送信する といった動作を試行するようにする</td></tr></tbody></table>



### 設定例
```nginx
http {
    include /opt/local/etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    server_names_hash_max_size 1024;
}
```
このコンテキストブロックは、nginx.confファイルでグローバル設定ディレクティブの後に配置します。

## 仮想サーバーセクション
serverから始まるコンテキストは「仮想サーバー」セクションとして扱われます。

仮想サーバにより、リソース群が論理的に分割されて別々のserver_nameディレクティブで配信されるようになります。


仮想サーバはlistenとserver_nameディレクティブにより定義されます。
listenディレクティブは、次のように、IPアドレスとポート番号のペア、もしくはUNIXドメインソケットのパスを指定します。
```nginx
listen address[:port];
listen port;
listen unix:path;
```



```julia
CSV.read("params/listen.csv")
```




<table class="data-frame"><thead><tr><th></th><th>パラメータ</th><th> 説明</th></tr><tr><th></th><th>String</th><th>String</th></tr></thead><tbody><p>11 rows × 2 columns</p><tr><th>1</th><td>default_server</td><td> リクエストがデフォルトで処理されるaddress:portのペアを定義する</td></tr><tr><th>2</th><td>setfib</td><td> 待ち受けているソケットにFIBを設定する。</td></tr><tr><th>3</th><td>backlog</td><td> listen()のbacklogパラメータを指定する</td></tr><tr><th>4</th><td>rcvbuf</td><td> 待ち受けているソケットにSO_RCVBUFパラメータを設定する</td></tr><tr><th>5</th><td>sndbuf</td><td> 待ち受けているソケットにSO_SNDBUFパラメータを設定する</td></tr><tr><th>6</th><td>accept_filter</td><td> accept filter名としてdatareadyもしくはhttpreadyを設定する</td></tr><tr><th>7</th><td>deferred</td><td> 遅延accept()を用いるためにTCP_DEFER_ACCEPTオプションを設定する。</td></tr><tr><th>8</th><td>bind</td><td> address:portのペアに対して個別にbind()を行う</td></tr><tr><th>9</th><td>ipv6only</td><td> IPV6_V6ONLYパラメータの値を指定する</td></tr><tr><th>10</th><td>ssl</td><td> このポートではHTTPSのコネクション以外実行しないことを示す</td></tr><tr><th>11</th><td>so_keepalive</td><td> 待ち受けているソケットに対して、TCPキープアライブを設定する。</td></tr></tbody></table>



nginxはあるリクエストに対して、どの仮想サーバーで処理を行うかのロジックは以下です。

1. listenディレクティブのIPアドレスとポート番号がマッチしているか 
2. Hostヘッダフィールドがserver_nameディレクティブに指定された文字列にマッチしているか
3. Hostヘッダフィールドがserver_nameディレクティブに指定された先頭にあるワイルドカードのある文字列にマッチしているか
4. Hostヘッダフィール度がserver_nameディレクティブに指定された最後尾のワイルドカードのある文字列にマッチしているか
5. Hostヘッダフィール度がserver_nameディレクティブに指定された正規表現で指定された文字列にマッチしているか
6. Hostへっだフィールドの対応漬けに失敗した場合、default_serverが指定されたlistenディレクティブにマッチするか
7. Hostヘッダフィールドの対応づけに失敗し、default_serverが未定義の場合、上記[1]を満たすlistenディレクティブが設定されている先頭のサーバにマッチするか

## ロケーション

locationディレクティブは仮想サーバセクション内で用いられ、クライアントが指定したURIもしくは内部リダイレクトで転送されたURIを示します。
ロケーションはいくつかの例外を除き、ネストすることが可能で、特定の設定を用いてリクエストの処理を行うために用いられます。

```nginx
location [修飾子] uri { ... }
```

名前付きは以下です。
```nginx
location @name { ... }
```

リクエストがあると、つぎのようにリクエストのURIのマッチするロケーションの確認が行われます。

- 正規表現の含まれていない文字列のロケーションに対して、文字列先頭からの最長一致でマッチするロケーションの確認が行われます。
- 正規表現が含まれているロケーションが設定ファイルで定義された順に確認される。
正義表現のチェックは最初にマッチしたロケーションで終了し、そのロケーションが処理に用いられる。

## 設定ファイルの全容

```nginx
user www; 
worker_processes 12;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    use /dev/poll;
    worker_connections 2048;
}

http {
    include /opt/local/etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    server_names_hash_max_size 1024;
    
    server {
        listen 80;
        return 444;
    }
    
    server {
        listen 80;
        server_name www.example.com;
        
        location / {
            try_files $uri $uri/ @mongrel;
        }
        
        location @mongrel {
            proxy_pass http://127.0.0.1:8080;
        }
    }
}
```

## 終わり
これが基本的なNginxの設定ファイルの作成方法です。
次回からはメールモジュールについてみていきます。


```julia

```
