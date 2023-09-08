unit System.MHT.RecordingXML;

interface

uses
  System.SysUtils,
  System.RegularExpressions,
  Xml.XMLIntf;

type
  TEachAction = record
    ActionNumber: Integer;
    Time: string;
    FileVersion: string;
    FileName: string;
    CommandLine: string;
    Description: string;
    Action: string;
    ScreenshotFileName: string;
  end;

  IMHTRecordingXmlParser = interface(IInvokable)
    ['{11D71D02-D51E-4746-AC7C-11B070069B0A}']
    function Xml(): string; overload;
    function Xml(const Value: string): IMHTRecordingXmlParser; overload;

    function Execute(): TArray<TEachAction>;
  end;

  TMHTRecordingXmlParser = class(TInterfacedObject, IMHTRecordingXmlParser)
  strict private
    FXml: string;
    FXmlDoc: IXMLDocument;
  private
    function GetRecursiveFirstSearchNode(BaseNode: IXMLNode; const SearchNodeName: string): IXMLNode;
    function ReplaceInvalidXmlCharacters(const Match: TMatch): string;
    procedure OpenXmlDoc();
  public
    constructor Create();
    destructor Destroy(); override;

    function Xml(): string; overload;
    function Xml(const Value: string): IMHTRecordingXmlParser; overload;

    function Execute(): TArray<TEachAction>;
  end;

implementation

uses
  {$IFDEF MSWINDOWS}Winapi.ActiveX,{$ENDIF}
  Xml.XMLDoc,
  Xml.xmldom;

{ TMHTRecordingXmlParser }

constructor TMHTRecordingXmlParser.Create;
begin
  inherited;
  {$IFDEF MSWINDOWS}CoInitialize(nil);{$ENDIF}
  FXmlDoc := TXMLDocument.Create(nil);
end;

destructor TMHTRecordingXmlParser.Destroy;
begin
  FXmlDoc.Active := False;
  FXmlDoc := nil;
  {$IFDEF MSWINDOWS}CoUninitialize;{$ENDIF}
  inherited;
end;

function TMHTRecordingXmlParser.Xml(const Value: string): IMHTRecordingXmlParser;
begin
  FXml := Value;
  Result := Self;
end;

function TMHTRecordingXmlParser.Xml: string;
begin
  Result := FXml;
end;

function TMHTRecordingXmlParser.GetRecursiveFirstSearchNode(BaseNode: IXMLNode; const SearchNodeName: string): IXMLNode;
begin
  Result := nil;
  if string(BaseNode.NodeName).StartsWith(SearchNodeName) then
  begin
    Exit(BaseNode);
  end
  else
  if (not Assigned(BaseNode.ChildNodes)) then
  begin
    Exit(nil);
  end;

  for var Idx: Integer := 0 to BaseNode.ChildNodes.Count - 1 do
  begin
    Result := GetRecursiveFirstSearchNode(BaseNode.ChildNodes[Idx], SearchNodeName);
    if Assigned(Result) then
      Exit;
  end;
end;


function TMHTRecordingXmlParser.Execute: TArray<TEachAction>;
const
  UserActionData = 'UserActionData';
  RecordSession = 'RecordSession';
  Description = 'Description';
  Action = 'Action';
  ScreenshotFileName = 'ScreenshotFileName';
var
  InnerRoot: IXMLNode;
  UserActionDataNode: IXMLNode;
  RecordSessionNode: IXMLNode;
  EachActionNodes: IXMLNode;
  AnyNode: IXMLNode;
  Actions: Integer;
  InnerFunc: TFunc<IXMLNode, string, string>;
begin
  OpenXmlDoc;

  InnerRoot := FXmlDoc.DocumentElement;

  UserActionDataNode := GetRecursiveFirstSearchNode(InnerRoot, UserActionData);
  if Assigned(UserActionDataNode) then
  begin
    RecordSessionNode := GetRecursiveFirstSearchNode(UserActionDataNode, RecordSession);
    Actions := string(RecordSessionNode.Attributes['ActionCount']).ToInteger();
    SetLength(Result, Actions);

    for var Idx: Integer := 0 to RecordSessionNode.ChildNodes.Count - 1 do
    begin
      Result[Idx].ActionNumber := string(RecordSessionNode.ChildNodes[Idx].Attributes['ActionNumber']).ToInteger();
      Result[Idx].Time := string(RecordSessionNode.ChildNodes[Idx].Attributes['Time']);
      Result[Idx].FileVersion := string(RecordSessionNode.ChildNodes[Idx].Attributes['FileVersion']);
      Result[Idx].FileName := string(RecordSessionNode.ChildNodes[Idx].Attributes['FileName']);
      Result[Idx].CommandLine := string(RecordSessionNode.ChildNodes[Idx].Attributes['CommandLine']);

      EachActionNodes := RecordSessionNode.ChildNodes[Idx];

      InnerFunc :=
        function(FromNodes: IXMLNode; ToSearch: string): string
        begin
          var InnerNode := GetRecursiveFirstSearchNode(FromNodes, ToSearch);
          if (Assigned(InnerNode) and InnerNode.IsTextElement) then
          begin
            Result := InnerNode.Text;
          end
          else
            Exit(string.Empty);
        end;

      Result[Idx].Description := InnerFunc(EachActionNodes, Description);
      Result[Idx].Action := InnerFunc(EachActionNodes, Action);
      Result[Idx].ScreenshotFileName := InnerFunc(EachActionNodes, ScreenshotFileName);

//      AnyNode := GetRecursiveFirstSearchNode(EachActionNodes, Description);
//      if (Assigned(AnyNode) and AnyNode.IsTextElement) then
//      begin
//        Result[Idx].Description := AnyNode.Text;
//      end;
//
//      AnyNode := GetRecursiveFirstSearchNode(EachActionNodes, Action);
//      if (Assigned(AnyNode) and AnyNode.IsTextElement) then
//      begin
//        Result[Idx].Action := AnyNode.Text;
//      end;
//
//      AnyNode := GetRecursiveFirstSearchNode(EachActionNodes, ScreenshotFileName);
//      if (Assigned(AnyNode) and AnyNode.IsTextElement) then
//      begin
//        Result[Idx].ScreenshotFileName := AnyNode.Text;
//      end;
    end;
  end;

//  LBase64: string;
//  LTBytes: TBytes;
//    ChildNode := ChildNode.ChildNodes.FindNode('BinaryBase64Object', 'schema');
//    if ChildNode <> nil then
//    begin
//      LBase64 := ChildNode.Text;
//      LTBytes := TNetEncoding.Base64.DecodeStringToBytes(LBase64);
//      TFile.WriteAllBytes(TPath.ChangeExtension(AFilename, '.xslt'), LTBytes);
//    end
end;

procedure TMHTRecordingXmlParser.OpenXmlDoc;
begin
  FXmlDoc.Active := False;
  if FXml.IsEmpty then
    Exit;

  //  https://dvteclipse.com/documentation/svlinter/How_to_use_special_characters_in_XML.3F.html
  FXml := TRegEx.Replace(FXml, 'name=\"[^\"]*\"', ReplaceInvalidXmlCharacters);

  FXmlDoc.LoadFromXML(FXml);
  FXmlDoc.Options := FXmlDoc.Options + [doNodeAutoIndent];
  FXmlDoc.Active := True;
end;

function TMHTRecordingXmlParser.ReplaceInvalidXmlCharacters(const Match: TMatch): string;
begin
  //  Found symbol files with invalid characters in attribute, sample:
  //  <symbol name="{System.Generics.Collections}TList<System.Tether.Manager.TTetheringProfileInfo>.GetItem"/>
  Result := Match
    .Value
    .Replace('<', '&lt;')
    .Replace('>', '&gt;')
    .Replace('&', '&amp;');
//    .Replace('"', '&quot;')
//    .Replace('''', '&apos;');
end;

end.
