unit Test.MHT.RecordingXML;

interface

uses
  DUnitX.TestFramework,
  System.MHT.RecordingXML,
  System.MHT.RecordingXMLToFile;

type
  [TestFixture]
  TTestRecordingXML = class
  strict private
    FCsvPath: string;
    FSut: IMHTRecordingXmlParser;
    FCut: IMHTRecordingXmlToFile;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_CanCreateAndLoadXML;

    [Test]
    procedure Test_CanSaveRecordToCSV;
  end;

implementation

uses
  System.IOUtils;

{$I RecordingXml.inc}

procedure TTestRecordingXML.Setup;
begin
  FCsvPath := TPath.Combine(TPath.GetLibraryPath(), 'Test');

  FSut := TMHTRecordingXmlParser.Create;
  FCut := TMHTRecordingXmlToFile.Create;
end;


procedure TTestRecordingXML.TearDown;
begin
  if TDirectory.Exists(FCsvPath) then
    TDirectory.Delete(FCsvPath, True);
end;

procedure TTestRecordingXML.Test_CanCreateAndLoadXML;
var
  Actual: TArray<TEachAction>;
begin
  Actual := FSut.Xml(Test_Mock_RecordingXml).Execute;
  Assert.AreEqual(2, Length(Actual));

  Assert.AreEqual(Actual[0].ActionNumber, 1);
  Assert.AreEqual(Actual[1].ActionNumber, 2);

  Assert.AreEqual(Actual[0].Time, '16:00:20');
  Assert.AreEqual(Actual[1].Time, '16:00:21');

  Assert.AreEqual(Actual[0].FileVersion, '5.4.2.294');
  Assert.AreEqual(Actual[0].FileName, 'R5IMMOB.EXE');
  Assert.AreEqual(Actual[0].CommandLine, 'R5IMMOB.EXE  ALIAS=IMMOB /SYNCSECAREAS');

  Assert.AreEqual(Actual[0].Action, 'Tastatureingabe');
  Assert.AreEqual(Actual[1].Action, 'Tastatureingabe');

  Assert.AreEqual(Actual[0].ScreenshotFileName, 'screenshot0001.JPEG');
  Assert.AreEqual(Actual[1].ScreenshotFileName, 'screenshot0002.JPEG');
end;

procedure TTestRecordingXML.Test_CanSaveRecordToCSV;
var
  InnerFilename: string;
  EachActions: TArray<TEachAction>;
  Actual: string;
begin
  //  Arrange...
  InnerFilename := TPath.Combine(FCsvPath, 'my.csv');
  EachActions := FSut.Xml(Test_Mock_RecordingXml).Execute;

  //  Act...
  FCut
    .RecordEachAction(EachActions)
    .Filename(InnerFilename)
    .SaveToCSV;

  //  Assert...
  Actual := TFile.ReadAllText(InnerFilename);
  Assert.IsNotEmpty(Actual);
end;


initialization
  TDUnitX.RegisterTestFixture(TTestRecordingXML);

end.
