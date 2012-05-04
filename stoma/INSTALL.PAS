program install_stoma;
{$M 10000,0,0}

uses crt, dos;

var quelle, ziel :string;

procedure error;
begin
  if doserror=8 then begin
    writeln ('Nicht genug Speicher fÅr die Installation!');
    halt;
  end;
  if doserror=2 then begin
    writeln ('Dateien von STOMA nicht gefunden!');
    halt;
  end;
end;
 
procedure install;
begin
  writeln ('Installation fÅr STOMA');
  writeln; writeln;
  quelle:=paramstr(1);
  ziel:=paramstr(2);
  write ('Installiere...');
  mkdir(ziel+'\stoma');
  chdir(ziel+'\stoma');
  writeln;
  exec('c:\command.com','/c copy '+quelle+'\stoma.exe '+ziel+'\stoma >nul');
  error;
  exec('c:\command.com','/c copy '+quelle+'\data.stm '+ziel+'\stoma >nul');
  error;
  writeln;
  writeln ('Installation von STOMA auf Laufwerk ',ziel,'\STOMA beendet!');
  writeln ('Aufruf: CD \STOMA ... STOMA');
  writeln;
  writeln ('Copyright (C) 1993,94 Ralf Bensmann');
end;

begin
  clrscr;
  if paramcount=2 then install else begin
    writeln ('Parameter ungÅltig!');
    halt;
  end;
end.
