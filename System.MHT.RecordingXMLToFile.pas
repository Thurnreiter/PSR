unit System.MHT.RecordingXMLToFile;

interface

uses
  System.MHT.RecordingXML;

type
  IMHTRecordingXmlToFile = interface(IInvokable)
    ['{FE5B3532-CF06-43E1-9834-AA92D1D64987}']
    function RecordEachAction(): TArray<TEachAction>; overload;
    function RecordEachAction(Value: TArray<TEachAction>): IMHTRecordingXmlToFile; overload;

    function Filename(): string; overload;
    function Filename(const Value: string): IMHTRecordingXmlToFile; overload;

    procedure SaveToCSV();
  end;

  TMHTRecordingXmlToFile = class(TInterfacedObject, IMHTRecordingXmlToFile)
  strict private
    FEachAction: TArray<TEachAction>;
    FFilename: string;
  public
    function RecordEachAction(): TArray<TEachAction>; overload;
    function RecordEachAction(Value: TArray<TEachAction>): IMHTRecordingXmlToFile; overload;

    function Filename(): string; overload;
    function Filename(const Value: string): IMHTRecordingXmlToFile; overload;

    procedure SaveToCSV();
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

{ TMHTRecordingXmlToFile }

function TMHTRecordingXmlToFile.RecordEachAction: TArray<TEachAction>;
begin
  Result := FEachAction;
end;

function TMHTRecordingXmlToFile.Filename(const Value: string): IMHTRecordingXmlToFile;
begin
  FFilename := Value;
  Result := Self;
end;

function TMHTRecordingXmlToFile.Filename: string;
begin
  Result := FFilename;
end;

function TMHTRecordingXmlToFile.RecordEachAction(Value: TArray<TEachAction>): IMHTRecordingXmlToFile;
begin
  FEachAction := Value;
  Result := Self;
end;

procedure TMHTRecordingXmlToFile.SaveToCSV;
var
  CsvContent: string;
  InnerPath: string;
begin
  CsvContent := 'ActionNumber;Time;FileVersion;FileName;CommandLine;Action;ScreenshotFileName;Description' + sLineBreak;
  for var Item: TEachAction in FEachAction do
  begin
    CsvContent := CsvContent
      + Format('%d;%s;%s;%s;%s;%s;%s;%s',
        [Item.ActionNumber,
         Item.Time,
         Item.FileVersion,
         Item.FileName,
         Item.CommandLine,
         Item.Action,
         Item.ScreenshotFileName,
         Item.Description])
      + sLineBreak;
  end;

  InnerPath := TPath.GetDirectoryName(FFilename);
  if (not TDirectory.Exists(InnerPath)) then
    TDirectory.CreateDirectory(InnerPath);

  TFile.WriteAllText(FFilename, CsvContent);
end;

end.
