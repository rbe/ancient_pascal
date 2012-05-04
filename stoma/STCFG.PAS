program stoma_conf;
{$i-}

uses crt, dos, kode;

type conf =record
             datadir :string;
             security :boolean;
             pass :string;
           end;

var sc  :conf;
    cfg :file of conf;
    c   :char;
    i   :shortint;
    s   :string;
    a   :word;

procedure code_data;
begin
  sc.datadir:=code(sc.datadir);
  sc.pass:=code(sc.pass);
end;

procedure decode_data;
begin
  sc.datadir:=decode(sc.datadir);
  sc.pass:=decode(sc.pass);
end;

procedure readcfg;
begin
  clrscr;
  writeln; writeln ('STOMA-Konfigurationsdatei:');
  for i:=1 to 80 do write ('=');
  writeln;
  while not eof(cfg) do begin
    read(cfg,sc);
    decode_data;
    writeln ('Sicherheitscodierung: ',sc.security);
    writeln ('Datenpfad           : ',sc.datadir);
  end;
  if sc.security then begin
    write ('Code „ndern ?'); c:=readkey; if(upcase(c)='J') then begin
      write ('alter code: '); readln(s);
      if (s=sc.pass) then begin
        write ('neuer code: '); readln(s);
        sc.pass:=code(s); a:=filepos(cfg); seek(cfg,a-1); write(cfg,sc);
      end else writeln ('code nicht ge„ndert!');
    end;
  end;
  close(cfg);
  writeln;
  writeln ('Ende der .CFG-Datei');
  writeln;
  writeln;
end;

procedure makecfg;
begin
  clrscr;
  writeln ('STOMA-Konfigurationsdatei: ERSTELLEN');
  for i:=1 to 80 do write ('=');
  writeln;
  write ('Wollen Sie Sicherheits-Codierung der Daten ? ');
  c:=readkey; c:=upcase(c); writeln(c);
  writeln;
  if c='J' then begin
    sc.security:=true;
    write('Code: ');
    while (c<>#13) do begin
      c:=readkey;
      if c<>#13 then begin write('*'); sc.pass:=sc.pass+c; end;
    end;
  end else sc.security:=false;
  writeln; writeln;
  write ('Pfad der Datendatei: ');
  readln(sc.datadir);
  code_data;
  write(cfg,sc);
  close(cfg);
  writeln; writeln;
  writeln ('Konfiguration geschrieben!');
  writeln;
end;

begin
  assign(cfg,'stoma.cfg');
  reset(cfg);
  if ioresult<>0 then begin
    writeln('Konnte STOMA.CFG nicht ”ffnen!');
    write ('Erstellen ? ');
    c:=readkey; if(upcase(c)='J') then begin
      rewrite(cfg);
      makecfg;
    end else halt;
  end else readcfg;
end.
