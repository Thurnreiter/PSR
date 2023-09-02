unit System.PSRWrapper;

interface
{
psr.exe [/start |/stop][/output ] [/sc (0|1)] [/maxsc ] [/sketch (0|1)] [/slides (0|1)] [/gui (o|1)] [/arcetl (0|1)] [/arcxml (0|1)] [/arcmht (0|1)] [/stopevent ] [/maxlogsize ] [/recordpid ]

Command Line Parameters für PSR:
  /start      : Start Recording. (Outputpath flag SHOULD be specified) /stop : Stop Recording.
  /sc         : Capture screenshots for recorded steps.
  /maxsc      : Maximum number of recent screen captures.
  /maxlogsize : Maximum log file size (in MB) before wrapping occurs.
  /gui        : Display control GUI.
  /arcetl     : Include raw ETW file in archive output.
  /arcxml     : Include MHT file in archive output.
  /recordpid  : Record all actions associated with given PID.
  /sketch     : Sketch UI if no screenshot was saved.
  /slides     : Create slide show HTML pages.
  /output     : Store output of record session in given path.
  /stopevent  : Event to signal after output files are generated.

PSR.EXE /START /OUTPUT "C:\Users\nt\AppData\Local\Temp\_nt.zip" /SC 1 /MAXSC 999 /GUI 1 /arcetl 1 /arcxml 1
PSR.EXE /START /OUTPUT "C:\Temp\002\_nt.zip" /SC 1 /MAXSC 999 /GUI 1 /arcetl 1 /arcxml 1 /slides 1 /sketch 1
PSR.EXE /START /OUTPUT "C:\Temp\002\_nt.zip" /SC 1 /MAXSC 999 /GUI 0
PSR.EXE /STOP

http://shortfastcode.blogspot.com/2013/04/problem-steps-recorder-command-line.html
https://stackoverflow.com/questions/8512730/how-to-integrate-problem-steps-recorder-psr-in-my-application

}

type
  IPSRWrapper = interface(IInvokable)
    ['{606699DF-A2E2-4594-8E43-F9ED3E81F0FF}']
    function CaptureScreenshotsForRecordedSteps(Value: Boolean): IPSRWrapper; overload;
    function CaptureScreenshotsForRecordedSteps(): Boolean; overload;

    function MaximumNumberOfRecentScreenCaptures(Value: Integer): IPSRWrapper; overload;
    function MaximumNumberOfRecentScreenCaptures(): Integer; overload;

    function DisplayControlGUI(Value: Boolean): IPSRWrapper; overload;
    function DisplayControlGUI(): Boolean; overload;

    function IncludeETWAndXML(Value: Boolean): IPSRWrapper; overload;
    function IncludeETWAndXML(): Boolean; overload;

    function Output(): string;

    function Start(): IPSRWrapper;
    function Stop(): IPSRWrapper;

    function IsRecording: Boolean;
  end;

  TPSRWrapper = class(TInterfacedObject, IPSRWrapper)
  strict private
    //    FProcessHandle: THandle;
    FIsRecording: Boolean;
    FCaptureScreenshotsForRecordedSteps: Boolean;
    FMaximumNumberOfRecentScreenCaptures: Integer;
    FDisplayControlGUI: Boolean;
    FIncludeETWAndXML: Boolean;
    FOutput: String;
  private
    function ProcessExists(): Boolean;
    procedure ExecuteProgAndWait(const AParams: string);
    procedure SleepWithoutFreezeApp(msec: Int64);
  public
    constructor Create();
    destructor Destroy; override;

    function CaptureScreenshotsForRecordedSteps(Value: Boolean): IPSRWrapper; overload;
    function CaptureScreenshotsForRecordedSteps(): Boolean; overload;

    function MaximumNumberOfRecentScreenCaptures(Value: Integer): IPSRWrapper; overload;
    function MaximumNumberOfRecentScreenCaptures(): Integer; overload;

    function DisplayControlGUI(Value: Boolean): IPSRWrapper; overload;
    function DisplayControlGUI(): Boolean; overload;

    function IncludeETWAndXML(Value: Boolean): IPSRWrapper; overload;
    function IncludeETWAndXML(): Boolean; overload;

    function Output(): string;

    function Start(): IPSRWrapper;
    function Stop(): IPSRWrapper;

    function IsRecording: Boolean;
  end;


implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.IOUtils
{$IFDEF MSWINDOWS}
  ,
  VCL.Forms,
  Winapi.Windows,
  WinApi.ShellAPI,
  Winapi.TlHelp32
{$ENDIF}
  ;

{ TPSRWrapper }

constructor TPSRWrapper.Create;
begin
  inherited Create();

  FCaptureScreenshotsForRecordedSteps := True;
  FMaximumNumberOfRecentScreenCaptures := 999;
  FDisplayControlGUI := False;
  FOutput := String.Empty;
  FIsRecording := False;
//  FProcessHandle := 0;
end;

destructor TPSRWrapper.Destroy;
begin
  //...
  inherited;
end;

function TPSRWrapper.CaptureScreenshotsForRecordedSteps(Value: Boolean): IPSRWrapper;
begin
  FCaptureScreenshotsForRecordedSteps := Value;
  Result := Self;
end;

function TPSRWrapper.CaptureScreenshotsForRecordedSteps: Boolean;
begin
  Result := FCaptureScreenshotsForRecordedSteps;
end;

function TPSRWrapper.DisplayControlGUI: Boolean;
begin
  Result := FDisplayControlGUI;
end;

function TPSRWrapper.DisplayControlGUI(Value: Boolean): IPSRWrapper;
begin
  FDisplayControlGUI := Value;
  Result := Self;
end;

function TPSRWrapper.MaximumNumberOfRecentScreenCaptures: Integer;
begin
  Result := FMaximumNumberOfRecentScreenCaptures;
end;

function TPSRWrapper.MaximumNumberOfRecentScreenCaptures(Value: Integer): IPSRWrapper;
begin
  FMaximumNumberOfRecentScreenCaptures := Value;
  Result := Self;
end;

function TPSRWrapper.Output: string;
begin
  Result := FOutput;
end;

//function TPSRWrapper.Output(const Value: String): IPSRWrapper;
//begin
//  FOutput := Value;
//  Result := Self;
//end;

function TPSRWrapper.ProcessExists(): Boolean;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := False;

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = 'PSR.EXE')
    or (UpperCase(FProcessEntry32.szExeFile) = 'PSR.EXE')) then
    begin
      Exit(True);
    end;

    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

//function TPSRWrapper.ExecuteProgAndWait(const AParam: string): Boolean;
//var
//  SEInfo: TShellExecuteInfo;
//  ExitCode: DWORD;
//  Return: Boolean;
//begin
//Writeln('1');
//  FillChar(SEInfo, SizeOf(SEInfo), #0);
//  SEInfo.LpVerb := 'open';
//  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
//  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;  // Tell ShellExecuteEx to keep the process handle open
//  //  SEInfo.hProcess
//  //  SEInfo.Wnd := Application.Handle;
//  //  SEInfo.Wnd := Handle;
//  SEInfo.LpFile := PChar('PSR.EXE');
//  SEInfo.lpParameters := PChar(AParam);
//  //  SEInfo.nShow := SW_SHOWNORMAL;
//  //  SEInfo.LpDirectory := PChar(TPath.GetDirectoryName('PSR.EXE'));
//Writeln('2');
//  Return := WinApi.ShellAPI.ShellExecuteEx(@SEInfo);
//Writeln('3');
//
//
//  if (Return) and (SEInfo.HProcess <> 0) then
//  begin
//Writeln('4');
//    WaitForSingleObject(SEInfo.HProcess, INFINITE);
//Writeln('5');
//    GetExitCodeProcess(SEInfo.HProcess, ExitCode);
//Writeln('6');
//    CloseHandle(SEInfo.HProcess);
//Writeln('7');
//  end;
//
//Writeln('8');
//
////  if (Return and (SEInfo.HProcess <> 0)) then
////  begin
////    repeat
////      GetExitCodeProcess(SEInfo.hProcess, ExitCode);
////    until (ExitCode <> STILL_ACTIVE); // or Application.Terminated;
////
////    //    FProcessHandle := SEInfo.HProcess;
////    CloseHandle(SEInfo.HProcess);
////    Exit(true);
////  end
////  else
////  begin
////    Exit(False);
////  end;
//end;



procedure TPSRWrapper.ExecuteProgAndWait(const AParams: string);
var
  {$IFDEF MSWINDOWS} Handle: HWND; {$ENDIF}
  Return: Cardinal;
begin
{$IFDEF MSWINDOWS}
  Handle := Application.Handle;
  if Assigned(Application.MainForm) then
    Handle := Application.MainForm.Handle;

  Return := WinApi.ShellAPI.ShellExecute(Handle, 'open', 'PSR.EXE', PChar(AParams), nil, SW_SHOWNORMAL);
  if (Return <= 32) then
  begin
    RaiseLastOSError();
  end;
{$ELSE}
  raise ENotImplemented.Create('Wrapper IProcess ShellExecute not implemented.');
{$ENDIF}
end;

function TPSRWrapper.IncludeETWAndXML: Boolean;
begin
  Result := FIncludeETWAndXML;
end;

function TPSRWrapper.IncludeETWAndXML(Value: Boolean): IPSRWrapper;
begin
  FIncludeETWAndXML := Value;
  Result := Self;
end;

function TPSRWrapper.IsRecording: Boolean;
begin
  Result := (FIsRecording or ProcessExists());
end;

procedure TPSRWrapper.SleepWithoutFreezeApp(msec: Int64);
var
  StartingValue, Elapsed: DWORD;
begin
  StartingValue := GetTickCount;
  Elapsed := 0;
  repeat
    if (MsgWaitForMultipleObjects(0, Pointer(nil)^, FALSE, msec-Elapsed, QS_ALLINPUT) <> WAIT_OBJECT_0) then
      Break;

    Application.ProcessMessages;
    Elapsed := (GetTickCount - StartingValue);
  until (Elapsed >= msec);
end;

function TPSRWrapper.Start: IPSRWrapper;
begin
  if (ProcessExists()) then
    Exit;

  var ParamPSR: String := '';

  FOutput := TPath.ChangeExtension(TPath.GetTempFileName, '.zip');

  ParamPSR := '/START '
    + ' /SC ' + FCaptureScreenshotsForRecordedSteps.ToInteger.ToString
    + ' /GUI ' + FDisplayControlGUI.ToInteger.ToString
    + ' /MAXSC ' + FMaximumNumberOfRecentScreenCaptures.ToString
    + ' /OUTPUT "' + FOutput + '"';

  if FIncludeETWAndXML then
  begin
    ParamPSR := ParamPSR + ' /ARCETL 1 /ARCXML 1 ';
  end;

  ExecuteProgAndWait(ParamPSR);
  FIsRecording := True;
end;

function TPSRWrapper.Stop: IPSRWrapper;
begin
  ExecuteProgAndWait('/stop');

  while ProcessExists() do
  begin
    SleepWithoutFreezeApp(1000);
  end;

  FIsRecording := False;
end;

end.

