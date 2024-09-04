program radek;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, radekmainf, form2
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='pinger';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);

  Application.CreateForm(TForm2, Form2);
  application.showmainform := false;
  Application.Run;
end.

