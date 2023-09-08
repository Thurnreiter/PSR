program PSRWrapperConsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.PSRWrapper in '..\System.PSRWrapper.pas',
  System.MHT.RecordingXML in '..\System.MHT.RecordingXML.pas',
  System.MHT.RecordingXMLToFile in '..\System.MHT.RecordingXMLToFile.pas';

var
  StopRecording: string;
  InnerPSRWrapper: IPSRWrapper;

begin
  try
    { TODO -oUser -cConsole Main : Code hier einfügen }
    InnerPSRWrapper := TPSRWrapper.Create;

    Writeln('Start recording...');
    InnerPSRWrapper
      .DisplayControlGUI(False)
      .CaptureScreenshotsForRecordedSteps(True)
      .MaximumNumberOfRecentScreenCaptures(999)
      .Start;

    Writeln('Output: ' + InnerPSRWrapper.Output);
    Writeln('IsRecording: ' + InnerPSRWrapper.IsRecording.ToString());
//    Sleep(10000);

    Writeln('To stop recording, press an key.');
//    Result := StartUpdate.ToLower.StartsWith('y');
    Readln(StopRecording);

    InnerPSRWrapper
      .Stop;

    Writeln('Output: ' + InnerPSRWrapper.Output);
    System.Readln;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Writeln('Close console. Press an key.');
      System.Readln;
    end;
  end;
end.

