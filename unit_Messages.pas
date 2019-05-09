unit unit_Messages;

interface

uses
  WinApi.Windows,
  Winapi.Messages;

const
  WM_TRIBO_BASE = WM_APP + $0900;
  WM_TRIBO_LOADFROMFILE = WM_TRIBO_BASE + 1;

procedure LoadFromFile(Target: HWND; FileName: String);

implementation

uses
  Forms, SysUtils;


procedure LoadFromFile;
var
  CDS: TCopyDataStruct;
begin
  CDS.dwData := WM_TRIBO_LOADFROMFILE;
  CDS.cbData := Length(FileName) + 1;
  GetMem(CDS.lpData, CDS.cbData);
  try
    //Копируем данные в буфер
    StrPCopy(CDS.lpData, AnsiString(FileName));
    //Отсылаем сообщение в окно с заголовком StringReceiver
    SendMessage(Target, WM_COPYDATA, Application.Handle, Integer(@CDS));
  finally
    //Высвобождаем буфер
    FreeMem(CDS.lpData, CDS.cbData);
  end;
end;

end.
