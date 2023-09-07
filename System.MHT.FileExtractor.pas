unit System.MHT.FileExtractor;

interface

uses
  System.SysUtils;

type
  IMHTFileExtractor = interface(IInvokable)
    ['{BED708BD-93C3-4566-AF3A-50D1ED76AA14}']
    function FromFile(const Value: string): IMHTFileExtractor; overload;
    function FromFile(): string; overload;

    function ToPath(const Value: string): IMHTFileExtractor; overload;
    function ToPath(): string; overload;

    function Extract(): Boolean;
  end;

  TMHTFileExtractor = class(TInterfacedObject, IMHTFileExtractor)
  strict private
    FFromFile: string;
    FToPath: string;
    FExtractPath: string;
  private
    const CContentLocation = 'content-location:';   //  17 = Length('content-location:')
    const CContentLocationLength = 17;   //  17 = Length('content-location:')
  private
    procedure Extracting(BoundaryArray: TArray<string>);
    procedure ExtractMhtBoundary(const MhtContent: string);
    procedure ExtractImages(const Content: string);
    procedure ExtractText(const Content: string);

    procedure GetContentLocation(const BaseContent: string; ProcToSave: TProc<string, string>);
  public
    function FromFile(const Value: string): IMHTFileExtractor; overload;
    function FromFile(): string; overload;

    function ToPath(const Value: string): IMHTFileExtractor; overload;
    function ToPath(): string; overload;

    function Extract(): Boolean;
  end;

implementation

uses
  System.Classes,
  System.Zip,
  System.Types,
  System.IOUtils,
  System.NetEncoding;

{ TMHTFileExtractor }

function TMHTFileExtractor.FromFile: string;
begin
  Result := FFromFile;
end;

function TMHTFileExtractor.ToPath(const Value: string): IMHTFileExtractor;
begin
  FToPath := Value;
  Result := Self;
end;

function TMHTFileExtractor.FromFile(const Value: string): IMHTFileExtractor;
begin
  FFromFile := Value;
  Result := Self;
end;

function TMHTFileExtractor.ToPath: string;
begin
  Result := FToPath;
end;

function TMHTFileExtractor.Extract: Boolean;
begin
  if (not TFile.Exists(FFromFile)) then
    Exit(False);

  //  var ExtractPath := TPath.Combine(TPath.GetLibraryPath(), 'New');
  FExtractPath := TPath.Combine(FToPath, TPath.GetFileNameWithoutExtension(FFromFile));
  TDirectory.CreateDirectory(FExtractPath);

  var MhtFile: string;

  if (TPath.GetExtension(FFromFile).ToLower.EndsWith('zip') and TZipFile.IsValid(FFromFile)) then
  begin
    TZipFile.ExtractZipFile(FFromFile, FExtractPath);
    var MhtFiles := TDirectory.GetFiles(FExtractPath, '*.mht*');
    if (Length(MhtFiles) = 0) then
      Exit(False);

    MhtFile := MhtFiles[0]; //  Fix, get the first file...
  end
  else
  begin
    MhtFile := FFromFile;
  end;

  ExtractMhtBoundary(TFile.ReadAllText(MhtFile));
  Result := True;
end;

procedure TMHTFileExtractor.ExtractMhtBoundary(const MhtContent: string);
var
  Content: string;
  ContentArray: TArray<string>;
  Boundary: string;
begin
  ContentArray := MhtContent.Split([sLineBreak]);
  for Content in ContentArray do
  begin
    if Content.Contains('boundary="') then
    begin
      Boundary := Content;
      Break;
    end;
  end;

  var startfrom := Boundary.IndexOf('"');
  var endto := Boundary.LastIndexOf('"');
  Boundary := Boundary.Substring((startfrom + 1), (endto - startfrom - 1));

  ContentArray := MhtContent.Split([Boundary]);
  Extracting(ContentArray);
end;

procedure TMHTFileExtractor.Extracting(BoundaryArray: TArray<string>);
var
  Idx: Integer;
begin
  for Idx := Low(BoundaryArray) to High(BoundaryArray) do
  begin
    if BoundaryArray[Idx].ToLower.Contains('content-type') then
    begin
      if BoundaryArray[Idx].ToLower.Contains('image/') then
      begin
        ExtractImages(BoundaryArray[Idx]);
      end
      else
      if BoundaryArray[Idx].ToLower.Contains('text/') then
      begin
        ExtractText(BoundaryArray[Idx]);
      end;
    end;
  end;
end;

procedure TMHTFileExtractor.GetContentLocation(const BaseContent: string; ProcToSave: TProc<string, string>);
begin
  if BaseContent.ToLower.Contains(CContentLocation) then
  begin
    var startfrom := (BaseContent.ToLower.IndexOf(CContentLocation) + CContentLocationLength);
    var endto := BaseContent.ToLower.IndexOf(sLineBreak, (startfrom + 2));

    var FileNameToSave := BaseContent.Substring(startfrom, (endto - startfrom)).Trim;
    startfrom := (BaseContent.IndexOf(FileNameToSave) + Length(FileNameToSave));
    var ValueToSave := BaseContent.Substring(startfrom).Trim;

    FileNameToSave := TPath.Combine(FExtractPath, FileNameToSave);
    ProcToSave(FileNameToSave, ValueToSave);
  end;
end;

procedure TMHTFileExtractor.ExtractImages(const Content: string);
begin
  GetContentLocation(Content,
    procedure (ImageName: string; ImageBase64: string)
    begin
      //  Sample how to write Base64 to file:   https://flixengineering.com/archives/961
      TFile.WriteAllBytes(ImageName, TNetEncoding.Base64.DecodeStringToBytes(ImageBase64))
    end);
end;

procedure TMHTFileExtractor.ExtractText(const Content: string);
begin
  GetContentLocation(Content,
    procedure (Textname: string; ValueToSave: string)
    begin
      TFile.WriteAllText(Textname, ValueToSave);
    end);
end;

//procedure TMHTFileExtractor.ExtractImages2(BoundaryArray: TArray<string>);
//var
//  Content: string;
//  IsImage: Boolean;
//  ImageName: string;
//  ImageBase64: string;
//begin
//  IsImage := False;
//  for Content in BoundaryArray do
//  begin
//    if Content.ToLower.Contains('content-type') then
//    begin
//       IsImage := Content.ToLower.Contains('image/jpeg');
//    end;
//
//    if (not IsImage) then
//      Continue;
//
//    if Content.ToLower.Contains(CContentLocation) then
//    begin
//      var startfrom := (Content.ToLower.IndexOf(CContentLocation) + CContentLocationLength);
//      var endto := Content.ToLower.IndexOf(sLineBreak, (startfrom + 2));
//
//      ImageName := Content.Substring(startfrom, (endto - startfrom)).Trim;
//
//      startfrom := (Content.IndexOf(ImageName) + Length(ImageName));
//      ImageBase64 := Content.Substring(startfrom).Trim;
//      DecodeImagesAndSave(ImageName, ImageBase64);
//      IsImage := False;
//    end;
//  end;
//end;

end.
