unit Test.MHT.Extractor;

interface

uses
  DUnitX.TestFramework,
  System.MHT.FileExtractor;

type
  [TestFixture]
  TMyTestObject = class
  strict private
    FMHTFile: string;
    FMHTZipFile: string;
    FSut: IMHTFileExtractor;
  private
    const CTestMHT = '..\..\Recording_20230902_1219.mht';
    const CTestMHTZip = '..\..\tmp6EF2.zip';
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_Extract_IsTrue_DirectFromMHT;

    [Test]
    procedure Test_Extract_IsTrue_DirectFromZip;
  end;

implementation

uses
  System.IOUtils;

procedure TMyTestObject.Setup;
begin
  //  FContentOfMHT := TFile.ReadAllText(CTestMHT);
  FMHTFile := TPath.Combine(TPath.GetLibraryPath(), CTestMHT);
  FMHTZipFile := TPath.Combine(TPath.GetLibraryPath(), CTestMHTZip);

  FSut := TMHTFileExtractor.Create;
end;

procedure TMyTestObject.TearDown;
var
  InnerPath: string;
begin
  InnerPath := TPath.Combine(TPath.GetLibraryPath(), TPath.GetFileNameWithoutExtension(CTestMHT));
  if TDirectory.Exists(InnerPath) then
    TDirectory.Delete(InnerPath, True);

  InnerPath := TPath.Combine(TPath.GetLibraryPath(), TPath.GetFileNameWithoutExtension(CTestMHTZip));
  if TDirectory.Exists(InnerPath) then
    TDirectory.Delete(InnerPath, True);

  FSut := nil;
end;

procedure TMyTestObject.Test_Extract_IsTrue_DirectFromMHT;
begin
  FSut
    .FromFile(FMHTFile)
    .ToPath(TPath.GetLibraryPath());

  Assert.IsTrue(FSut.Extract);
end;


procedure TMyTestObject.Test_Extract_IsTrue_DirectFromZip;
begin
  FSut
    .FromFile(FMHTZipFile)
    .ToPath(TPath.GetLibraryPath());

  Assert.IsTrue(FSut.Extract);
end;

initialization
  TDUnitX.RegisterTestFixture(TMyTestObject);

end.
