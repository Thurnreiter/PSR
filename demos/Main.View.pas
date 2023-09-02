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
  Vcl.Mask;

type
  TMainView = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    Label1: TLabel;
    memoOutput: TMemo;
    ToggleSwitchDC: TToggleSwitch;
    ToggleSwitchSC: TToggleSwitch;
    ToggleSwitchIncludeETWAndXML: TToggleSwitch;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    edtMaxSC: TMaskEdit;
    Label6: TLabel;
    lblWaiting: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
    FInnerPSRWrapper: IPSRWrapper;
  public
    { Public-Deklarationen }
  end;

var
  MainView: TMainView;

implementation

{$R *.dfm}

procedure TMainView.FormCreate(Sender: TObject);
begin
  FInnerPSRWrapper := TPSRWrapper.Create;
end;

procedure TMainView.FormDestroy(Sender: TObject);
begin
  FInnerPSRWrapper := nil;
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
  ToggleSwitchDC.Enabled := True;
  ToggleSwitchSC.Enabled := True;
  ToggleSwitchIncludeETWAndXML.Enabled := True;
  edtMaxSC.Enabled := True;
  btnStart.Enabled := True;
  btnStart.SetFocus;
end;

end.
