#include <time.h>
#include <process.h>
#include <def.c>
#include <cursor.c>
#include <popup.c>
#include <dos2.c>
#include <error.c>

float stoma_ver=0.7;
int d;
char *prg, *cfgprg;

void bild()
{
char datum[9], zeit[9], s[80];
  MFORE=WHITE; MBACK=BLUE;
  _clearscreen(0);
  for(i=0;i<80;i++) printf("-");
  colored(); _settextposition(2,1);
  for(i=0;i<14;i++)
  {
    sprintf(s,"%c",0xf9);
    _outtext(s);
  }
  sprintf(s,"STOMA%cVersion%c%1.1f%c-%cCopyright%c(C)%c1993,94%cRalf%cBensmann\
",0xf9,0xf9,stoma_ver,0xf9,0xf9,0xf9,0xf9,0xf9,0xf9);
  _outtext(s);
  for(i=0;i<11;i++) { sprintf(s,"%c",0xf9); _outtext(s); }
  uncolored();
  for(i=0;i<80;i++) printf("-");
  _strdate(datum); _strtime(zeit);
  _settextposition(6,1); printf("Datum: %s",datum);
  _settextposition(6,67); printf("Zeit: %s",zeit);
  _settextposition(7,1); printf("MS-DOS: %s",dosversion());
  MFORE=WHITE; MBACK=RED;
}

void build_popup_menu()
{
  mpkt[1]=" Neuen Patienten aufnehmen               ";
  mpkt[2]=" Alle Patientendaten vollstÑndig anzigen ";
  mpkt[3]=" Alle Namen anzeigen                     ";
  mpkt[4]=" Suchen von Daten                        ";
  mpkt[5]=" éndern von EintrÑgen                    ";
  mpkt[6]=" Patient aus Datei lîschen               ";
  mpkt[7]=" Gelîschten Patienten wieder zurÅckrufen ";
  mpkt[8]=" Besuchsdaten eingeben                   ";
  mpkt[9]=" Besuchsdaten ansehen                    ";
  mpkt[10]=" Besuchsdaten Ñndern                    ";
  mpkt[11]=" Bericht Åber Patient verfassen         ";
  mpkt[12]=" Bericht ansehen                        ";
  mpkt[13]=" Drucken                                ";
  mpkt[14]=" Konfiguration Ñndern                   ";
  mpkt[15]=" Ende                                   ";
  PAINT=1;
  _clearscreen(0);
}

void code()
{
char s[10];
  i=0;
  while (i<3) {
    printf("code:");
    gets(s);
    if (strcmp(s,"irsdb")!=0) {
      i++;
      if (i>2) exit(printf("\nfalscher code.\n"));
    } else { printf("code ok."); return; }
  }
}

void main()
{
  _clearscreen(0);
  code();
  prg="\\stoma\\sprg.exe"; cfgprg="\\stoma\\stcfg.exe";
  err=spawnl(P_WAIT, prg, prg, "n",NULL);
  if (err!=0)
  {
    error("Datenbank-Manager \"sprg.exe\" kann nicht ausgefÅhrt\
 werden!",1);
    exit(errno);
  }
  build_popup_menu();
  while(d<15)
  {
    bild();
    _settextwindow(10,20,25,80);
    d=pop_up(15,15);
    _settextwindow(1,1,25,80);
    _clearscreen(0);
    switch(d)
    {
      case  1 :err=spawnl(P_WAIT, prg, prg, "1", NULL); break;
      case  2 :err=spawnl(P_WAIT, prg, prg, "2", NULL); break;
      case  3 :err=spawnl(P_WAIT, prg, prg, "3", NULL); break;
      case  4 :err=spawnl(P_WAIT, prg, prg, "4", NULL); break;
      case  5 :err=spawnl(P_WAIT, prg, prg, "5", NULL); break;
      case  6 :err=spawnl(P_WAIT, prg, prg, "6", NULL); break;
      case  7 :err=spawnl(P_WAIT, prg, prg, "7", NULL); break;
      case  8 :err=spawnl(P_WAIT, prg, prg, "8", NULL); break;
      case  9 :err=spawnl(P_WAIT, prg, prg, "9", NULL); break;
      case 10 :err=spawnl(P_WAIT, prg, prg, "a", NULL); break;
      case 11 :err=spawnl(P_WAIT, prg, prg, "b", NULL); break;
      case 12 :err=spawnl(P_WAIT, prg, prg, "c", NULL); break;
      case 13 :err=spawnl(P_WAIT, prg, prg, "d", NULL); break;
      case 14 :{
		 /* code(); */
		 err=spawnl(P_WAIT, cfgprg, cfgprg, NULL);
	       } break;
    }
    if (err==-1)
    {
      _clearscreen(0);
      error("Datenbank-Manager \"sprg.exe\" kann nicht ausgefÅhrt\
   werden!!",1);
      err=0;
    }
  }
  _clearscreen(0);
}
