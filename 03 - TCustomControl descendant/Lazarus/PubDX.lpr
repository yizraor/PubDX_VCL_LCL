program PubDX;

{$MODE Delphi}

uses
  Forms, Interfaces,
  uDxTypes in '..\..\common\uDxTypes.pas',
  uD3Dcommon in '..\..\common\uD3Dcommon.pas',
  uDXGI in '..\..\common\uDXGI.pas',
  uD3D11 in '..\..\common\uD3D11.pas',
  uD3D11sdklayers in '..\..\common\uD3D11sdklayers.pas',
  uD3Dcompiler in '..\..\common\uD3Dcompiler.pas',
  uD3DX11 in '..\..\common\uD3DX11.pas',
  uFormMain in 'uFormMain.pas' {FormMain},
  uFormAbout in 'uFormAbout.pas' {FormAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormAbout, FormAbout);
  Application.Run;
end.
