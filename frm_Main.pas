unit frm_Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.FileCtrl, RzFilSys, Vcl.ComCtrls, RzTreeVw, RzShellCtrls,
  RzPanel, RzSplit, Vcl.ExtCtrls, VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart,
  RzTabs, RzButton, Vcl.ImgList, RzStatus, System.Actions, Vcl.ActnList,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, RzListVw, Vcl.Menus, Vcl.ExtDlgs,
  System.ImageList, ZipMstr;

type
  TDataPoint = record
    x,y: Double;
  end;

  TData = array of TDataPoint;

  TfrmMain = class(TForm)
    rztlbrMain: TRzToolbar;
    Status: TRzStatusBar;
    RzSplitter1: TRzSplitter;
    RzPanel1: TRzPanel;
    RzPanel2: TRzPanel;
    Tree: TRzShellTree;
    Pages: TRzPageControl;
    rztbshtCOF: TRzTabSheet;
    chrtCOF: TChart;
    srsCOF: TLineSeries;
    rztbshtRaw: TRzTabSheet;
    chrtL: TChart;
    srsFl: TLineSeries;
    chrtN: TChart;
    srsFn: TLineSeries;
    ilTools: TImageList;
    rztlbtnSave: TRzToolButton;
    rztlbtnCopy: TRzToolButton;
    srsSmooth: TLineSeries;
    Status1: TRzStatusPane;
    StatusX: TRzStatusPane;
    Status2: TRzStatusPane;
    StatusY: TRzStatusPane;
    rzspcr1: TRzSpacer;
    btnStartBtnJumptoLine: TRzToolButton;
    btnStartBtnClear: TRzToolButton;
    dlgSave: TSaveDialog;
    actmgr: TActionManager;
    actExport: TAction;
    actCopy: TAction;
    Files: TRzShellList;
    btnStartBtnInsertImage: TRzToolButton;
    rzspcr2: TRzSpacer;
    actFileSaveImage: TAction;
    actFileCopyImage: TAction;
    ImageMenu: TPopupMenu;
    Sa1: TMenuItem;
    actFileCopyImage1: TMenuItem;
    dlgSaveImage: TSavePictureDialog;
    btnStartBtnExport: TRzToolButton;
    actFileSave: TAction;
    RzPanel3: TRzPanel;
    lblFileName: TLabel;
    lblData1: TLabel;
    lblData2: TLabel;
    lblData3: TLabel;
    rzspcr3: TRzSpacer;
    btnNumberOfCycles: TRzToolButton;
    actCycles: TAction;
    Progress: TRzProgressStatus;
    actReCompress: TAction;
    btnStartBtnExecute: TRzToolButton;
    RzVersionInfo1: TRzVersionInfo;
    RzVersionInfoStatus1: TRzVersionInfoStatus;
    BtnRefresh: TRzToolButton;
    Zip: TZipMaster;
    RzToolButton1: TRzToolButton;
    procedure FormCreate(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure chrtCOFMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure btnStartBtnJumptoLineClick(Sender: TObject);
    procedure btnStartBtnClearClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure FilesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure actFileSaveImageExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actFileCopyImageExecute(Sender: TObject);
    procedure chrtCOFAfterDraw(Sender: TObject);
    procedure chrtLAfterDraw(Sender: TObject);
    procedure actCyclesExecute(Sender: TObject);
    procedure actReCompressExecute(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure ZipProgress(Sender: TObject; Details: TZMProgressDetails);
    procedure RzToolButton1Click(Sender: TObject);
  private
    { Private declarations }

    Fl, Fn, COF: TData;
    N, Nn: integer;

    Header: TStringList;
    SamplingRate: Integer;
    SmoothCof: Integer;
    FLastFileName: string;

    procedure LoadData(const FileName: string);
    procedure Smooth(const N: Integer; var Data: TData);
    procedure Compress(const Max: Integer; Input: TData; out Output: TData);
    procedure Plot(Data: TData; var Series: TLineSeries);
    procedure Symmetry;
    procedure GetProfileAsText(List: TStringList; Series: TLineSeries);
    procedure CutData(Series: TLineSeries);
    procedure Envelope(var Input, Output: TData);
    procedure AddPoint(const x,y: double; var Data: TData);
    procedure CalcCOF;
    function NumberOfCycles(S: string):Integer;

    procedure LoadSettings;
    procedure SaveSettings;
    procedure SaveData(FileName: string);
    procedure LoadArch(FileName: string);
    procedure LoadRAW(FileName: string);
    procedure PlotRaw;
    procedure PlotCOF(Scale: Double = 1);

    procedure SetLabels(Name, D1, D2, D3: string);
    procedure OnCopyDataMsg(var MessageData: TWMCopyData); message WM_COPYDATA;
    procedure ProcessFile;
    procedure ClearView;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Clipbrd, System.IniFiles, System.Win.Registry, unit_Messages, frm_Progress,
  frm_CutDialog;

{$R *.dfm}

procedure RegisterFileType(prefix: string; exepfad: string);
begin
 with TRegistry.Create do
   try
     RootKey := HKEY_CURRENT_USER;
     OpenKey('Software\\Classes\\' + '.' + prefix, True);
     WriteString('', prefix + 'file');
     CloseKey;
     CreateKey('Software\\Classes\\' + prefix + 'file');
     OpenKey('Software\\Classes\\' + prefix + 'file\\DefaultIcon', True);
     WriteString('', exepfad + ',0');
     CloseKey;
     OpenKey('Software\\Classes\\' + prefix + 'file\\shell\\open\\command', True);
     WriteString('', '""' + exepfad + '" "%1"');
     CloseKey;
   finally
     Free;
   end;
end;

procedure TfrmMain.GetProfileAsText(List: TStringList; Series: TLineSeries);
var
  i: integer;
  S: string;
begin
  if List.Count = 0 then
  begin
    List.Add('Cycles' + #09 + 'COF');
    List.Add(' ' + #09 + ' ');
    List.Add('');
  end
  else
  begin
    List[0] := 'Cycles' + #09 + 'COF';
    List[1] := ' ' + #09 + ' ';
  end;

  for I := 0 to Series.Count - 1 do
  begin
    S := FloatToStrF(Series.XValues[i], ffFixed, 4, 4) +
         #09 + FloatToStrF(Series.YValues[i], ffFixed, 4, 4);
    List.Add(S);
  end;
end;


procedure TfrmMain.FilesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  Ext: string;
begin
  if not Item.Selected then Exit;
  if Files.SelectedItem.PathName = '' then Exit;
  if Files.SelectedItem.PathName = FLastFileName then Exit;

  if ExtractFileExt(Files.SelectedItem.PathName) = '' then Exit;

  FLastFileName := Files.SelectedItem.PathName;

  try
    Screen.Cursor := crHourGlass;

    ClearView;

    Nn := 0;   // value from the file will be used
    ProcessFile;

    SetLabels(Files.SelectedItem.PathName, Header[4], Header[5], Header[6]);
    Pages.ActivePageIndex := 0;

  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  S: string;
  i: integer;
  Item : TListItem;
begin
  {$IFDEF WIN64}
    Caption := 'Tribo Viewer 64 bit';
  {$ENDIF}


  FormatSettings.DecimalSeparator := '.';
  Header := TStringList.Create;
  SetLabels('','','','');
  LoadSettings;
  if ParamCount > 0 then
  begin
    if ParamStr(1) = '-ext' then RegisterFileType('zrw', Application.ExeName)
    else
    begin
      S := ParamStr(1);
      if ExtractFileExt(S) = '.raw' then
         LoadData(S)
      else
        LoadArch(S);

      Tree.SelectedPathName := ExtractFilePath(S);
      SetLabels(ExtractFileName(S), Header[4], Header[5], Header[6]);
    end;
  end;
end;


procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  FreeAndNil(Header);
end;

procedure TfrmMain.SaveData(FileName: string);
var
  ZipRenameList : TList;
  RenRec: PZMRenameRec;
begin
  try
    ZipRenameList := TList.Create();
    New(RenRec);


    Zip.ZipFileName := FileName;
    Zip.FSpecArgs.Add(Files.SelectedItem.PathName);
    Zip.Add;

    RenRec^.Source := ExtractFileName(Files.SelectedItem.FileName);
    RenRec^.Dest := 'Data.raw';
    ZipRenameList.Add(RenRec);
    Zip.Rename(ZipRenameList, 0, HtrDefault);

    Header.SaveToStream(Zip.ZipStream);
    Zip.AddStreamToFile('Data.dat', 0, 0);

  finally
    Dispose(RenRec);
    FreeAndNil(ZipRenameList);
    FreeAndNil(Zip);
  end;

end;

procedure TfrmMain.SaveSettings;
var
  Ini: TIniFile;
begin
  try
    Ini := TInifile.Create(ChangeFileExt(Application.ExeName,'.ini'));

    Ini.WriteString('Path', 'ImportFolder', Tree.SelectedPathName);
    Ini.WriteString('Path', 'ExportFolder', ExtractFilePath(dlgSave.FileName));

  finally
    FreeAndNil(Ini);
  end;
end;

procedure TfrmMain.SetLabels(Name, D1, D2, D3: string);
begin
  lblFileName.Caption := Name;
  lblData1.Caption := D1;
  lblData2.Caption := D2;
  lblData3.Caption := D3;
end;

procedure TfrmMain.Smooth;
var
  i,j: Integer;
  s: Double;
begin
  for I := 0 to High(Data) - N do
  begin
    S := 0;
    for j := 0 to N do
      S := S + Data[i + J].y;
    Data[i + N div 2].y := S/(N + 1);
  end;
end;

procedure TfrmMain.Symmetry;
var
  i: Integer;
  Avg: Double;
  Max, Total: Integer;
begin
  Avg := 0;

  Total := High(Fl);
  Max := Round(0.9 * Total);

  for I := 3 to Max do
    Avg := Avg + Fl[i].y;

  Avg := Avg / Total;

  for I := 0 to Total do
    Fl[i].y := Fl[i].y - Avg;


end;

procedure TfrmMain.actCopyExecute(Sender: TObject);
var
  List: TStringList;
begin
  List := TStringList.Create;
  GetProfileAsText(List, srsSmooth);
  Clipboard.AsText := List.Text;
  FreeAndNil(List);
end;

procedure TfrmMain.actFileCopyImageExecute(Sender: TObject);
begin
  chrtCOF.CopyToClipboardBitmap;
end;

procedure TfrmMain.actFileSaveExecute(Sender: TObject);
begin
  dlgSave.DefaultExt := '.zrw';
  dlgSave.Filter := 'Tribotest data|*.zrw';

  if Files.SelectedItem <> nil then
     dlgSave.FileName := ExtractFileName(ChangeFileExt(Files.SelectedItem.FileName, '.zrw'))
  else
    dlgSave.FileName := ExtractFileName(ChangeFileExt(ParamStr(1), '.zrw'));

  if dlgSave.Execute then
  begin
    try
      Screen.Cursor := crHourGlass;
      ShowProgress;

      GetProfileAsText(Header, srsSmooth);

      if FileExists(dlgSave.FileName) then DeleteFile(dlgSave.FileName);

      SaveData(dlgSave.FileName);
    finally
      Screen.Cursor := crDefault;
      HideProgress;
    end;
  end;
end;

procedure TfrmMain.actFileSaveImageExecute(Sender: TObject);
begin
  if dlgSaveImage.Execute then chrtCOF.SaveToBitmapFile(dlgSaveImage.FileName);
end;

procedure TfrmMain.actReCompressExecute(Sender: TObject);
var
  S: string;
  B: TData;

  Window, i, j: Integer;
  SS: Double;
  Count: Integer;
begin
  if Files.SelectedItem.PathName = '' then Exit;

  Window := Round(srsSmooth.Count / 1000);
  if Window < 3 then Exit;


  try
    Screen.Cursor := crHourGlass;
    srsSmooth.BeginUpdate;



    i := 0;
    repeat
      SS := 0;
      for j := 0 to Window - 1 do
        SS := SS + srsSmooth.YValues[j + i];

      srsSmooth.XValues[i] := (srsSmooth.XValues[i] + srsSmooth.XValues[i + Window]) / 2;
      srsSmooth.YValues[i] := SS / Window;
      inc(i);

      for j := 0 to Window - 1 do
        if (i + j) < srsSmooth.Count - 1 then
          srsSmooth.Delete(i + j);

    until i >= srsSmooth.Count - 1;

    srsSmooth.EndUpdate;

    S := '';
    for I := 0 to 7 do
      S := S + Header.Strings[i] + #13#10;

     Header.Text := S;
     GetProfileAsText(Header, srsSmooth);

    Zip.ZipFileName := Files.SelectedItem.PathName;
    Zip.FSpecArgs.Add('Data.dat');
    Zip.Delete;
    Header.SaveToStream(Zip.ZipStream);
    Zip.AddStreamToFile('Data.dat', 0, 0);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.ProcessFile;
var
  ext: string;
begin
  Ext:= ExtractFileExt(Files.SelectedItem.FileName);

  if Ext = '.raw' then
  begin
    LoadData(Files.SelectedItem.PathName);
    actFileSave.Enabled := True;
  end;

  if Ext = '.zrw' then
  begin
    LoadArch(Files.SelectedItem.PathName);
    actFileSave.Enabled := False;
  end;
end;


procedure TfrmMain.RzToolButton1Click(Sender: TObject);
begin
  CutData(srsSmooth);
end;

procedure TfrmMain.actCyclesExecute(Sender: TObject);
var
  S, ext: string;
begin
  S := InputBox('Number of cycles','New value', '0');
  if S = '0' then Exit;

  Nn := StrToInt(S);
  ProcessFile;
end;

procedure TfrmMain.actExportExecute(Sender: TObject);
begin
  dlgSave.DefaultExt := '.dat';
  dlgSave.Filter := 'ASCII file|*.dat';

  if Files.SelectedItem <> nil then
     dlgSave.FileName := ExtractFileName(ChangeFileExt(Files.SelectedItem.FileName, '.dat'))
  else
    dlgSave.FileName := ExtractFileName(ChangeFileExt(ParamStr(1), '.dat'));

  if dlgSave.Execute then
  begin
    GetProfileAsText(Header, srsSmooth);
    Header.SaveToFile(dlgSave.FileName);
  end;
end;

procedure TfrmMain.AddPoint;
var
  N : Integer;
begin
  N := High(Data) + 2;
  SetLength(Data, N);
  Data[N - 1].x := x;
  Data[N - 1].y := y;
end;

procedure TfrmMain.BtnRefreshClick(Sender: TObject);
var
  Stream : TMemoryStream;
  OrgFileName: string;
begin
  if Files.SelectedItem <> nil then
     OrgFileName := Files.SelectedItem.PathName
  else
    OrgFileName:= ParamStr(1);

  if ExtractFileExt(OrgFileName) <> '.zrw' then Exit;

  dlgSave.DefaultExt := '.raw';
  dlgSave.FileName := ChangeFileExt(ExtractFileName(OrgFileName), '.raw');
  dlgSave.Filter := 'RAW Tribotest data|*.raw';

  if Not dlgSave.Execute then Exit;

  try
    Screen.Cursor := crHourGlass;
    ShowProgress;

    Stream := TMemoryStream.Create;

    Zip.ZipFileName := OrgFileName;
    Zip.FSpecArgs.Add('Data.raw');
    Stream := Zip.ExtractFileToStream('Data.raw');
    Stream.Seek(0, soFromBeginning);
    Stream.SaveToFile(dlgSave.FileName);

  finally
    Screen.Cursor := crDefault;
    HideProgress;
  end;
end;

procedure TfrmMain.btnStartBtnClearClick(Sender: TObject);
var
  A: TData;
begin
  try
    Screen.Cursor := crHourGlass;
    CalcCOF;
    Compress(N, COF, A);
    Plot(A, srsCOF);
  finally

  end;
end;

procedure TfrmMain.btnStartBtnJumptoLineClick(Sender: TObject);
begin
  try
    Screen.Cursor := crHourGlass;

    if actFileSave.Enabled then
    begin
      Plot(Fl, srsFl);
      Plot(Fn, srsFn);
      Pages.ActivePageIndex := 1;
    end
    else begin
      LoadRAW(Files.SelectedItem.PathName);
      PlotRaw;
    end;
  finally

  end;
end;

procedure TfrmMain.CalcCOF;
var
  i: Integer;
  Max: Integer;
begin
  Max := High(Fl);
  SetLength(COF, Max + 1);
  for I := 0 to Max do
  begin
    COF[i].x := Fl[i].x;
    if Fn[i].y > 0 then
      COF[i].y := Abs(Fl[i].y/Fn[i].y)
    else
      COF[i].y := 0;
  end;
end;

procedure TfrmMain.chrtCOFAfterDraw(Sender: TObject);
begin
  Screen.Cursor := crDefault;
end;

procedure TfrmMain.chrtCOFMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  xv, yv: single;
begin
  xv := srsSmooth.XScreenToValue(X);
  yv := srsSmooth.YScreenToValue(Y);
  StatusX.Caption := FloatToStrF(xv, ffFixed, 4, 3);
  StatusY.Caption := FloatToStrF(yv, ffFixed, 4, 3);

end;

procedure TfrmMain.chrtLAfterDraw(Sender: TObject);
begin
  Screen.Cursor := crDefault;
end;

procedure TfrmMain.ClearView;
begin
  srsFl.Clear;
  srsFn.Clear;
  srsCOF.Clear;

  chrtCOF.Update;

  lblFileName.Caption := '';
  lblData1.Caption := '';
  lblData2.Caption := '';
  lblData3.Caption := '';
end;

procedure TfrmMain.Compress;
var
  i,j,k: Integer;
  s, Scale: Double;
  Count: Longint;
  Window, NMax: Integer;
begin
  Count := High(Input);
  Scale := Max / Input[Count].X;  // counts per cycle

  if Max > 1000 then
  begin
    NMax := 1000;
  end
    else begin
      NMax := Max;
    end;

  Window := Round(Count / NMax);

  S := 0; j := 0; k := 0;
  for I := 0 to High(Input) do
  begin
    S := S + Input[i].y;
    inc(j);
    if j = Window then
    begin
      AddPoint(Scale * Input[i].x, S / j, Output);
      j := 0;
      S := 0;
    end;
  end;
end;

procedure TfrmMain.CutData(Series: TLineSeries);
var
  S: string;
  i, k, N, j, Nc: integer;
  XScale: double;
begin
  if (frmCutDialog.ShowModal <> mrOk) then Exit;

  Nn :=  frmCutDialog.RealNumber;
  Nc := frmCutDialog.CutFrom;

  Series.BeginUpdate;
  i := Series.Count - 1; k:= 0;

  N := NumberOfCycles(Header[6]);
  Header[6] := StringReplace(Header[6], IntToStr(N), IntToStr(nN), []);

  while (Series.XValue[i] > Nc) and (i > 0) do
  begin
    inc(k);
    dec(i);
  end;

  Series.Delete(i - 1, k + 2);

  XScale := Nn / Series.Count;
  for I := 0 to Series.Count - 1 do
    Series.XValue[i] := i * XScale;

  Series.EndUpdate;
  lblData3.Caption := Header [6];
end;

procedure TfrmMain.Envelope;
var
  Derivative: TData;
  i, N, j, k: Integer;
  Max, S, SS: Double;

  A: TData;

begin
  N := 20;
  SetLength(Derivative, High(Input) + 1);


  for I := 0 to High(Input) - 1 do
  begin
    Derivative[i].y := (Input[i + 1].y - Input[i].y)/(Input[i + 1].x - Input[i].x);
  end;

  for I := 0 to High(Input) do
  begin
    if (Derivative[i].y < 0.00001) then
    begin
      AddPoint(Input[i].x, Input[i].y, A);
    end;
  end;

  for I := 0 to High(A) - N do
  begin
    S := 0;
    for j := i to i + N do
      S := S + A[j].y;

    S := S / N;

    if A[i].y > 0.98 * S then
      AddPoint(A[i].x, A[i].y, Output);
  end;
end;

procedure TfrmMain.LoadArch(FileName: string);
var
  S: TMemoryStream;
begin
  try
    Zip.DLL_Load := True;
    Zip.ZipFileName := FileName;
    S := Zip.ExtractFileToStream('Data.dat');

    S.Seek(0, soFromBeginning);
    Header.LoadFromStream(S);
    N := NumberOfCycles(Header[6]);
    if (nN > 0) then
    begin
      Header[6] := StringReplace(IntToStr(N), IntToStr(nN), Header[6],[]);
      PlotCOF(nN/N);
      N := nN;
    end
    else
      PlotCOF;
  finally

  end;
end;

procedure TfrmMain.LoadData;
const
  D = #9;
var
  FB: file of Byte;
  i, j, k, count: Integer;
  S: string;
  A,B: TData;
  List : TStringList;
begin
  ShowProgress;

  SetLength(Fl, 0);
  SetLength(Fn, 0);
  Header.Clear;

  List := TStringList.Create;
  try
    List.LoadFromFile(FileName);

    for i := 0 to 7 do
    begin
      S := List[i];
      Header.Add(S);
      if i = 6 then N := NumberOfCycles(S);
      if i = 7 then  SamplingRate := NumberOfCycles(S);
    end;

    if (N = 0) and (nN = 0) then N := 100;
    if (nN > 0) then
    begin
      Header[6] := StringReplace(Header[6], IntToStr(N), IntToStr(nN),[]);
      N := nN;
    end;

    Count := 0;

    SetLength(Fn, List.Count - 8);
    SetLength(Fl, List.Count - 8);

    for I := 8 to List.Count - 1 do
    begin
      S := List[i];

      try
        for j := 1 to Length(S) do
          if S[j] = D then
          begin
            Fn[Count].x := StrToFloat(Copy(S, 1, j - 1));
            k := j + 1;
            Break;
          end;

        for j := k to Length(S) do
          if S[j] = D then
          begin
            Fn[Count].y := StrToFloat(Copy(S, k, j - k - 1));
            Fl[Count].y := StrToFloat(Copy(S, j + 1));
            Fl[Count].x := Fn[Count].x;
            Break;
          end;
        Inc(Count);
      except

      end;

      if (List.Count mod i = 100) then
          UpdateProgress(i/ List.Count * 100);
    end;

  finally
    FreeAndNil(List);
  end;

  Symmetry;

  if SamplingRate <= 25 then
    SmoothCof := 15
  else
    SmoothCof := 5;


  // smooth
  Smooth(SmoothCof, Fl);
  Smooth(SmoothCof, Fn);
  CalcCOF;
  Envelope(COF, A);
  Envelope(A, B);
  UpdateProgress(95);
  Smooth(SmoothCof, B);
  Compress(N, B, COF);
  UpdateProgress(98);
  Plot(COF, srsSmooth);
  UpdateProgress(100);
  HideProgress;
end;

procedure TfrmMain.LoadRAW(FileName: string);
const
  D = #9;
var
  List: TStringList;
  S: string;
  i: Integer;
  Stream: TMemoryStream;

  procedure ExtractValues(S: string);
  var
    N: Integer;
    l, nn: Double;
    p: Integer;
  begin
    p := Pos(D, S);
    N := StrToInt(Copy(S, 1, p - 1));
    Delete(S, 1, p);

    p := Pos(D, S);
    nn := StrToFloat(Copy(S, 1, p - 1));
    Delete(S, 1, p);

    l := StrToFloat(S);

    AddPoint(N, nn, Fn);
    AddPoint(N, l, Fl);
  end;

begin
  try
    SetLength(COF, 0);
    SetLength(Fl, 0);
    SetLength(Fn, 0);

    List := TStringList.Create;

    Zip.ZipFileName :=FileName;
    Stream := Zip.ExtractFileToStream('Data.raw');
    Stream.Seek(0, soFromBeginning);
    List.LoadFromStream(Stream);

    for I := 9 to List.Count - 1 do
      ExtractValues(List[i]);

  finally
    FreeAndNil(List);
  end;

end;

procedure TfrmMain.LoadSettings;
var
  Ini: TIniFile;
begin
  try
    Ini := TInifile.Create(ChangeFileExt(Application.ExeName,'.ini'));

    Tree.SelectedPathName := Ini.ReadString('Path', 'ImportFolder', 'C:\');
    dlgSave.InitialDir := Ini.ReadString('Path', 'ExportFolder', 'C:\');

  finally
    FreeAndNil(Ini);
  end;
end;

function TfrmMain.NumberOfCycles(S: string): Integer;
var
  p: Integer;
  S1: string;
begin
  if S = '' then
  begin
    Result := 0;
    Exit;
  end;

  S := Trim(S);
  p := Pos(#9, S);
  Delete(S, 1, p);
  p := Pos(#9, S);
  if p = 0 then
    Result := StrToInt(S)
  else
  begin
    S1 := Copy(S, 1, p - 1);
    if S1 <> '' then Result := StrToInt(S1)
  end;
end;

procedure TfrmMain.OnCopyDataMsg(var MessageData: TWMCopyData);
var
  Str : string;
begin
  if MessageData.CopyDataStruct.dwData = WM_TRIBO_LOADFROMFILE then
  begin
    Str := string(PAnsiChar((MessageData.CopyDataStruct.lpData)));
    if ExtractFileExt(Str) = '.raw' then
         LoadData(Str)
      else
        LoadArch(Str);
  end
  else
    MessageData.Result := 0;
end;

procedure TfrmMain.Plot;
var
  i: Integer;
begin
  Series.BeginUpdate;
  Series.Clear;

  for I := 0 to High(Data) do
    Series.AddXY(Data[i].x, Data[i].Y);
  Series.EndUpdate;
end;

procedure TfrmMain.PlotCOF;
var
  i: Integer;
  X,Y: Double;
  p: Integer;
  S: string;
begin
  srsSmooth.BeginUpdate;
  srsSmooth.Clear;
  Progress.Percent := 0;

  for I := 9 to Header.Count - 1 do
  begin
    S := Header[i];
    p := Pos(#9, S);
    x := StrToFloat(Copy(S, 1, p - 1)) * Scale;
    Delete(S, 1, p);
    y := StrToFloat(S);
    srsSmooth.AddXY(x,y);

    Progress.Percent := round(i / Header.Count * 80);
  end;
  srsSmooth.EndUpdate;
  Progress.Percent := 100;
end;

procedure TfrmMain.PlotRaw;
begin
    Symmetry;
    Smooth(SmoothCof, Fl);
    Smooth(SmoothCof, Fn);

    Plot(Fl, srsFl);
    Plot(Fn, srsFn);
    Pages.ActivePageIndex := 1;
end;

procedure TfrmMain.TreeChange(Sender: TObject; Node: TTreeNode);
begin
  Files.Folder.PathName := Tree.SelectedPathName;
  if Files.SelCount = 0 then ClearView;
end;

procedure TfrmMain.ZipProgress(Sender: TObject; Details: TZMProgressDetails);
begin
  if Assigned(frmProgress) and  frmProgress.Showing then
     UpdateProgress(Details.TotalPerCent);
end;

end.
