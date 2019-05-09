unit frm_CutDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, JvExMask,
  JvToolEdit, JvBaseEdits;

type
  TfrmCutDialog = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Ok: TButton;
    Cancel: TButton;
    edCutFrom: TJvCalcEdit;
    edRealNumber: TJvCalcEdit;
  private
    function GetCutFrom: integer;
    function GetRealNumber: integer;
    { Private declarations }
  public
    { Public declarations }
    property CutFrom: integer read GetCutFrom;
    property RealNumber: integer read GetRealNumber;
  end;

var
  frmCutDialog: TfrmCutDialog;

implementation

{$R *.dfm}

{ TfrmCutDialog }

function TfrmCutDialog.GetCutFrom: integer;
begin
  Result := Round(edCutFrom.Value);
end;

function TfrmCutDialog.GetRealNumber: integer;
begin
  Result := Round(edRealNumber.Value);
end;

end.
