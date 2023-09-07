program PSRWrapperVCL;

uses
  Vcl.Forms,
  Main.View in 'Main.View.pas' {MainView},
  Vcl.Themes,
  Vcl.Styles,
  System.PSRWrapper in '..\System.PSRWrapper.pas',
  System.MHT.FileExtractor in '..\System.MHT.FileExtractor.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'PSRWrapper';
  TStyleManager.TrySetStyle('Windows10 Dark');
  //  TStyleManager.SetStyle('Tablet Dark');
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
