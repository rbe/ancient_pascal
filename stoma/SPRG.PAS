program Stoma;
{$i-}

uses crt, dos, printer;

type data =record
             name,vorname,strasse,plzort,
             tele,geb,kk, diagnose, stomaanlage,
             versorgung :string;
             termin :string[20];
             gel :boolean;
           end;
     conf =record
             datadir  :string[20];
             security :boolean;
           end;

var d    :data;
    f    :file of data;
    cfg  :file of conf;
    sc   :conf;
    f2,
    f3   :text;
    s, olddir,
    ss   :string;
    c    :char;
    i,
    wy   :integer;
    neu, secure,
    ende :boolean;
    y, m, day,
    dw   :word;

function code(cs :string): string;
var zahl :integer;
    ch   :string;

begin
  ch:='';
  for i:=1 to length(cs) do begin
    zahl:=ord(cs[I])+64;
    ch:=ch+chr(zahl);
  end;
  code:=ch;
end;

function decode(cs :string): string;
var satz   :string[3];
    blanks :byte;
    j, h,
    hilf   :integer;
    ascii  :string;

begin
  ascii:='';
  blanks:=0;
  for i:=1 to length(cs)-1 do begin
    j:=pos(' ',cs);
    if j>0 then inc(blanks);
    insert('d',cs,j);
    delete(cs,j+1,1);
  end;
  for i:=1 to blanks do begin
    h:=j+1;
    j:=pos('d',cs);
    insert(' ',cs,j);
    delete(cs,j+1,1);
    satz:=copy(cs,h,j-h);
  end;
  for i:=1 to length(cs) do begin
    hilf:=ord(cs[i]);
    hilf:=ord(hilf)-64;
    ascii:=ascii+chr(hilf);
  end;
  decode:=ascii;
end;

procedure taste;
begin
  gotoxy(1,25);
  write ('Taste drÅcken...'); clreol;
  c:=readkey;
end;

procedure code_data;
begin
  d.name:=code(d.name);
  d.vorname:=code(d.vorname);
  d.strasse:=code(d.strasse);
  d.plzort:=code(d.plzort);
  d.geb:=code(d.geb);
  d.tele:=code(d.tele);
  d.kk:=code(d.kk);
  d.diagnose:=code(d.diagnose);
  d.versorgung:=code(d.versorgung);
  d.stomaanlage:=code(d.stomaanlage);
  d.termin:=code(d.termin);
end;

procedure decode_data;
begin
  d.name:=decode(d.name);
  d.vorname:=decode(d.vorname);
  d.strasse:=decode(d.strasse);
  d.plzort:=decode(d.plzort);
  d.geb:=decode(d.geb);
  d.tele:=decode(d.tele);
  d.kk:=decode(d.kk);
  d.diagnose:=decode(d.diagnose);
  d.versorgung:=decode(d.versorgung);
  d.termin:=decode(d.termin);
end;

procedure code_schr;
begin
  code_data;
  write(f,d);
  if ioresult<>0 then begin
    window(1,1,80,25);
    clrscr;
    write ('Fehler ');
    case doserror of
      5 :write ('Zugriff verweigert');
      6 :write ('Handle ungÅltig');
      else write ('Nr ',doserror);
    end;
    writeln (' beim Schreiben der Datendatei!');
    write ('(N)ochmal versuchen oder (a)bbrechen ? ');
    c:=readkey;
    c:=upcase(c);
    case c of
      'W' :code_schr;
      'A' :begin
             writeln; writeln;
             writeln ('Daten konnten nicht geschrieben werden!!');
             writeln ('========================================');
             taste;
           end;
      end;
  end;
end;

procedure code_lies;
begin
  read(f,d);
  decode_data;
end;

procedure schr;
begin
  write(f,d);
  if ioresult<>0 then begin
    window(1,1,80,25);
    clrscr;
    write ('Fehler ');
    case doserror of
      5 :write ('Zugriff verweigert');
      6 :write ('Handle ungÅltig');
      else write ('Nr ',doserror);
    end;
    writeln (' beim Schreiben der Datendatei!');
    write ('(N)ochmal versuchen oder (a)bbrechen ? ');
    c:=readkey;
    c:=upcase(c);
    case c of
      'W' :schr;
      'A' :begin
             writeln; writeln;
             writeln ('Daten konnten nicht geschrieben werden!!');
             writeln ('========================================');
             taste;
           end;
      end;
  end;
end;

procedure lies;
begin
  read(f,d);
end;

procedure o;
begin
  assign(f,'data.stm');
  reset(f);
end;

procedure cl;
begin
  close(f);
end;

procedure oeffnen;
begin
  neu:=false;
  assign(f,'data.stm');
  reset(f);
  if ioresult<>0 then begin
    writeln ('Datendatei neu geîffnet!!');
    rewrite(f);
    neu:=true;
  end;
  writeln ('Datei ordnungsgemÑ· geîffnet!');
  close(f);
end;

procedure maske;
begin
  for i:=1 to 80 do write ('=');
  writeln ('Name         : ');
  writeln ('Vorame       : ');
  writeln ('Stra·e       : ');
  writeln ('PLZ/Wohnort  : ');
  writeln ('Telefon      : ');
  writeln ('Geburtsdatum : ');
  writeln ('Krankenkasse : ');
  writeln ('n. Termin am : ');
  writeln ('Diagnose     : ');
  writeln; writeln;
  writeln ('Versorgung   : ');
  writeln; writeln;
  writeln ('Stomaanlage  : ');
  writeln; writeln;
  for i:=1 to 80 do write ('=');
end;

procedure allenamen;
begin
  clrscr;
  o;
  while not eof(f) do begin
    if secure then code_lies else lies;
    if not d.gel then
      writeln ('- ',d.name,', ',d.vorname,'; ',d.strasse,', ',d.plzort);
    if wherey>23 then begin
      taste;
      clrscr;
    end;
  end;
  taste;
  cl;
end;

procedure eingabe;
var a:longint;
begin
  o;
  a:=filesize(f);
  seek(f,a);
  repeat
    ende:=false;
    clrscr;
    maske;
    window(20,2,80,25);
    readln(d.name);
    readln(d.vorname);
    if (d.name='') and (d.vorname='') then begin
      window(1,1,80,25);
      exit;
    end;
    readln(d.strasse);
    readln(d.plzort);
    readln(d.tele);
    readln(d.geb);
    readln(d.kk);
    readln(d.termin);
    wy:=wherey;
    readln(d.diagnose);
    gotoxy(1,wy+3);
    wy:=wherey;
    readln(d.versorgung);
    gotoxy (1,wy+3);
    readln(d.stomaanlage);
    d.gel:=false;
    if not ende then
      if secure then code_schr else schr;
    window(1,1,80,25);
    if not ende then begin
      gotoxy(1,25);
      write ('Noch ein Eingabe machen ?');
      c:=readkey; write(upcase(c));
    end;
  until (upcase(c)='N') or ende;
  cl;
end;

procedure ausgabe;
begin
  o;
  while not eof(f) do begin
    if secure then code_lies else lies;
    if not d.gel then begin
      clrscr;
      maske;
      window(20,2,80,25);
      writeln(d.name);
      writeln(d.vorname);
      writeln(d.strasse);
      writeln(d.plzort);
      writeln(d.tele);
      writeln(d.geb);
      writeln(d.kk);
      writeln(d.termin);
      wy:=wherey;
      writeln(d.diagnose);
      gotoxy(1,wy+3);
      wy:=wherey;
      writeln(d.versorgung);
      gotoxy(1,wy+3);
      writeln(d.stomaanlage);
      window(1,1,80,25);
      if (not eof(f)) then begin
        gotoxy(1,25);
        write ('Weiter ?');
        c:=readkey; write (upcase(c));
        if upcase(c)='N' then exit;
      end else begin
        gotoxy(1,25);
        write ('Taste drÅcken...');
        repeat until keypressed;
        exit;
      end;
    end;
  end;
  cl;
end;

procedure loeschen;
var a, such :byte;
begin
  write ('Patient: ');
  readln(ss);
  if ss='' then exit;
  gotoxy(1,wherey-1); clreol;
  o; seek(f,0); d.gel:=false;
  while (not eof(f)) and (not d.gel) do begin
    if secure then code_lies else lies;
    such:=pos(ss,d.name);
    if such>0 then begin
      write('Patient ',ss,' wirklich lîschen ? ');
      c:=readkey;
      writeln(upcase(c));
      gotoxy(1,wherey-1);
      if (upcase(c)='J') then begin
        write ('Lîsche "',ss,'"....');
        d.gel:=true;
        a:=filepos(f);
        seek(f,a-1);
        schr;
      end;
      gotoxy(1,wherey-1);
      write ('Patient "',ss,'" aus Kartei entfehrnt!');
    end;
  end;
  if not d.gel then write ('Patient ',ss,' nicht gefunden!');
  taste;
  cl;
end;

procedure lrueck;
var such, a :byte;
    g :boolean;
begin
  g:=false;
  write ('Patient: ');
  readln(ss);
  if ss='' then exit;
  gotoxy(1,wherey-1); clreol;
  o; seek(f,0);
  while (not eof(f)) do begin
    if secure then code_lies else lies;
    such:=pos(ss,d.name);
    if (such>0) and (d.gel) then begin
      writeln ('Mache lîschen rÅckgÑngig "',ss,'"....');
      d.gel:=false; g:=true;
      a:=filepos(f);
      seek(f,a-1);
      schr;
      write ('Patient "',ss,'" der Kartei wieder zugefÅgt!');
    end;
  end;
  if not g then write ('Patient "',ss,'" nicht gefunden!');
  taste;
  cl;
end;

procedure zeige;
begin
  clrscr;
  maske;
  window(20,2,80,25);
  writeln(d.name);
  writeln(d.vorname);
  writeln(d.strasse);
  writeln(d.plzort);
  writeln(d.tele);
  writeln(d.geb);
  writeln(d.kk);
  writeln(d.termin);
  wy:=wherey;
  writeln(d.diagnose);
  gotoxy(1,wy+3);
  wy:=wherey;
  writeln(d.versorgung);
  gotoxy(1,wy+3);
  writeln(d.stomaanlage);
  window(1,1,80,25);
  exit;
end;

procedure suchen;
begin
  write ('Suchstring eingeben: ');
  readln (ss);
  if ss='' then exit;
  o;
  while not eof(f) do begin
    if secure then code_lies else lies;
    if (pos(ss,d.name)>0) then begin zeige; taste; end;
    if (pos(ss,d.vorname)>0) then begin zeige; taste; end;
    if (pos(ss,d.strasse)>0) then begin zeige; taste; end;
    if (pos(ss,d.plzort)>0) then begin zeige; taste; end;
    if (pos(ss,d.tele)>0) then begin zeige; taste; end;
    if (pos(ss,d.geb)>0) then begin zeige; taste; end;
    if (pos(ss,d.kk)>0) then begin zeige; taste; end;
    if (pos(ss,d.termin)>0) then begin zeige; taste; end;
  end;
  cl;
end;

procedure aendern;
var ok  :boolean;
    a   :byte;
    old :string;
begin
  ende:=false;
  write ('Patient: ');
  readln(ss);
  o;
  while not eof(f) do begin
    if secure then code_lies else lies;
    if (pos(ss,d.name)>0) or (pos(ss,d.vorname)>0) then begin
      ok:=true;
      zeige;
      window(20,2,80,25);
      old:=d.name;
      readln(d.name);
      if d.name='' then d.name:=old;
      old:=d.vorname;
      readln(d.vorname);
      if d.vorname='' then d.vorname:=old;
      old:=d.strasse;
      readln(d.strasse);
      if d.strasse='' then d.strasse:=old;
      old:=d.plzort;
      readln(d.plzort);
      if d.plzort='' then d.plzort:=old;
      old:=d.tele;
      readln(d.tele);
      if d.name='' then d.tele:=old;
      old:=d.geb;
      readln(d.geb);
      if d.geb='' then d.geb:=old;
      old:=d.kk;
      readln(d.kk);
      if d.kk='' then d.kk:=old;
      old:=d.termin;
      readln(d.termin);
      if d.termin='' then d.termin:=old;
      wy:=wherey;
      old:=d.diagnose;
      readln(d.diagnose);
      if d.diagnose='' then d.diagnose:=old;
      gotoxy(1,wy+3);
      wy:=wherey;
      old:=d.versorgung;
      readln(d.versorgung);
      if d.versorgung='' then d.versorgung:=old;
      gotoxy (1,wy+3);
      old:=d.stomaanlage;
      readln(d.stomaanlage);
      if d.stomaanlage='' then d.stomaanlage:=old;
      d.gel:=false;
      a:=filepos(f);
      seek(f,a-1);
      if not ende then if secure then code_schr else schr;
    end;
  end;
  if not ok then begin
    write ('Patient "',ss,'" nicht gefunden!');
    taste;
  end;
  window(1,1,80,25);
  cl;
end;

procedure besuch;
var nam :boolean;
    fp  :byte;
    b   :string;

procedure search;
begin
  while (not eof(f)) and (not nam) do begin
    if secure then code_lies else lies;
    if (pos(ss,d.name)>0) then nam:=true;
  end;
end;

begin
  o;
  nam:=false;
  write ('Patient: ');
  readln(ss);
  search;
  cl;
  clrscr;
  if nam then begin
    assign(f3,d.name+'.bes');
    append(f3);
    if ioresult<>0 then begin
      writeln ('Besuchsdatendatei kann nicht geîffnet werden!');
      write ('Datei fÅr Patient "',ss,'" neu erstellen ? ');
      c:=readkey;
      c:=upcase(c); write (c);
      if c='J' then rewrite(f3) else exit;
    end;
    zeige;
    window(1,20,80,22);
    write ('Besuchsdaten eingeben: ');
    window(24,20,80,24);
    repeat
      readln(b);
      if b<>'#e#' then writeln (f3, b);
     until b='#e#';
    window(1,1,80,25);
  end else begin
    writeln ('Patient "',ss,'" nicht gefunden!');
    taste;
  end;
  close(f3);
end;

procedure zeigebesuch;
var b :string;
begin
  assign (f3,d.name+'.bes');
  reset(f3);
  if ioresult<>0 then begin
    writeln ('Besuchsdatendatei kann nicht geîffnet werden!');
    c:=readkey;
  end;
  clrscr;
  for i:=1 to 80 do write ('=');
  writeln ('Patient: ');
  writeln; writeln;
  writeln ('Besuchsdaten:');
  gotoxy(1,24);
  for i:=1 to 80 do write ('=');
  window(20,2,80,23);
  writeln(d.name,', ',d.vorname);
  writeln(d.plzort,', ',d.strasse,', ',d.tele);
  writeln;
  while not eof(f3) do begin
    readln(f3,b);
    writeln (b);
    if wherey>22 then begin
      window(1,1,80,25);
      taste;
      window(20,2,80,23);
     end;
  end;
  window(1,1,80,25);
  taste;
  close(f3);
end;

procedure besuchansehen;
var nam :boolean;
    b   :string;

begin
  nam:=false;
  write ('Patient: ');
  readln(ss);
  o;
  while (not eof(f)) and (not nam) do begin
    if secure then code_lies else lies;
    if (pos(ss,d.name)>0) then begin
      nam:=true;
      zeigebesuch;
      exit;
    end;
  end;
  writeln ('Patient ',ss,' nicht gefunden!');
  taste;
  cl;
end;

procedure besuchaendern;

procedure baendern;
var dat,
    dat2 :string;
begin
  write ('Welches Datum Ñndern: ');
  readln(dat);
  while not eof(f3) do begin
    readln(f3,dat2);
    if (pos(dat,dat2)>0) then begin
      writeln (dat2);
      write ('Neues Datum: '); readln(dat);
      writeln(f3,dat);
      exit;
    end;
  end;
  writeln ('Datum "',dat,'" nicht gefunden!');
  taste;
  close(f3);
end;

begin
  write ('Patient: ');
  readln(ss);
  o;
  while not eof(f) do begin
    if secure then code_lies else lies;
    if (pos(ss,d.name)>0) then begin
      zeigebesuch;
      baendern;
    end;
  end;
  writeln ('Patient ',ss,' nicht gefunden!');
  taste;
  cl;
end;

procedure bericht;
var nam :boolean;
    ber :string;

procedure search;
begin
  seek(f,0);
  while (not eof(f)) and (not nam) do begin
    if secure then code_lies else lies;
    if (pos(ss,d.name)>0) then nam:=true;
  end;
end;

begin
  nam:=false;
  write ('Patient: ');
  readln(ss);
  o;
  search;
  cl;
  assign(f2,d.name+'.ber');
  reset(f2);
  if ioresult<>0 then begin
    writeln ('Datei "',d.name,'.stm" konnte nicht geîffnet werden!!');
    write ('Datei neu erîffnen ? ');
    c:=readkey;
    c:=upcase(c); write (c); if c='J' then rewrite (f2) else exit;
  end;
  if nam then begin
    clrscr;
    writeln (d.name,', ',d.vorname,', ',d.strasse,', ',d.plzort);
    writeln (f2,d.name,', ',d.vorname,', ',d.strasse,', ',d.plzort);
    writeln ('Bericht verfassen:');
    window(1,3,80,25);
    repeat
      readln(ber);
      writeln(f2,ber);
    until ber='#e#';
    close(f2);
    window(1,1,80,25);
  end else begin
    writeln ('Patient ',ss,' nicht gefunden!');
    taste;
  end;
end;

procedure berichtansehen;
var nam :boolean;
    ber :string;

procedure zeigebericht;
begin
  assign(f2,d.name+'.stm');
  reset(f2);
  if ioresult<>0 then begin
    writeln ('Berichtsdatei " ',d.name+'.ber','" nicht gefunden!');
    taste;
    exit;
  end;
  clrscr;
  for i:=1 to 80 do write ('=');
  gotoxy(1,24);
  for i:=1 to 80 do write ('=');
  writeln ('Patient: ');
  writeln; writeln;
  writeln ('Bericht:');
  window(20,2,80,23);
  writeln(d.name,', ',d.vorname);
  writeln(d.plzort,', ',d.strasse,', ',d.tele);
  writeln;
  reset(f2);
  readln(f2,ber);
  while not eof(f2) do begin
    readln(f2,ber);
    if wherey>23 then begin
      window(1,1,80,25);
      taste;
      window(20,2,80,23);
    end;
    writeln (ber);
  end;
  window(1,1,80,25);
  taste;
end;

begin
  nam:=false;
  write ('Patient: ');
  readln(ss);
  o;
  repeat
    if secure then code_lies else lies;
    if (pos(ss,d.name)>0) then begin
      nam:=true;
      zeigebericht;
    end else begin
      writeln ('Patient ',ss,' nicht gefunden!');
      taste;
    end;
  until nam;
  cl;
end;

procedure drucken;
var dr :string;

function checkprn :boolean;
begin
  repeat
    writeln (lst);
    if ioresult<>0 then begin
      clrscr;
      writeln ('Der Drucker reagiert nicht! Bitte ÅberprÅfen!');
      write ('Funktion (a)bbrechen oder (w)iederholen ? ');
      clreol;
      checkprn:=false;
      c:=readkey; c:=upcase(c); write (c);
      if c='A' then begin
        window(1,1,80,25);
        exit;
      end;
    end else checkprn:=true;
  until (checkprn) or (c='A');
end;

begin
  write ('Was drucken (return=alles) ? ');
  readln (dr);
  if not checkprn then exit;
  o; clrscr; write('drucke...');
  if dr='' then begin
    while not eof(f) do begin
    if secure then code_lies else lies;
      writeln(lst,d.name);
      writeln(lst,d.vorname);
      writeln(lst,d.strasse);
      writeln(lst,d.plzort);
      writeln(lst,d.tele);
      writeln(lst,d.geb);
      writeln(lst,d.kk);
      writeln(lst,d.termin);
      writeln(lst,d.diagnose);
      writeln(lst,d.versorgung);
      writeln(lst,d.stomaanlage);
    end;
  end;
  cl;
end;

procedure beginn;
begin
  clrscr;
  oeffnen;
  if neu then eingabe;
  if not neu then allenamen;
end;

procedure init;
begin
  sc.datadir:='';
  assign (cfg,'stoma.cfg');
  reset(cfg);
  if ioresult<>0 then begin
    writeln ('Konfigurationsdatei konnte nicht gefunden werden!!');
    writeln ('Programmabbruch!');
    writeln; halt;
  end;
  seek(cfg,0);
  { while (not eof(cfg)) do } read(cfg,sc);
  sc.datadir:=decode(sc.datadir);
  if sc.security then secure:=true else secure:=false;
  chdir(sc.datadir);
  close(cfg);
end;

procedure param;
var p :string[1];
begin
  p:=copy(paramstr(1),1,1);
  case p[1] of
    '1' :eingabe;
    '2' :ausgabe;
    '3' :allenamen;
    '4' :suchen;
    '5' :aendern;
    '6' :loeschen;
    '7' :lrueck;
    '8' :besuch;
    '9' :besuchansehen;
    'a' :besuchaendern;
    'b' :bericht;
    'c' :berichtansehen;
    'd' :drucken;
    'o' :oeffnen;
    'n' :beginn;
  end;
end;

begin
  checkbreak:=false;
  getdir(0,olddir);
  init;
  param;
  chdir(olddir);
  cl;
end.
