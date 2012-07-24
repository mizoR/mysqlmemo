MySQLで、カラムの仕様とかをメモするときに使うスクリプト

    $ cat memo.yaml
    # memo.yaml
    users:
      id:       プライマリーキー
      username: ユーザ名(4〜10chars, UNIQ)
      password: パスワード(8〜20chars)
      email:    メールアドレス(UNIQ)
     
    $ ruby mysqlmemo.rb -m memo.yml -h localhost -u root -p database_development
    <TABLE>
      <CAPTION>users</CAPTION>
      <TR>
        <TH>Field</TH><TH>Type</TH><TH>Null</TH><TH>Key</TH><TH>Default</TH><TH>Extra</TH><TH>Memo</TH>
      </TR><TR>
        <TD>id</TD><TD>int(11)</TD><TD>NO</TD><TD>PRI</TD><TD>NULL</TD><TD>auto_increment</TD><TD>プライマリーキー</TD>
      </TR><TR>
        <TD>username</TD><TD>varchar(255)</TD><TD>NO</TD><TD></TD><TD>NULL</TD><TD></TD><TD>ユーザ名(4〜10chars, UNIQ)</TD>
      </TR><TR>
        <TD>password</TD><TD>varchar(255)</TD><TD>NO</TD><TD></TD><TD>NULL</TD><TD></TD><TD>パスワード(8〜20chars)</TD>
      </TR><TR>
        <TD>email</TD><TD>varchar(255)</TD><TD>NO</TD><TD>UNI</TD><TD></TD><TD></TD><TD>メールアドレス(UNIQ)</TD>
      </TR>
    </TABLE>

