unit uFormAbout;

{$MODE Delphi}

interface

uses
  SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    lblAbout: TLabel;
    btnOk: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}

{ TFormAbout }

end.
