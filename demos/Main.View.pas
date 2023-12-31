unit Main.View;

interface

uses
  System.Classes,
  System.SysUtils,
  System.PSRWrapper,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.WinXCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  Vcl.Dialogs;

type
  TMainView = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    edtMaxSC: TMaskEdit;
    memoOutput: TMemo;
    ToggleSwitchDC: TToggleSwitch;
    ToggleSwitchSC: TToggleSwitch;
    ToggleSwitchIncludeETWAndXML: TToggleSwitch;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblWaiting: TLabel;
    ActivityIndicatorSaving: TActivityIndicator;
    btnExtractor: TButton;
    Bevel1: TBevel;
    edtExtractorOutputFrom: TLabeledEdit;
    edtExtractorOutputTo: TLabeledEdit;
    OpenDialog: TOpenDialog;
    BtnOpen: TButton;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure memoOutputClick(Sender: TObject);
    procedure btnExtractorClick(Sender: TObject);
    procedure BtnOpenClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FInnerPSRWrapper: IPSRWrapper;
  public
    { Public-Deklarationen }
  end;

var
  MainView: TMainView;

implementation

uses
  System.IOUtils,
  System.MHT.FileExtractor,
  System.MHT.RecordingXML,
  System.MHT.RecordingXMLToFile,
  Winapi.Windows,
  Winapi.Messages,
  WinApi.ShellAPI;

{$R *.dfm}

procedure TMainView.FormCreate(Sender: TObject);
begin
  FInnerPSRWrapper := TPSRWrapper.Create;
  edtExtractorOutputFrom.Text := 'C:\Temp\002\tmp795.zip';
  edtExtractorOutputTo.Text := 'C:\Temp\002';
end;

procedure TMainView.FormDestroy(Sender: TObject);
begin
  FInnerPSRWrapper := nil;
end;

procedure TMainView.memoOutputClick(Sender: TObject);
var
  CurrentLineNumber: Integer;
  OuputFileName: TFileName;
begin
  CurrentLineNumber := SendMessage(memoOutput.Handle, EM_LINEFROMCHAR, memoOutput.SelStart, 0);
  //  CurrentLineNumber := memoOutput.Perform(EM_LINEFROMCHAR, -1, 0);
  memoOutput.SelStart := memoOutput.Perform(EM_LINEINDEX, CurrentLineNumber, 0);
  memoOutput.SelLength := Length(memoOutput.Lines[CurrentLineNumber]);

  OuputFileName := memoOutput.Lines[CurrentLineNumber];
  if (not String(OuputFileName).IsEmpty)  then
  begin
    WinApi.ShellAPI.ShellExecute(
      Handle,
      'OPEN',
      PChar('explorer.exe'),
      PChar('/select, "' + OuputFileName + '"'),
      nil,
      SW_NORMAL);
  end;

  edtExtractorOutputFrom.Text := OuputFileName;
  edtExtractorOutputTo.Text := TPath.GetDirectoryName(OuputFileName);
end;

procedure TMainView.btnExtractorClick(Sender: TObject);
var
  RecordingXmlParser: IMHTRecordingXmlParser;
  ListOfActions: TArray<TEachAction>;
  RecordingXmlToFile: IMHTRecordingXmlToFile;
  ImgExtractor: IMHTFileExtractor;
  Return: string;
begin
  ImgExtractor := TMHTFileExtractor.Create;
  Return := ImgExtractor
    .FromFile(edtExtractorOutputFrom.Text)
    .ToPath(edtExtractorOutputTo.Text)
    .Extract;

  var XmlFile := TDirectory.GetFiles(Return, 'RecordingXML*.xml');
  if (Length(XmlFile) > 0) and (TFile.Exists(XmlFile[0])) then
  begin
    RecordingXmlParser := TMHTRecordingXmlParser.Create;
    ListOfActions := RecordingXmlParser.Xml(TFile.ReadAllText(XmlFile[0])).Execute;

    RecordingXmlToFile := TMHTRecordingXmlToFile.Create;
    RecordingXmlToFile
      .RecordEachAction(ListOfActions)
      .Filename(TPath.ChangeExtension(XmlFile[0], 'csv'))
      .SaveToCSV;
  end;
end;

procedure TMainView.BtnOpenClick(Sender: TObject);
begin
  if TFile.Exists(edtExtractorOutputTo.Text) then
  begin
    OpenDialog.InitialDir := TPath.GetDirectoryName(edtExtractorOutputTo.Text);
  end;

  if OpenDialog.Execute then
  begin
    edtExtractorOutputFrom.Text := OpenDialog.FileName;
    edtExtractorOutputTo.Text := TPath.GetDirectoryName(OpenDialog.FileName);
  end;
end;

procedure TMainView.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  ToggleSwitchDC.Enabled := False;
  ToggleSwitchSC.Enabled := False;
  ToggleSwitchIncludeETWAndXML.Enabled := False;
  edtMaxSC.Enabled := False;

  FInnerPSRWrapper
    .DisplayControlGUI(ToggleSwitchDC.State = tssOn)
    .CaptureScreenshotsForRecordedSteps(ToggleSwitchSC.State = tssOn)
    .MaximumNumberOfRecentScreenCaptures(999)
    .IncludeETWAndXML(ToggleSwitchIncludeETWAndXML.State = tssOn)
    .Start;

  btnStop.Enabled := True;
  btnStop.SetFocus;
end;

procedure TMainView.btnStopClick(Sender: TObject);
begin
  btnStop.Enabled := False;
  lblWaiting.Visible := True;
  ActivityIndicatorSaving.Animate := True;

  FInnerPSRWrapper.Stop;
  if (FInnerPSRWrapper.Output.IsEmpty) then
  begin
    memoOutput.Lines.Add('Is empty.');
  end
  else
  begin
    memoOutput.Lines.Add(FInnerPSRWrapper.Output);
  end;

  lblWaiting.Visible := False;
  ActivityIndicatorSaving.Animate := False;
  ToggleSwitchDC.Enabled := True;
  ToggleSwitchSC.Enabled := True;
  ToggleSwitchIncludeETWAndXML.Enabled := True;
  edtMaxSC.Enabled := True;
  btnStart.Enabled := True;
  btnStart.SetFocus;
end;

end.
