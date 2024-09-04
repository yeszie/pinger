unit PingUnit;

{$mode Delphi}

interface

uses
{$IFDEF UNIX}
  cthreads,
  cmem,
{$ENDIF}Classes, SysUtils, process, dialogs;

Type

  TPinger = class(TThread)
  private
    FHost : String;
    FInterval : Integer;
    FPing : Boolean;
  protected
    { protected declarations }
  public
    constructor Create(aHost : String; aInterval : Integer = 5000);
    destructor Destroy; override;
    procedure Execute; override;
    property Ping : Boolean read FPing;
  end;

  TNetworkConnectionChecker = class(TThread)
  private
    FHosts : Array of string;
    FInterval : Integer;
    FPing : Boolean;
  protected
    { protected decarations }
  public
    constructor Create(aHosts: array of String; aInterval: Integer=10000);
    destructor Destroy; override;
    procedure Execute; override;
    property IsConnected : Boolean read FPing;
  end;

implementation

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//////////TPinger/////////////////////////////////

{ private declarations }

{ protected declarations }

{ public declarations }

constructor TPinger.Create(aHost : String; aInterval : Integer = 5000);
begin
  inherited Create(True);
  FPing := False;
  FHost := aHost;
  FInterval := aInterval;
  FreeOnTerminate := False;
  Start;
end;

destructor TPinger.Destroy;
begin
  FHost := '';
  FPing := False;
  FInterval := 0;
  Inherited Destroy;
end;

procedure TPinger.Execute;
var
  PingResult : Boolean;
  Response : String;
  SubStr : String;
  Index : Integer;
  Prc : TProcess;
  SL : TStringList;
  TC : QWORD;
begin
  TC := 0;
  while (not Terminated) do
  begin
    if ((GetTickCount64 - TC) < FInterval) then
    begin
      sleep(10);
    end
    else
    begin
      PingResult := False;
      Response := '';
      SubStr := '';
      {$IFDEF UNIX}
        Prc := TProcess.Create(nil);
        Prc.Executable := 'ping';
        Prc.Parameters.Add('-c 1');
        Prc.Parameters.Add('-i 1');
        Prc.Parameters.Add('-w 1');
        Prc.Parameters.Add(FHost);
        Prc.Options := Prc.Options + [poWaitOnExit, poUsePipes];
        Prc.Execute;
        SL := TStringList.Create;
        SL.LoadFromStream(Prc.Output);
        Response := SL.Text;
        SL.Free;
        SL := nil;
        Prc.Terminate(0);
        Prc.Free;
        Prc := nil;
        PingResult := (Pos('unreachable', Response) = 0) and (Pos('Timed out', Response) = 0);
      {$ENDIF}
      {$IFDEF WINDOWS}
        Prc := TProcess.Create(nil);
        Prc.Executable := 'ping.exe';
        Prc.Parameters.AddCommaText('-n 1 -w 1000 ' + FHost);
        Prc.Options := Prc.Options + [poWaitOnExit, poUsePipes];
        Prc.ShowWindow := swoHIDE;
        Prc.Execute;
        SL := TStringList.Create;
        SL.LoadFromStream(Prc.Output);
        Response := SL.Text;
        SL.Free;
        SL := nil;
        Prc.Terminate(0);
        Prc.Free;
        Prc := nil;
        PingResult := (Pos('unreachable', Response) = 0) and (Pos('Timed out', Response) = 0);
      {$ENDIF}

      if PingResult then
      begin
        {$IFDEF UNIX}
          Index := Pos(' received', Response) - 1;
          SubStr := '';
          while (Response[Index] <> ' ') and (Index > 0) do
          begin
            SubStr := Response[Index] + SubStr;
            Dec(Index);
          end;
        {$ENDIF}
        {$IFDEF WINDOWS}
          Index := Pos('Received = ', Response) + 11;
          SubStr := '';
          while Response[Index] <> ',' do
          begin
            SubStr := SubStr + Response[Index];
            Inc(Index);
          end;
        {$ENDIF}
        PingResult := StrToIntDef(SubStr, -1) > 0;
      end;
      FPing := PingResult;
      TC := GetTickCount64;
    end;
  end;
end;

//////////TPinger/////////////////////////////////
//////////////////////////////////////////////////
//////////TNetworkConnectionChecker///////////////

{ private declarations }

{ protected declarations }

{ public declarations }

constructor TNetworkConnectionChecker.Create(aHosts: array of String; aInterval: Integer=10000);
var
  i : Integer;
begin
  inherited Create(True);
  FPing := True;
  if Length(aHosts) > 0 then
  begin
    SetLength(FHosts, Length(aHosts));
    for i := 0 to Length(aHosts) - 1 do
    begin
      FHosts[i] := aHosts[i];
    end;
  end;
  FInterval := aInterval;
  FreeOnTerminate := False;
  Start;
end;

destructor TNetworkConnectionChecker.Destroy;
var
  i : Integer;
begin
  if Length(FHosts) > 0 then
  begin
    for i := 0 to Length(FHosts) - 1 do
    begin
      FHosts[i] := '';
    end;
    SetLength(FHosts, 0);
  end;
  FPing := False;
  FInterval := 0;
  Inherited Destroy;
end;

procedure TNetworkConnectionChecker.Execute;
var
  PingResult : Boolean;
  FailCount : Integer;
  Response : String;
  SubStr : String;
  Index : Integer;
  Prc : TProcess;
  SL : TStringList;
  TC : QWORD;
begin
  TC := 0;
  FailCount := 0;
  while (not Terminated) do
  begin
    if ((GetTickCount64 - TC) < FInterval) then
    begin
      sleep(10);
    end
    else
    begin
      if Length(FHosts) > 0 then
      begin
        PingResult := False;
        Response := '';
        SubStr := '';
        {$IFDEF UNIX}
          Prc := TProcess.Create(nil);
          Prc.Executable := 'ping';
          Prc.Parameters.Add('-c 1');
          Prc.Parameters.Add('-i 1');
          Prc.Parameters.Add('-w 5');
          Prc.Parameters.Add(FHosts[FailCount]);
          Prc.Options := Prc.Options + [poWaitOnExit, poUsePipes];
          Prc.Execute;
          SL := TStringList.Create;
          SL.LoadFromStream(Prc.Output);
          Response := SL.Text;
          SL.Free;
          SL := nil;
          Prc.Terminate(0);
          Prc.Free;
          Prc := nil;
          PingResult := (Pos('unreachable', Response) = 0) and (Pos('Timed out', Response) = 0);
        {$ENDIF}
        {$IFDEF WINDOWS}
          Prc := TProcess.Create(nil);
          Prc.Executable := 'ping.exe';
          Prc.Parameters.AddCommaText('-n 1 -w 5000 ' + FHosts[FailCount]);
          Prc.Options := Prc.Options + [poWaitOnExit, poUsePipes];
          Prc.ShowWindow := swoHIDE;
          Prc.Execute;
          SL := TStringList.Create;
          SL.LoadFromStream(Prc.Output);
          Response := SL.Text;
          SL.Free;
          SL := nil;
          Prc.Terminate(0);
          Prc.Free;
          Prc := nil;
          PingResult := (Pos('unreachable', Response) = 0) and (Pos('Timed out', Response) = 0);
        {$ENDIF}

        if PingResult then
        begin
          {$IFDEF UNIX}
            Index := Pos(' received', Response) - 1;
            SubStr := '';
            while (Response[Index] <> ' ') and (Index > 0) do
            begin
              SubStr := Response[Index] + SubStr;
              Dec(Index);
            end;
          {$ENDIF}
          {$IFDEF WINDOWS}
            Index := Pos('Received = ', Response) + 11;
            SubStr := '';
            while Response[Index] <> ',' do
            begin
              SubStr := SubStr + Response[Index];
              Inc(Index);
            end;
          {$ENDIF}
          PingResult := StrToIntDef(SubStr, -1) > 0;
        end;
        if not PingResult then
        begin
          Inc(FailCount);
          if FailCount >= Length(FHosts) then
          begin
            FailCount := 0;
            FPing := False;
          end;
        end
        else
        begin
          FPing := True;
          FailCount := 0;
        end;
      end;
      TC := GetTickCount64;
    end;
  end;
end;

//////////TNetworkConnectionChecker///////////////
//////////////////////////////////////////////////
//////////////////////////////////////////////////



end.

