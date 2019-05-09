unit frm_Progress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RzPrgres, Vcl.ExtCtrls, RzPanel;

type
  TfrmProgress = class(TForm)
    RzPanel1: TRzPanel;
    Progress: TRzProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure ShowProgress;
  procedure UpdateProgress(Value: double);
  procedure HideProgress;

var
  frmProgress: TfrmProgress;

implementation

{$R *.dfm}

uses frm_Main;


procedure ShowProgress;
begin
  if not Assigned(frmProgress) then
    frmProgress := TfrmProgress.Create(frmMain);

  frmProgress.Progress.Percent := 0;
  frmProgress.Progress.Update;
  frmProgress.Show;
  frmProgress.Update;
end;

procedure UpdateProgress;
begin
  frmProgress.Progress.Percent := Round(Value);
  frmProgress.Progress.Update;
end;

procedure HideProgress;
begin
  frmProgress.Hide;
end;

end.
