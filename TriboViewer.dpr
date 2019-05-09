program TriboViewer;


uses
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  System.Types,
  frm_Main in 'frm_Main.pas' {frmMain},
  unit_PrevInst in 'unit_PrevInst.pas',
  unit_Messages in 'unit_Messages.pas',
  frm_Progress in 'frm_Progress.pas' {frmProgress},
  frm_CutDialog in 'frm_CutDialog.pas' {frmCutDialog};

{$R *.res}

var
  Handle: HWND;

begin
  Application.Initialize;
  Application.Title := 'TriboViewer';

  {$IFDEF WIN64}
    Application.Title  := 'Tribo Viewer 64 bit';
  {$ELSE}
    if FirstHinstanceRunning(1) then
    begin
      Handle := FindWindow(PWideChar('TfrmMain'), 'TriboViewer');
      LoadFromFile(Handle, ParamStr(1));
      Exit;
    end;
  {$ENDIF}

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmCutDialog, frmCutDialog);
  Application.Run;
end.
