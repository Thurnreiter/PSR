program PSRExtractorCon;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  WinApi.ShellAPI,
  Winapi.Windows,
  System.MHT.FileExtractor in '..\System.MHT.FileExtractor.pas';

const
  ErrorNoFrom = 'No valid parameter found, is mandatory and have exits. ';
  HelpMsg = 'Extracts a "Recording*.mht" or ZIP from there into the output directory as individual files.' + sLineBreak + sLineBreak
    + 'PSRExtractorCon [/FROM:]["File"] [/TO:]["Path"]' + sLineBreak
    + '  /HELP                  Show this help.' + sLineBreak
    + '  /FROM:".\tmp123.zip"   Name of the MHT or ZIP. The parameter is mandatory.' + sLineBreak
    + '  /TO:".\Any\"           Output directory. If the directory does not exist, the input file directory is used.' + sLineBreak
    + sLineBreak
    + 'Done. press <Enter> key to quit.';

begin
  try
    if (FindCmdLineSwitch('?') or FindCmdLineSwitch('HELP')) then
    begin
      System.Writeln(HelpMsg);
      System.Readln;
      Exit;
    end;

    var AppParamValueFrom: string := string.Empty;
    if ((not FindCmdLineSwitch('from:', AppParamValueFrom)) or (not TFile.Exists(AppParamValueFrom))) then
    begin
      System.Writeln(ErrorNoFrom + AppParamValueFrom);
      System.Readln;
      Exit;
    end;

    var AppParamValueTo: string := string.Empty;
    if (not FindCmdLineSwitch('to:', AppParamValueTo)) then
    begin
      AppParamValueTo := TPath.GetDirectoryName(AppParamValueFrom);
    end;

    Writeln('Starting extraction...');

    var Return: string := TMHTFileExtractorFactory.GetInstance
      .FromFile(AppParamValueFrom)
      .ToPath(AppParamValueTo)
      .Extract;

    if TDirectory.Exists(Return) then
    begin
      Writeln('Open folder: ' + Return + ' [Y/N]');
      var StopRecording: string;
      Readln(StopRecording);
      if StopRecording.ToLower.Equals('y') then
      begin
        WinApi.ShellAPI.ShellExecute(
          0,
          'OPEN',
          PChar('explorer.exe'),
          PChar('/select, "' + Return + '"'),
          nil,
          SW_NORMAL);
      end;
    end;

    Writeln('Finish. Press an key.');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      Writeln('Close console. Press an key.');
      System.Readln;
    end;
  end;
end.
