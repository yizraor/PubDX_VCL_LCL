unit uFormMain;

INTERFACE

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, System.Actions, Vcl.ActnList,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  uDxTypes, uD3Dcommon, uDXGI, uD3D11, uD3D11sdklayers,
  uD3Dcompiler, uD3DX11;

type
  TFormMain = class(TForm)
    ActionList: TActionList;
    actFileSample1: TAction;
    actFileSample2: TAction;
    actFileOpen: TAction;
    actFileSave: TAction;
    actRenderVSync: TAction;
    actRenderMsaa1: TAction;
    actRenderMsaa2: TAction;
    actRenderMsaa4: TAction;
    actRenderMsaa8: TAction;
    actOtherDebugDevice: TAction;
    actOtherDebugReport: TAction;
    actProgramQuit: TAction;
    MainMenu: TMainMenu;
    miFile: TMenuItem;
    miFileSample1: TMenuItem;
    miFileSample2: TMenuItem;
    miFileSep01: TMenuItem;
    miFileOpen: TMenuItem;
    miFileSave: TMenuItem;
    miRender: TMenuItem;
    miRenderVSync: TMenuItem;
    miRenderSep01: TMenuItem;
    miRenderMsaa1: TMenuItem;
    miRenderMsaa2: TMenuItem;
    miRenderMsaa4: TMenuItem;
    miRenderMsaa8: TMenuItem;
    miOther: TMenuItem;
    miOtherDebugDevice: TMenuItem;
    miOtherDebugReport: TMenuItem;
    miQuit: TMenuItem;
    PopupMenu: TPopupMenu;
    miPopupVSync: TMenuItem;
    miPopupSep01: TMenuItem;
    miPopupMsaa1: TMenuItem;
    miPopupMsaa2: TMenuItem;
    miPopupMsaa4: TMenuItem;
    miPopupMsaa8: TMenuItem;
    OpenDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    StatusBar: TStatusBar;
    pnShaderCode: TPanel;
    lblShaderCode: TLabel;
    txtShaderCode: TMemo;
    lblShadersErrors: TLabel;
    txtShaderErrors: TMemo;
    btnShaderApply: TButton;
    actProgramAboutMsgbox: TAction;
    actProgramAboutForm: TAction;
    miOtherSep01: TMenuItem;
    miOtherAboutMsgbox: TMenuItem;
    miOtherAboutForm: TMenuItem;
    actFileCompile: TAction;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure OnApplicationIdle(Sender: TObject; var Done: Boolean);
    procedure actFileSample1Execute(Sender: TObject);
    procedure actFileSample2Execute(Sender: TObject);
    procedure actFileOpenExecute(Sender: TObject);
    procedure actFileSaveExecute(Sender: TObject);
    procedure actFileCompileExecute(Sender: TObject);
    procedure actRenderVSyncExecute(Sender: TObject);
    procedure actRenderMsaa1Execute(Sender: TObject);
    procedure actRenderMsaa2Execute(Sender: TObject);
    procedure actRenderMsaa4Execute(Sender: TObject);
    procedure actRenderMsaa8Execute(Sender: TObject);
    procedure actOtherDebugDeviceExecute(Sender: TObject);
    procedure actOtherDebugReportExecute(Sender: TObject);
    procedure actProgramAboutMsgboxExecute(Sender: TObject);
    procedure actProgramAboutFormExecute(Sender: TObject);
    procedure actProgramQuitExecute(Sender: TObject);
  private
    bInitComplete: Boolean;

    dtFrames: TDateTime;
    nFrames: Int64;
    nLastFPS: Double;

    dwTicksOfLastRender: UINT;

    nSelectedMsaa: UINT;

    pCompiledVertexShader: ID3DBlob;
    pCompiledPixelShader: ID3DBlob;

    pDXGIfactory: IDXGIFactory;
    pDXGIoutput: IDXGIOutput;

    pD3Ddevice: ID3D11Device;
    pD3Dcontext: ID3D11DeviceContext;

    pD3Ddebug: ID3D11Debug;

    pSwapChain: IDXGISwapChain;
    pRenderTargetView: ID3D11RenderTargetView;

    pRasterizerState: ID3D11RasterizerState;
    pInputLayout: ID3D11InputLayout;
    pVertexBuffer: ID3D11Buffer;
    pConstantBuffer: ID3D11Buffer;
    pVertexShader: ID3D11VertexShader;
    pPixelShader: ID3D11PixelShader;

    procedure InitShaders(const sCode: AnsiString; out pVS, pPS: ID3DBlob);
    procedure InitDirect3D();
    procedure FinalizeDirect3D();

    procedure ProcessShaderCompilationMessages(var pErrorMsgs: ID3DBlob; hr, hr2: HRESULT);

    procedure SetDebugName(const pObject: ID3D11DeviceChild; const sName: AnsiString);
  protected
    procedure CreateParams(var params: TCreateParams);  override;
    procedure WndProc(var msg: TMessage);  override;
  end;

var
  FormMain: TFormMain;

IMPLEMENTATION

{$R *.dfm}

uses
  Math, DateUtils, uFormAbout;

type
  TVertexData = record
    x: _FLOAT;
    y: _FLOAT;
    z: _FLOAT;
    w: _FLOAT;
    clr: D3DCOLORVALUE;
  end;

  TConstantBufferData = record
    matView: D3DXMATRIX;
    matProjection: D3DXMATRIX;
    matWorld: D3DXMATRIX;
    matResult: D3DXMATRIX;
    dwTimeInterval: UINT;
    dwGetTickCount: UINT;
    dwUnused: array[2..15] of UINT;
  end;

const
  input_layout: array [0..1] of D3D11_INPUT_ELEMENT_DESC =
  (
    (SemanticName: 'POSITION'; SemanticIndex: 0; Format: DXGI_FORMAT_R32G32B32A32_FLOAT;
     InputSlot: 0; AlignedByteOffset: 0;
     InputSlotClass: D3D11_INPUT_PER_VERTEX_DATA; InstanceDataStepRate: 0),
    (SemanticName: 'COLOR'; SemanticIndex: 0; Format: DXGI_FORMAT_R32G32B32A32_FLOAT;
     InputSlot: 0; AlignedByteOffset: 0 + (SizeOf(_FLOAT) * 4);
     InputSlotClass: D3D11_INPUT_PER_VERTEX_DATA; InstanceDataStepRate: 0)
  );

  vertices: array[0..2] of TVertexData =
  (
    (x:  0.00; y:  1.00; z: 0.0; w: 1.0; clr: (r: 0.75; g: 0.75; b: 0.25; a: 1.0)),
    (x:  0.75; y: -1.00; z: 0.0; w: 1.0; clr: (r: 0.75; g: 0.25; b: 0.75; a: 1.0)),
    (x: -0.75; y: -1.00; z: 0.0; w: 1.0; clr: (r: 0.25; g: 0.75; b: 0.75; a: 1.0))
  );

  strides: UINT = SizeOf(vertices[Low(vertices)]);
  offsets: UINT = 0;

  sShaderCode_Sample_1: AnsiString =
    '// не изменяйте это определение' + sLineBreak +
    'cbuffer cbConst : register ( b0 )' + sLineBreak +
    '{' + sLineBreak +
    '  float4x4 matView;' + sLineBreak +
    '  float4x4 matProjection;' + sLineBreak +
    '  float4x4 matWorld;' + sLineBreak +
    '  float4x4 matResult;' + sLineBreak +
    '  uint dwTimeInterval;' + sLineBreak +
    '  uint dwGetTickCount;' + sLineBreak +
    '};' + sLineBreak +
    '' + sLineBreak +
    'struct VS_OUTPUT' + sLineBreak +
    '{' + sLineBreak +
    '  float4 pos : SV_POSITION;' + sLineBreak +
    '  float4 clr : COLOR0;' + sLineBreak +
    '};' + sLineBreak +
    '' + sLineBreak +
    '// не изменяйте имя функции (VS)' + sLineBreak +
    'VS_OUTPUT VS ( float4 Pos : POSITION, float4 Clr : COLOR )' + sLineBreak +
    '{' + sLineBreak +
    '  VS_OUTPUT output;' + sLineBreak +
    '  ' + sLineBreak +
    '  output.pos = mul ( Pos, matResult );' + sLineBreak +
    '  output.clr = Clr;' + sLineBreak +
    '  ' + sLineBreak +
    '  return output;' + sLineBreak +
    '}' + sLineBreak +
    '' + sLineBreak +
    '// не изменяйте имя функции (PS)' + sLineBreak +
    'float4 PS ( VS_OUTPUT input ) : SV_Target' + sLineBreak +
    '{' + sLineBreak +
    '  return input.clr;' + sLineBreak +
    '}' + sLineBreak +
    '';

  sShaderCode_Sample_2: AnsiString =
    '// не изменяйте это определение' + sLineBreak +
    'cbuffer cbConst : register ( b0 )' + sLineBreak +
    '{' + sLineBreak +
    '  float4x4 matView;' + sLineBreak +
    '  float4x4 matProjection;' + sLineBreak +
    '  float4x4 matWorld;' + sLineBreak +
    '  float4x4 matResult;' + sLineBreak +
    '  uint dwTimeInterval;' + sLineBreak +
    '  uint dwGetTickCount;' + sLineBreak +
    '};' + sLineBreak +
    '' + sLineBreak +
    'struct VS_OUTPUT' + sLineBreak +
    '{' + sLineBreak +
    '  float4 pos : SV_POSITION;' + sLineBreak +
    '  float4 clr : COLOR0;' + sLineBreak +
    '};' + sLineBreak +
    '' + sLineBreak +
    '// не изменяйте имя функции (VS)' + sLineBreak +
    'VS_OUTPUT VS ( float4 Pos : POSITION, float4 Clr : COLOR, uint vId : SV_VertexID )' + sLineBreak +
    '{' + sLineBreak +
    '  VS_OUTPUT output;' + sLineBreak +
    '  float tmp1;' + sLineBreak +
    '  float tmp2;' + sLineBreak +
    '  float tmp3;' + sLineBreak +
    '  float tmp4;' + sLineBreak +
    '  ' + sLineBreak +
    '  tmp1 = ( sin ( ( dwGetTickCount % 4000 ) / 4000.0 * radians(180) ) );' + sLineBreak +
    '  tmp2 = sin ( ( dwGetTickCount % 5000 ) / 5000.0 * radians(360) );' + sLineBreak +
    '  tmp3 = cos ( ( dwGetTickCount % 5000 ) / 5000.0 * radians(360) );' + sLineBreak +
    '  tmp4 = ( (vId + 1) * sin ( ( dwGetTickCount % 2000 ) / 2000.0 * radians(180) ) );' + sLineBreak +
    '  ' + sLineBreak +
    '  output.pos = float4 ( Pos[0], Pos[1] + 1.0 * tmp1, Pos[2], Pos[3] );' + sLineBreak +
    '  output.pos = float4 ( output.pos[0] * tmp3 + output.pos[2] * tmp2, output.pos[1], output.pos[0] * (-tmp2) + output.pos[2] * tmp3, output.pos[3] );' + sLineBreak +
    '  output.pos = mul ( output.pos, matResult );' + sLineBreak +
    '  output.clr = float4 ( Clr[0] - 0.2 * tmp4, Clr[1] - 0.2 * tmp4, Clr[2] - 0.2 * tmp4, Clr[3] );' + sLineBreak +
    '  ' + sLineBreak +
    '  return output;' + sLineBreak +
    '}' + sLineBreak +
    '' + sLineBreak +
    '// не изменяйте имя функции (PS)' + sLineBreak +
    'float4 PS ( VS_OUTPUT input ) : SV_Target' + sLineBreak +
    '{' + sLineBreak +
    '  return input.clr;' + sLineBreak +
    '}' + sLineBreak +
    '';

{$IFDEF FPC}
function IsDebuggerPresent(): BOOL;
  external 'kernel32.dll' name 'IsDebuggerPresent';
{$ENDIF}

function Vector3Normalize(V: D3DXVECTOR): D3DXVECTOR;
var
  f: _FLOAT;
begin
  f := sqrt(sqr(V.x) + sqr(V.y) + sqr(V.z));
  Result.x := V.x / f;
  Result.y := V.y / f;
  Result.z := V.z / f;
  Result.w := V.w / f;
end;

function Vector4Multiply(V1, V2: D3DXVECTOR): D3DXVECTOR;
begin
  Result.x := V1.x * V2.x;
  Result.y := V1.y * V2.y;
  Result.z := V1.z * V2.z;
  Result.w := V1.w * V2.w;
end;

function Vector3Cross(V1, V2: D3DXVECTOR): D3DXVECTOR;
begin
  Result.x := (V1.v[1] * V2.v[2]) - (V1.v[2] * V2.v[1]);
  Result.y := (V1.v[2] * V2.v[0]) - (V1.v[0] * V2.v[2]);
  Result.z := (V1.v[0] * V2.v[1]) - (V1.v[1] * V2.v[0]);
  Result.w := 0.0;
end;

function Vector3Dot(V1, V2: D3DXVECTOR): D3DXVECTOR;
var
  f: _FLOAT;
begin
  f := ( V1.x * V2.x ) + ( V1.y * V2.y ) + ( V1.z * V2.z );
  Result.x := f;
  Result.y := f;
  Result.z := f;
  Result.w := f;
end;

function Vector4Dot(V1, V2: D3DXVECTOR): D3DXVECTOR;
var
  f: _FLOAT;
begin
  f := ( V1.x * V2.x ) + ( V1.y * V2.y ) + ( V1.z * V2.z ) + ( V1.w * V2.w );
  Result.x := f;
  Result.y := f;
  Result.z := f;
  Result.w := f;
end;

function Vector4Transform(V: D3DXVECTOR; M: D3DXMATRIX): D3DXVECTOR;
begin
  Result.x := (M.m[0][0]*V.v[0])+(M.m[1][0]*V.v[1])+(M.m[2][0]*V.v[2])+(M.m[3][0]*V.v[3]);
  Result.y := (M.m[0][1]*V.v[0])+(M.m[1][1]*V.v[1])+(M.m[2][1]*V.v[2])+(M.m[3][1]*V.v[3]);
  Result.z := (M.m[0][2]*V.v[0])+(M.m[1][2]*V.v[1])+(M.m[2][2]*V.v[2])+(M.m[3][2]*V.v[3]);
  Result.w := (M.m[0][3]*V.v[0])+(M.m[1][3]*V.v[1])+(M.m[2][3]*V.v[2])+(M.m[3][3]*V.v[3]);
end;

function MatrixLookToLH(EyePosition, EyeDirection, UpDirection: D3DXVECTOR): D3DXMATRIX;
var
  NegEyePosition: D3DXVECTOR;
  D0, D1, D2: D3DXVECTOR;
  R0, R1, R2: D3DXVECTOR;
  M: D3DXMATRIX;
begin
  R2 := Vector3Normalize(EyeDirection);

  R0 := Vector3Cross(UpDirection, R2);
  R0 := Vector3Normalize(R0);

  R1 := Vector3Cross(R2, R0);

  NegEyePosition.x := -EyePosition.x;
  NegEyePosition.y := -EyePosition.y;
  NegEyePosition.z := -EyePosition.z;
  NegEyePosition.w := -EyePosition.w;

  D0 := Vector3Dot(R0, NegEyePosition);
  D1 := Vector3Dot(R1, NegEyePosition);
  D2 := Vector3Dot(R2, NegEyePosition);

  M.r[0] := D3D_Vector(R0.x, R0.y, R0.z, D0.w);
  M.r[1] := D3D_Vector(R1.x, R1.y, R1.z, D1.w);
  M.r[2] := D3D_Vector(R2.x, R2.y, R2.z, D2.w);
  M.r[3] := D3D_Vector(0, 0, 0, 1);

  Result := D3D_Matrix_Transpose(M);
end;

function MatrixPerspectiveFovLH(fovY, aspectRatio, nearZ, farZ: FLOAT): D3DXMATRIX;
var
  SinFov, CosFov: Extended;
  Height, Width: _FLOAT;
  FF: _FLOAT;
begin
  SinCos(0.5 * fovY, SinFov, CosFov);

  Height := CosFov / SinFov;
  Width := Height / aspectRatio;

  FF := FarZ / (FarZ - NearZ);

  Result.r[0] := D3D_Vector(Width, 0.0, 0.0, 0.0);
  Result.r[1] := D3D_Vector(0.0, Height, 0.0, 0.0);
  Result.r[2] := D3D_Vector(0.0, 0.0, FF, 1.0);
  Result.r[3] := D3D_Vector(0.0, 0.0, -FF * NearZ, 0.0);
end;

function MatrixMultiply(M1, M2: D3DXMATRIX): D3DXMATRIX;
var
  x, y, z, w: _FLOAT;
begin
  x := M1.m[0][0];
  y := M1.m[0][1];
  z := M1.m[0][2];
  w := M1.m[0][3];
  Result.m[0][0] := (M2.m[0][0]*x)+(M2.m[1][0]*y)+(M2.m[2][0]*z)+(M2.m[3][0]*w);
  Result.m[0][1] := (M2.m[0][1]*x)+(M2.m[1][1]*y)+(M2.m[2][1]*z)+(M2.m[3][1]*w);
  Result.m[0][2] := (M2.m[0][2]*x)+(M2.m[1][2]*y)+(M2.m[2][2]*z)+(M2.m[3][2]*w);
  Result.m[0][3] := (M2.m[0][3]*x)+(M2.m[1][3]*y)+(M2.m[2][3]*z)+(M2.m[3][3]*w);
  x := M1.m[1][0];
  y := M1.m[1][1];
  z := M1.m[1][2];
  w := M1.m[1][3];
  Result.m[1][0] := (M2.m[0][0]*x)+(M2.m[1][0]*y)+(M2.m[2][0]*z)+(M2.m[3][0]*w);
  Result.m[1][1] := (M2.m[0][1]*x)+(M2.m[1][1]*y)+(M2.m[2][1]*z)+(M2.m[3][1]*w);
  Result.m[1][2] := (M2.m[0][2]*x)+(M2.m[1][2]*y)+(M2.m[2][2]*z)+(M2.m[3][2]*w);
  Result.m[1][3] := (M2.m[0][3]*x)+(M2.m[1][3]*y)+(M2.m[2][3]*z)+(M2.m[3][3]*w);
  x := M1.m[2][0];
  y := M1.m[2][1];
  z := M1.m[2][2];
  w := M1.m[2][3];
  Result.m[2][0] := (M2.m[0][0]*x)+(M2.m[1][0]*y)+(M2.m[2][0]*z)+(M2.m[3][0]*w);
  Result.m[2][1] := (M2.m[0][1]*x)+(M2.m[1][1]*y)+(M2.m[2][1]*z)+(M2.m[3][1]*w);
  Result.m[2][2] := (M2.m[0][2]*x)+(M2.m[1][2]*y)+(M2.m[2][2]*z)+(M2.m[3][2]*w);
  Result.m[2][3] := (M2.m[0][3]*x)+(M2.m[1][3]*y)+(M2.m[2][3]*z)+(M2.m[3][3]*w);
  x := M1.m[3][0];
  y := M1.m[3][1];
  z := M1.m[3][2];
  w := M1.m[3][3];
  Result.m[3][0] := (M2.m[0][0]*x)+(M2.m[1][0]*y)+(M2.m[2][0]*z)+(M2.m[3][0]*w);
  Result.m[3][1] := (M2.m[0][1]*x)+(M2.m[1][1]*y)+(M2.m[2][1]*z)+(M2.m[3][1]*w);
  Result.m[3][2] := (M2.m[0][2]*x)+(M2.m[1][2]*y)+(M2.m[2][2]*z)+(M2.m[3][2]*w);
  Result.m[3][3] := (M2.m[0][3]*x)+(M2.m[1][3]*y)+(M2.m[2][3]*z)+(M2.m[3][3]*w);
end;

{ TFormMain }

procedure TFormMain.CreateParams(var params: TCreateParams);
begin
  inherited CreateParams(params);

  params.WindowClass.style := params.WindowClass.style or CS_HREDRAW or CS_VREDRAW;
  params.Style := params.Style or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;
end;

procedure TFormMain.WndProc(var msg: TMessage);
begin
  if ( msg.Msg = WM_ERASEBKGND ) and ( bInitComplete ) then
  begin
    msg.Result := 1;
    Exit;
  end;

  inherited WndProc(msg);
end;

procedure TFormMain.ProcessShaderCompilationMessages(var pErrorMsgs: ID3DBlob; hr, hr2: HRESULT);
var
  nSize: SIZE_T;
  pData: Pointer;
  sData: AnsiString;
begin
  if ( pErrorMsgs = nil ) then Exit;

  nSize := pErrorMsgs.GetBufferSize();
  pData := pErrorMsgs.GetBufferPointer();

  if ( nSize = 0 ) then
  begin
    pErrorMsgs := nil;
    Exit;
  end;

  SetLength(sData, nSize);
  CopyMemory(PAnsiChar(sData), pData, nSize);
  pErrorMsgs := nil;

  txtShaderErrors.Lines.Text := txtShaderErrors.Lines.Text + sLineBreak + string(sData);
  StatusBar.Panels[0].Text := 'Обнаружены ошибки при компиляции шейдера!';
 // Application.MessageBox(PWideChar(WideString(sData)), 'Сообщения от компилятора HLSL', MB_OK or MB_ICONEXCLAMATION);
end;

procedure TFormMain.SetDebugName(const pObject: ID3D11DeviceChild; const sName: AnsiString);
begin
  if ( pObject <> nil ) and ( Length(sName) > 0 ) then
    pObject.SetPrivateData(WKPDID_D3DDebugObjectName, Length(sName), PAnsiChar(sName))
end;

procedure TFormMain.InitShaders(const sCode: AnsiString; out pVS, pPS: ID3DBlob);
var
  hr, hr2: HRESULT;
  pErrorMsgs: ID3DBlob;
begin
  pVS := nil;
  pPS := nil;

  txtShaderErrors.Lines.Text := '';

  if ( Length(sCode) = 0 ) then Exit;

  StatusBar.Panels[0].Text := '';

  hr2 := S_OK;
  hr := D3DX11CompileFromMemory
        (
          PAnsiChar(sCode), Length(sCode),
          nil, nil, nil, 'VS', 'vs_4_0',
          D3DCOMPILE_ENABLE_STRICTNESS or D3DCOMPILE_WARNINGS_ARE_ERRORS, 0,
          nil, pVS, @pErrorMsgs, @hr2
        );
  ProcessShaderCompilationMessages(pErrorMsgs, hr, hr2);

  hr := D3DX11CompileFromMemory
        (
          PAnsiChar(sCode), Length(sCode),
          nil, nil, nil, 'PS', 'ps_4_0',
          D3DCOMPILE_ENABLE_STRICTNESS or D3DCOMPILE_WARNINGS_ARE_ERRORS, 0,
          nil, pPS, @pErrorMsgs, @hr2
        );
  ProcessShaderCompilationMessages(pErrorMsgs, hr, hr2);

  if ( pVS <> nil ) and ( pPS <> nil ) and
     ( Length(StatusBar.Panels[0].Text) = 0 ) then
    StatusBar.Panels[0].Text := 'Компиляция шейдеров выполнена успешно';
end;

procedure TFormMain.InitDirect3D();
var
  hr: HRESULT;
  nQualityTest: UINT;
  FeatureLevel: D3D11_FEATURE_LEVEL;
  FeatureLevelRet: D3D11_FEATURE_LEVEL;
  vpDesc: D3D11_VIEWPORT;
  pBackBuffer: ID3D11Texture2D;
  srData: D3D11_SUBRESOURCE_DATA;
  cbBuf: TConstantBufferData;
begin
  FinalizeDirect3D();

  hr := CreateDXGIFactory(IDXGIFactory, pDXGIfactory);
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  FeatureLevel := D3D11_FEATURE_LEVEL(0);
  FeatureLevelRet := D3D11_FEATURE_LEVEL(0);

  hr := D3D11CreateDevice
        (
          nil, D3D11_DRIVER_TYPE_HARDWARE, 0,
          IfThen(actOtherDebugDevice.Checked, D3D11_CREATE_DEVICE_DEBUG, 0),
          nil, 0, D3D11_SDK_VERSION,
          nil, @FeatureLevel, nil
        );
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  hr := D3D11CreateDeviceAndSwapChain
        (
          nil, D3D11_DRIVER_TYPE_HARDWARE, 0,
          IfThen(actOtherDebugDevice.Checked, D3D11_CREATE_DEVICE_DEBUG, 0),
          @FeatureLevel, 1, D3D11_SDK_VERSION,
          DXGI_SwapChainDesc
          (
            DXGI_ModeDesc
            (
              Self.ClientWidth, Self.ClientHeight,
              DXGI_Rational_(60, 1),
              DXGI_FORMAT_R8G8B8A8_UNORM,
              DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED,
              DXGI_MODE_SCALING_UNSPECIFIED
            ),
            DXGI_SampleDesc(nSelectedMsaa, 0),
            Self.Handle, TRUE, 1,
            DXGI_USAGE_RENDER_TARGET_OUTPUT,
            DXGI_SWAP_EFFECT_DISCARD,
            0
          ),
          @pSwapChain, @pD3Ddevice, @FeatureLevelRet, @pD3Dcontext
        );
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pD3Dcontext, 'TFormMain.pD3Dcontext');

  if ( actOtherDebugDevice.Checked ) then
  begin
    hr := pD3Ddevice.QueryInterface(ID3D11Debug, pD3Ddebug);
    if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));
  end;

  hr := pSwapChain.GetContainingOutput(pDXGIoutput);
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  hr := pDXGIfactory.MakeWindowAssociation(Self.Handle, DXGI_MWA_NO_WINDOW_CHANGES);
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  hr := pSwapChain.GetBuffer(0, ID3D11Texture2D, pBackBuffer);
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pBackBuffer, 'FormMain.pBackBuffer');

  hr := pD3DDevice.CreateRenderTargetView(pBackBuffer, nil, pRenderTargetView);
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pRenderTargetView, 'FormMain.pRenderTargetView');

  pD3Dcontext.OMSetRenderTargets(1, @pRenderTargetView, nil);

  vpDesc.Width := Self.ClientWidth;
  vpDesc.Height := Self.ClientHeight;
  vpDesc.MinDepth := 0.0;
  vpDesc.MaxDepth := 1.0;
  vpDesc.TopLeftX := 0;
  vpDesc.TopLeftY := 0;
  pD3DContext.RSSetViewports(1, @vpDesc);

  hr := pD3Ddevice.CreateRasterizerState
        (
          D3D11_RasterizerDesc
          (
            D3D11_FILL_SOLID, D3D11_CULL_NONE,
            FALSE, 0, 0, 0,
            FALSE, FALSE, TRUE, TRUE
          ),
          pRasterizerState
        );
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pRasterizerState, 'FormMain.pRasterizerState');

  pD3Dcontext.RSSetState(pRasterizerState);

  ZeroMemory(@cbBuf, SizeOf(cbBuf));
  cbBuf.dwTimeInterval := 0;
  cbBuf.dwGetTickCount := GetTickCount();

  srData.pSysMem := @cbBuf;
  srData.SysMemPitch := 0;
  srData.SysMemSlicePitch := 0;

  hr := pD3Ddevice.CreateBuffer
        (
          D3D11_BufferDesc
          (
            SizeOf(cbBuf),
            D3D11_BIND_CONSTANT_BUFFER,
            D3D11_USAGE_DYNAMIC,
            D3D11_CPU_ACCESS_WRITE,
            0, 0
          ),
          @srData,
          pConstantBuffer
        );
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pConstantBuffer, 'TFormMain.pConstantBuffer');

  hr := pD3DDevice.CreateVertexShader
        (
          pCompiledVertexShader.GetBufferPointer(),
          pCompiledVertexShader.GetBufferSize(),
          nil,
          pVertexShader
        );
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pVertexShader, 'TFormMain.pVertexShader');

  hr := pD3Ddevice.CreatePixelShader
        (
          pCompiledPixelShader.GetBufferPointer(),
          pCompiledPixelShader.GetBufferSize(),
          nil,
          pPixelShader
        );
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pPixelShader, 'TFormMain.pPixelShader');

  hr := pD3Ddevice.CreateInputLayout
        (
          @input_layout[Low(input_layout)], Length(input_layout),
          pCompiledVertexShader.GetBufferPointer(),
          pCompiledVertexShader.GetBufferSize(),
          pInputLayout
        );
  if ( Failed(hr) ) then EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pInputLayout, 'TFormMain.pInputLayout');

  srData.pSysMem := @vertices[Low(vertices)];
  srData.SysMemPitch := 0;
  srData.SysMemSlicePitch := 0;

  hr := pD3Ddevice.CreateBuffer
        (
          D3D11_BufferDesc
          (
            SizeOf(vertices[Low(vertices)]) * Length(vertices),
            D3D11_BIND_VERTEX_BUFFER,
            D3D11_USAGE_DEFAULT,
            0, 0, 0
          ),
          @srData,
          pVertexBuffer
        );
  if ( Failed(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  SetDebugName(pVertexBuffer, 'TFormMain.pVertexBuffer');

  nQualityTest := 0;
  hr := pD3Ddevice.CheckMultisampleQualityLevels(DXGI_FORMAT_R8G8B8A8_UNORM, 2, nQualityTest);
  actRenderMsaa2.Enabled := ( Succeeded(hr) ) and ( nQualityTest > 0 );

  nQualityTest := 0;
  hr := pD3Ddevice.CheckMultisampleQualityLevels(DXGI_FORMAT_R8G8B8A8_UNORM, 4, nQualityTest);
  actRenderMsaa4.Enabled := ( Succeeded(hr) ) and ( nQualityTest > 0 );

  nQualityTest := 0;
  hr := pD3Ddevice.CheckMultisampleQualityLevels(DXGI_FORMAT_R8G8B8A8_UNORM, 8, nQualityTest);
  actRenderMsaa8.Enabled := ( Succeeded(hr) ) and ( nQualityTest > 0 );

  bInitComplete := TRUE;
end;

procedure TFormMain.FinalizeDirect3D();
begin
  bInitComplete := FALSE;

  if ( pD3Dcontext <> nil ) then
    pD3Dcontext.ClearState();

  pPixelShader := nil;
  pVertexShader := nil;
  pConstantBuffer := nil;
  pVertexBuffer := nil;
  pInputLayout := nil;
  pRasterizerState := nil;
  pRenderTargetView := nil;
  pSwapChain := nil;
  pD3Ddebug := nil;
  pD3Dcontext := nil;
  pD3Ddevice := nil;
  pDXGIoutput := nil;
  pDXGIfactory := nil;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  bInitComplete := FALSE;

  try
    DoubleBuffered := FALSE;
    Application.OnIdle := OnApplicationIdle;

    dtFrames := Now();
    nFrames := 0;
    nLastFPS := 0;

    dwTicksOfLastRender := GetTickCount();

    nSelectedMsaa := 1;
    actRenderMsaa1.Checked := TRUE;
    txtShaderCode.Lines.Text := string(sShaderCode_Sample_1);

    InitShaders(sShaderCode_Sample_1, pCompiledVertexShader, pCompiledPixelShader);
    InitDirect3D();
  except
    if ( ExceptObject <> nil ) and ( ExceptObject is Exception )
      then Application.ShowException(Exception(ExceptObject))
      else Application.MessageBox('Неизвестная ошибка в процессе инициализации!', 'неудача', MB_OK or MB_ICONERROR);

    Application.Terminate();

    FinalizeDirect3D();
    Exit;
  end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FinalizeDirect3D();

  pCompiledVertexShader := nil;
  pCompiledPixelShader := nil;
end;

procedure TFormMain.FormResize(Sender: TObject);
var
  hr: HRESULT;
  swDesc: DXGI_SWAP_CHAIN_DESC;
  vpDesc: D3D11_VIEWPORT;
  pBackBuffer: ID3D11Texture2D;
begin
  StatusBar.Panels[0].Width := StatusBar.ClientWidth - 85;
  if ( not bInitComplete ) then Exit;

  bInitComplete := FALSE;

  pD3Dcontext.OMSetRenderTargets(0, nil, nil);
  pRenderTargetView := nil;

  ZeroMemory(@swDesc, SizeOf(swDesc));
  swDesc.BufferDesc.Format := DXGI_FORMAT_UNKNOWN;

  hr := pSwapChain.GetDesc(swDesc);
  if ( FAILED(hr) ) then raise EOSError.Create(SysErrorMessage(hr));

  if ( nSelectedMsaa = swDesc.SampleDesc.Count ) then
  begin
    hr := pSwapChain.ResizeBuffers
          (
            1,
            Self.ClientWidth, Self.ClientHeight,
            swDesc.BufferDesc.Format, 0
          );

    if ( Failed(hr) ) then
    begin
      StatusBar.Panels[0].Text := 'ошибка метода pSwapChain.ResizeBuffers(): ' + QuotedStr(SysErrorMessage(hr));
      Exit;
    end;
  end
  else begin
    pSwapChain := nil;

    hr := pDXGIfactory.CreateSwapChain
          (
            pD3DDevice,
            DXGI_SwapChainDesc
            (
              DXGI_ModeDesc
              (
                Self.ClientWidth, Self.ClientHeight,
                DXGI_Rational_(60, 1),
                DXGI_FORMAT_R8G8B8A8_UNORM,
                DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED,
                DXGI_MODE_SCALING_UNSPECIFIED
              ),
              DXGI_SampleDesc(nSelectedMsaa, 0),
              Self.Handle, TRUE, 1,
              DXGI_USAGE_RENDER_TARGET_OUTPUT,
              DXGI_SWAP_EFFECT_DISCARD,
              0
            ),
            pSwapChain
          );

    if ( Failed(hr) ) then
    begin
      StatusBar.Panels[0].Text := 'pSwapChain.ResizeBuffers(): ' + QuotedStr(SysErrorMessage(hr));
      Exit;
    end;

    hr := pDXGIfactory.MakeWindowAssociation(Self.Handle, DXGI_MWA_NO_WINDOW_CHANGES);

    if ( Failed(hr) ) then
      StatusBar.Panels[0].Text := 'pDXGIfactory.MakeWindowAssociation(): ' + QuotedStr(SysErrorMessage(hr));
  end;

  hr := pSwapChain.GetBuffer(0, ID3D11Texture2D, pBackBuffer);
  if ( Failed(hr) ) then
  begin
    StatusBar.Panels[0].Text := 'pSwapChain.GetBuffer(): ' + QuotedStr(SysErrorMessage(hr));
    Exit;
  end;

  hr := pD3Ddevice.CreateRenderTargetView(pBackBuffer, nil, pRenderTargetView);
  if ( Failed(hr) ) then
  begin
    StatusBar.Panels[0].Text := 'pD3DDevice.CreateRenderTargetView(): ' + QuotedStr(SysErrorMessage(hr));
    Exit;
  end;

  pD3Dcontext.OMSetRenderTargets(1, @pRenderTargetView, nil);

  vpDesc.Width := Self.ClientWidth;
  vpDesc.Height := Self.ClientHeight;
  vpDesc.MinDepth := 0.0;
  vpDesc.MaxDepth := 1.0;
  vpDesc.TopLeftX := 0;
  vpDesc.TopLeftY := 0;

  pD3Dcontext.RSSetViewports(1, @vpDesc);

  bInitComplete := TRUE;

  InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.FormPaint(Sender: TObject);
var
  hr: HRESULT;
  cbBuf: TConstantBufferData;
  dwMS: Int64;
  sTextFPS: string;
  msrData: D3D11_MAPPED_SUBRESOURCE;
begin
  if ( not bInitComplete ) then Exit;

  if ( actRenderVSync.Checked ) then
  begin
    hr := pDXGIoutput.WaitForVBlank();

    if ( Failed(hr) ) then
      StatusBar.Panels[0].Text := 'pDXGIoutput.WaitForVBlank(): ' + QuotedSTr(SysErrorMessage(hr));
  end;

  ZeroMemory(@cbBuf, SizeOf(cbBuf));

  cbBuf.matView := MatrixLookToLH
                   (
                     D3D_Vector (   0.0,  0.0, -5.0 ),
                     D3D_Vector ( -1.25,  0.0,  5.0 ),
                     D3D_Vector (   0.0,  1.0,  0.0 )
                   );
  cbBuf.matProjection := MatrixPerspectiveFovLH
                         (
                           1.0, 1.0, 1.0, 100.0
                         );
  cbBuf.matWorld := D3D_Matrix_Identity();

  cbBuf.matResult := MatrixMultiply
                     (
                       cbBuf.matWorld,
                       MatrixMultiply
                       (
                         cbBuf.matView,
                         cbBuf.matProjection
                       )
                     );

  cbBuf.matView := D3D_Matrix_Transpose(cbBuf.matView);
  cbBuf.matProjection := D3D_Matrix_Transpose(cbBuf.matProjection);
  cbBuf.matWorld := D3D_Matrix_Transpose(cbBuf.matWorld);
  cbBuf.matResult := D3D_Matrix_Transpose(cbBuf.matResult);

  cbBuf.dwGetTickCount := GetTickCount();
  cbBuf.dwTimeInterval := ( cbBuf.dwGetTickCount - dwTicksOfLastRender );

  dwTicksOfLastRender := cbBuf.dwGetTickCount;

  hr := pD3Dcontext.Map(pConstantBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, msrData);
  if ( Succeeded(hr) ) then
  try
    CopyMemory(msrData.pData, @cbBuf, SizeOf(cbBuf));
  finally
    pD3Dcontext.Unmap(pConstantBuffer, 0);
  end;

  if ( Failed(hr) ) then
    StatusBar.Panels[0].Text := 'pD3Dcontext.Map(): ' + QuotedStr(SysErrorMessage(hr));

  pD3Dcontext.ClearRenderTargetView(pRenderTargetView, D3D11_RGBA_FLOAT(0, 0, 0, 1.0));

    pD3Dcontext.RSSetState(pRasterizerState);
    pD3Dcontext.IASetInputLayout(pInputLayout);
    pD3Dcontext.IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    pD3Dcontext.IASetVertexBuffers(0, 1, @pVertexBuffer, @strides, @offsets);
    pD3Dcontext.IASetIndexBuffer(nil, DXGI_FORMAT_UNKNOWN, 0);
    pD3Dcontext.VSSetConstantBuffers(0, 1, @pConstantBuffer);
    pD3Dcontext.VSSetShader(pVertexShader, nil, 0);
    pD3Dcontext.PSSetConstantBuffers(0, 1, @pConstantBuffer);
    pD3Dcontext.PSSetShader(pPixelShader, nil, 0);

    pD3Dcontext.Draw(3, 0);

  hr := pSwapChain.Present(0, 0);

  if ( Failed(hr) ) then
    StatusBar.Panels[0].Text := 'SwapChain.Present(): ' + QuotedStr(SysErrorMessage(hr));

  nFrames := nFrames + 1;

  dwMS := abs(MilliSecondsBetween(dtFrames, Now()));
  if ( dwMS >= 1000 ) then
  begin
    nLastFPS := ( nFrames * 1000.0 / dwMS );
    dtFrames := Now();
    nFrames := 0;

    if ( nLastFPS > 0 ) then
    begin
      if ( nLastFPS >= 20 )
        then sTextFPS := IntToStr(Round(nLastFPS))
        else sTextFPS := FormatFloat('0.0#', nLastFPS);

      sTextFPS := sTextFPS + ' fps';
    end
    else
      sTextFPS := '- fps';

    StatusBar.Panels[1].Text := sTextFPS;
  end;
end;

procedure TFormMain.OnApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  if ( Application.Terminated ) or      // выполняется завершение работы
     ( Application.ModalLevel > 0 ) or  // открыты модальные окна
     ( Self.WindowState = wsMinimized ) then  // окно свернуто
  begin
    // перерисовка не нужна, завершаем цикл обработки OnIdle()
    Done := TRUE;
    Exit;
  end;

  // будем обрабатывать OnIdle() повторно
  Done := FALSE;

  // обеспечить сообщение WM_PAINT для последующей отрисовки
  if ( bInitComplete ) then
    InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.actFileSample1Execute(Sender: TObject);
begin
  txtShaderCode.Lines.Text := string(sShaderCode_Sample_1);
end;

procedure TFormMain.actFileSample2Execute(Sender: TObject);
begin
  txtShaderCode.Lines.Text := string(sShaderCode_Sample_2);
end;

procedure TFormMain.actFileOpenExecute(Sender: TObject);
begin
  if ( OpenDlg.Execute() ) then
    txtShaderCode.Lines.LoadFromFile(OpenDlg.FileName);
end;

procedure TFormMain.actFileSaveExecute(Sender: TObject);
begin
  if ( SaveDlg.Execute() ) then
    txtShaderCode.Lines.SaveToFile(SaveDlg.FileName);
end;

procedure TFormMain.actFileCompileExecute(Sender: TObject);
var
  sCode: AnsiString;
  pVS, pPS: ID3DBlob;
begin
  sCode := AnsiString(txtShaderCode.Lines.Text);

  if ( Length(sCode) = 0 ) then
  begin
    Application.MessageBox('Не задан исходный код шейдеров!', 'ошибка', MB_OK or MB_ICONERROR);
    Exit;
  end;

  InitShaders(sCode, pVS, pPS);

  if ( pVS <> nil ) and ( pPS <> nil ) then
  begin
    FinalizeDirect3D();

    pCompiledVertexShader := pVS;
    pCompiledPixelShader := pPS;

    InitDirect3D();
    InvalidateRect(Self.Handle, nil, FALSE);
  end;
end;

procedure TFormMain.actRenderVSyncExecute(Sender: TObject);
begin
  InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.actRenderMsaa1Execute(Sender: TObject);
begin
  nSelectedMsaa := 1;
  FinalizeDirect3D();

  InitDirect3D();
  InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.actRenderMsaa2Execute(Sender: TObject);
begin
  nSelectedMsaa := 2;
  FinalizeDirect3D();

  InitDirect3D();
  InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.actRenderMsaa4Execute(Sender: TObject);
begin
  nSelectedMsaa := 4;
  FinalizeDirect3D();

  InitDirect3D();
  InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.actRenderMsaa8Execute(Sender: TObject);
begin
  nSelectedMsaa := 8;
  FinalizeDirect3D();

  InitDirect3D();
  InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.actOtherDebugDeviceExecute(Sender: TObject);
begin
  FinalizeDirect3D();

  InitDirect3D();
  InvalidateRect(Self.Handle, nil, FALSE);
end;

procedure TFormMain.actOtherDebugReportExecute(Sender: TObject);
begin
  if ( not IsDebuggerPresent() ) then
  begin
    Application.MessageBox('Программа должна выполняться под отладчиком!', 'предупреждение', MB_OK or MB_ICONEXCLAMATION);
    Exit;
  end;

  if ( pD3Ddebug = nil ) then
  begin
    Application.MessageBox('Не найден отладочный интерфейс ID3D11Debug!', 'ошибка', MB_OK or MB_ICONERROR);
    Exit;
  end;

  pD3Ddebug.ReportLiveDeviceObjects(D3D11_RLDO_DETAIL);
end;

procedure TFormMain.actProgramAboutMsgboxExecute(Sender: TObject);
begin
  Application.MessageBox
  (
    PChar
    (
      'Демонстрационная программа  ( DirectX 11 )' + sLineBreak +
      '' + sLineBreak +
      'Тема:' + sLineBreak +
      '  - использование Direct3D вместе с VCL / LCL' + sLineBreak +
      '' + sLineBreak +
      'Задействованные DirectX - API :' + sLineBreak +
      '  - DXGI' + sLineBreak +
      '  - Direct3D' + sLineBreak +
      '  - D3Dcompiler ( HLSL )'
    ),
    'О программе',
    MB_OK or MB_ICONINFORMATION
  );
end;

procedure TFormMain.actProgramAboutFormExecute(Sender: TObject);
var
  pDialog: TFormAbout;
begin
  pDialog := TFormAbout.Create(Self);
  try
    pDialog.ShowModal();
  finally
    pDialog.Free();
  end;
end;

procedure TFormMain.actProgramQuitExecute(Sender: TObject);
begin
  Application.Terminate();
end;

INITIALIZATION
  Math.SetExceptionMask([exInvalidOp..exPrecision]);
END.
