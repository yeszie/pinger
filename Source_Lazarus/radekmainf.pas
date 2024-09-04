unit radekmainf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  LazHelpHTML, StdCtrls, ShellApi, pingunit, Windows;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    HTMLBrowserHelpViewer1: THTMLBrowserHelpViewer;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    MenuItem1: TMenuItem;
    MenuItem1_iPingPL: TMenuItem;
    MenuItem3_Exit: TMenuItem;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    //procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem1_iPingPLClick(Sender: TObject);
    procedure MenuItem3_ExitClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    adresyIP:array of TPinger;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.MenuItem3_ExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i : Integer;
  Cnt : Integer;
begin
  Cnt := 0;
  trayicon1.Hint := 'Pinger';
  for i := 0 to Length(AdresyIP) - 1 do
  begin
    if AdresyIP[i].Ping then
    begin
      Inc(Cnt);
    end
    else
    begin
      TrayIcon1.hint := TrayIcon1.hint + #13#10 + AdresyIP[i].Host;
    end;

  end;
  if Cnt = 0 then
  begin
    ImageList1.GetIcon(2, TrayIcon1.Icon);
  end
  else if Cnt = Length(AdresyIP) then
  begin
    ImageList1.GetIcon(0, TrayIcon1.Icon);
  end
  else
  begin
    ImageList1.GetIcon(1, TrayIcon1.Icon);
  end;

end;

procedure TForm1.MenuItem1_iPingPLClick(Sender: TObject);
const
  URL = 'https://iPing.pl';
begin
  ShellExecute(Form1.handle, 'open', Pchar(URL), nil, nil, SW_NORMAL);
end;


procedure CreateFile(Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    if not FileExists('pinger.txt') then
    begin
      SL.Add('# Hosts for pinger');
      SL.Add('google.com');
      SL.Add('iPing.pl');
      SL.Add('8.8.8.8');
      SL.SaveToFile('pinger.txt');  // Utwórz plik z jednym wpisem
      Application.Terminate;
    end;
  finally
    SL.Free;
  end;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  SL: TStringList;
  Len: Integer;
  i: Integer;
begin
  Timer1.Enabled := True;  // Włącz Timer na początku procedury
  adresyIP := nil;
  SL := TStringList.Create;
  try
    // Sprawdź, czy plik istnieje
    if not FileExists('pinger.txt') then
    begin
      CreateFile(Sender)
    end
    else
    begin
      SL.LoadFromFile('pinger.txt');  // Wczytaj plik, jeśli istnieje
      for i := 0 to SL.Count - 1 do
      begin
        // Sprawdź czy linia nie jest pusta, nie zaczyna się od '#' i nie zawiera tylko białych znaków lub znaków specjalnych
        if (Trim(SL.Strings[i]) <> '') and (SL.Strings[i][1] <> '#') then
        begin
          Len := Length(adresyIP);
          SetLength(adresyIP, Len + 1);
          adresyIP[Len] := TPinger.Create(SL.Strings[i]);  // Tworzenie obiektu TPinger z danym adresem IP
        end;
      end;
    end;
  finally
    SL.Free;  // Zwolnij obiekt TStringList
  end;
end;


procedure TForm1.MenuItem1Click(Sender: TObject);
begin
   Show;
end;

//procedure TForm1.Button1Click(Sender: TObject);
//begin
//  SetLength(AdresyIp, Length(AdresyIP) + 1);
//  AdresyIp[Length(AdresyIP) - 1] :=  Tpinger.Create(Edit1.text);
//end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   canclose := false;
   Hide;
end;

end.

