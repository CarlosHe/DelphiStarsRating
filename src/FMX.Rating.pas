unit FMX.Rating;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, System.Math, System.Math.Vectors, FMX.Types, FMX.Controls, FMX.Graphics;

type
  TOnRatingChange = procedure(Sender: TObject; AValue: Double) of object;

  TRatingColors = class(TPersistent)
  private
    FBackground: TBrush;
    FStroke: TStrokeBrush;
    FStarColor: TBrush;
    FOnChanged: TNotifyEvent;
    procedure SetBackground(const Value: TBrush);
    procedure SetStroke(const Value: TStrokeBrush);
    procedure SetStarColor(const Value: TBrush);
    procedure SetOnChanged(const Value: TNotifyEvent);
    { private declarations }
  protected
    { protected declarations }
    procedure DoChanged(Sender: TObject);
  public
    { public declarations }
    constructor Create; virtual;
    destructor Destroy; override;
  published
    { published declarations }
    property Background: TBrush read FBackground write SetBackground;
    property Stroke: TStrokeBrush read FStroke write SetStroke;
    property StarColor: TBrush read FStarColor write SetStarColor;
    property OnChanged: TNotifyEvent read FOnChanged write SetOnChanged;
  end;

  TRating = class(TControl)
  private
    FStarCount: Integer;
    FStarDistance: Double;
    FStarScale: Double;
    FMouseCapturing: Boolean;
    FSteps: Double;
    FOnRatingChange: TOnRatingChange;
    FColors: TRatingColors;
    FRating: Double;
    FStarsPathData: TPathData;
    procedure SetStarCount(const Value: Integer);
    procedure SetStarDistance(const Value: Double);
    procedure SetStarScale(const Value: Double);
    procedure SetSteps(const Value: Double);
    procedure SetOnRatingChange(const Value: TOnRatingChange);
    procedure SetColors(const Value: TRatingColors);
    procedure SetRating(const Value: Double);
    { Private declarations }
  protected
    { Protected declarations }
    procedure ColorsChanged(Sender: TObject);
    procedure CreateStars;
    procedure Paint; override;
    function CalcWidth: Double;
    function CalcHeight: Double;
    procedure CalcRatingFromMouse(X: Single);
    procedure DoStarChanged;
    procedure DoRatingChanged;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Align;
    property Anchors;
    property ClipChildren;
    property ClipParent;
    property Cursor;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Locked;
    property Height;
    property HitTest default False;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TouchTargetExpansion;
    property Visible;
    property Width;
    property TabOrder;
    property TabStop;
    { Events }
    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnResized;
    { Drag and Drop events }
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    { Mouse events }
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property StarCount: Integer read FStarCount write SetStarCount default 5;
    property StarDistance: Double read FStarDistance write SetStarDistance;
    property StarScale: Double read FStarScale write SetStarScale;
    property Steps: Double read FSteps write SetSteps;
    property Rating: Double read FRating write SetRating;
    property OnRatingChange: TOnRatingChange read FOnRatingChange write SetOnRatingChange;
    property Colors: TRatingColors read FColors write SetColors;
  end;

procedure Register;

const
  StarData =
    'M 561.735,32.327 L 689.890,303.844 L 976.452,347.384 C 1021.944,354.296 1040.108,412.75'+
    '1 1007.190,446.302 L 799.832,657.649 L 848.783,956.075 C 856.553,1003.450 808.998,1039.'+
    '577 768.309,1017.210 L 512.000,876.312 L 255.691,1017.210 C 215.002,1039.577 167.447,10'+
    '03.450 175.217,956.075 L 224.168,657.649 L 16.810,446.302 C -16.108,412.751 2.056,354.2'+
    '96 47.548,347.384 L 334.110,303.844 L 462.265,32.327 C 482.609,-10.776 541.391,-10.776 '+
    '561.735,32.327 Z';

//  'M 767.386,445.845 C 772.612,458.831 769.869,473.666 760.347,483.925 L 662.111,593.363 L' +
//    ' 689.630,725.521 C 694.406,744.727 682.707,764.169 663.501,768.945 C 660.847,769.605 65' +
//    '8.126,769.959 655.391,770.000 C 649.202,770.000 643.125,768.343 637.792,765.200 L 513.9' +
//    '58,697.681 L 389.804,765.200 C 384.661,768.202 378.799,769.751 372.844,769.680 C 353.35' +
//    '5,769.901 337.377,754.280 337.156,734.790 C 337.120,731.664 337.500,728.547 338.286,725' +
//    '.521 L 365.805,593.363 L 267.569,483.925 C 253.931,468.970 254.999,445.790 269.953,432.' +
//    '152 C 275.677,426.931 282.908,423.659 290.608,422.806 L 417.962,411.606 L 481.959,278.1' +
//    '68 C 490.418,260.495 511.602,253.026 529.274,261.485 C 536.575,264.980 542.462,270.866 ' +
//    '545.956,278.168 L 609.954,411.606 L 737.308,422.806 C 750.909,424.116 762.578,433.054 7' +
//    '67.386,445.845 Z';

implementation

procedure Register;
begin
  RegisterComponents('Material Design', [TRating]);
end;

{ TRating }

function TRating.CalcHeight: Double;
begin
  Result := (32 * FStarScale);
end;

procedure TRating.CalcRatingFromMouse(X: Single);
var
  StarWidth: Double;
  StarTrunc: Integer;
  DistanceCount: Double;
  TempRating: Double;
  PosX: Single;
begin
  StarWidth := (32 * FStarScale);
  PosX:= X;
  if FColors.Stroke.Kind <> TBrushKind.None then
   PosX:=PosX- (Self.Colors.Stroke.Thickness/2 *  FStarScale);

  StarTrunc := Trunc(PosX * 1 / (StarWidth + FStarDistance * FStarScale) ) ;

  DistanceCount := PosX - StarTrunc * StarWidth - StarTrunc * FStarDistance * FStarScale;

  if Trunc(StarTrunc + (DistanceCount / StarWidth)) - StarTrunc > 0 then
    TempRating := Trunc(StarTrunc + (DistanceCount / StarWidth))
  else
    TempRating := StarTrunc + (DistanceCount / StarWidth);

  Rating := TempRating;

  Repaint;
end;

function TRating.CalcWidth: Double;
begin
  Result := (32 * FStarScale * StarCount) + (StarDistance * FStarScale * (StarCount - 1));
end;

procedure TRating.ColorsChanged(Sender: TObject);
begin
  DoStarChanged;
  Repaint;
end;

constructor TRating.Create(AOwner: TComponent);
begin
  inherited;
  AutoCapture := True;
  FMouseCapturing := False;
  FStarScale := 1;
  FStarDistance := 5;
  FStarCount := 5;
  FRating := 5;
  FSteps:=0.01;
  FColors := TRatingColors.Create;
  FColors.OnChanged := ColorsChanged;
  FStarsPathData := TPathData.Create;
  DoStarChanged;
  CreateStars;

end;

procedure TRating.CreateStars;
var
  StarPathData: TPathData;
  I: Integer;
  CurrDistance: Double;
begin
  CurrDistance := (32 * FStarScale) + (StarDistance * FStarScale);

  StarPathData := TPathData.Create;
  StarPathData.Data := StarData;
  StarPathData.FitToRect(TRectF.Create(0, 0, 32 * FStarScale, 32 * FStarScale));

  FStarsPathData.Clear;
  try
    for I := 0 to StarCount - 1 do
    begin
      FStarsPathData.Data := FStarsPathData.Data + StarPathData.Data;
      StarPathData.Translate(CurrDistance, 0);
    end;
  finally
    StarPathData.Free;
  end;
end;

destructor TRating.Destroy;
begin
  FColors.Free;
  FStarsPathData.Free;
  inherited;
end;

procedure TRating.DoRatingChanged;
begin
  if Assigned(FOnRatingChange) then
    FOnRatingChange(Self, FRating);
end;

procedure TRating.DoStarChanged;
var
  TempWidth, TempHeight: Single;
begin
  TempWidth := CalcWidth;
  TempHeight := CalcHeight;
  if FColors.Stroke.Kind <> TBrushKind.None then
  begin
    TempWidth := TempWidth + FColors.Stroke.Thickness * FStarScale;
    TempHeight := TempHeight + FColors.Stroke.Thickness * FStarScale;
  end;
  Self.Width := TempWidth;
  Self.Height := TempHeight;
end;

procedure TRating.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FMouseCapturing := True;
end;

procedure TRating.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if not FMouseCapturing then
    exit;

  CalcRatingFromMouse(X);

end;

procedure TRating.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  StarWidth: Double;
  StarTrunc: Integer;
  DistanceCount: Double;
  TempRating: Double;
begin
  inherited;
  FMouseCapturing := False;
  CalcRatingFromMouse(X);
end;

procedure TRating.Paint;
var
  I: Integer;
  TempPathData: TPathData;
  TotalFill: Double;
  Save: TCanvasSaveState;
begin
  inherited;

  if (csDesigning in ComponentState) and not Locked then
    DrawDesignBorder;
  try

    if FRating > 0 then
      TotalFill := (32 * FStarScale) * (FRating) + (Ceil(FRating) - 1) * (FStarDistance * FStarScale)
    else
      TotalFill := 0;

    if FColors.Stroke.Kind <> TBrushKind.None then
      TotalFill := TotalFill + FColors.Stroke.Thickness / 2 * FStarScale;

    TempPathData := TPathData.Create;
    try
      TempPathData.Data := FStarsPathData.Data;
      if FColors.Stroke.Kind <> TBrushKind.None then
        TempPathData.Translate(FColors.Stroke.Thickness / 2 * FStarScale, FColors.Stroke.Thickness / 2 * FStarScale);
      Canvas.BeginScene;
      Canvas.Fill.Assign(FColors.Background);
      Canvas.Stroke.Assign(FColors.Stroke);
      Canvas.Stroke.Thickness := FColors.Stroke.Thickness * FStarScale;
      if not GlobalUseGPUCanvas then
        Canvas.DrawPath(TempPathData, Opacity);
      Canvas.FillPath(TempPathData, Opacity);
      Canvas.EndScene;

      Save := Canvas.SaveState;
      Canvas.IntersectClipRect(TRectF.Create(0, 0, TotalFill, Height));
      Canvas.Fill.Assign(FColors.StarColor);
      Canvas.FillPath(TempPathData, Opacity);
      Canvas.RestoreState(Save);
    finally
      TempPathData.Free
    end;

  finally

  end;

end;

procedure TRating.Resize;
begin
  inherited;
  DoStarChanged;
end;

procedure TRating.SetColors(const Value: TRatingColors);
begin
  FColors := Value;
end;

procedure TRating.SetOnRatingChange(const Value: TOnRatingChange);
begin
  FOnRatingChange := Value;
end;

procedure TRating.SetRating(const Value: Double);
var
  NewValue: Double;
  OldValue: Double;

begin
  OldValue := FRating;
 
  if ((Frac(Value) - (Trunc(Frac(Value) / FSteps) * FSteps)) > FSteps / 3) then
    NewValue := Trunc(Value) + Trunc(Frac(Value) / FSteps) * FSteps + FSteps
  else
    NewValue := Trunc(Value) + Trunc(Frac(Value) / FSteps) * FSteps;

  NewValue := RoundTo(NewValue, -2);

  if NewValue <= 0 then
    FRating := 0
  else if NewValue > FStarCount then
    FRating := FStarCount
  else
    FRating := NewValue;

  Repaint;

  if NewValue <> OldValue then
    DoRatingChanged;
end;

procedure TRating.SetStarCount(const Value: Integer);
begin
  FStarCount := Value;
  CreateStars;
  SetRating(FRating);
  DoStarChanged;
end;

procedure TRating.SetStarDistance(const Value: Double);
begin
  FStarDistance := Value;
  CreateStars;
  DoStarChanged;
end;

procedure TRating.SetStarScale(const Value: Double);
begin
  FStarScale := Value;
  CreateStars;
  DoStarChanged;
end;

procedure TRating.SetSteps(const Value: Double);
begin
  if Value > 1 then
    FSteps := 1
  else if Value <= 0 then
    FSteps := 0.01
  else
    FSteps := Value;
end;

{ TRatingColors }

constructor TRatingColors.Create;
begin
  FBackground := TBrush.Create(TBrushKind.Solid, $FFEEEEEE);
  FStarColor := TBrush.Create(TBrushKind.Solid, $FFFFC107);
  FStroke := TStrokeBrush.Create(TBrushKind.Solid, $FF858585);

  FStroke.OnChanged := DoChanged;
  FStarColor.OnChanged := DoChanged;
  FBackground.OnChanged := DoChanged;

end;

destructor TRatingColors.Destroy;
begin
  FBackground.Free;
  FStarColor.Free;
  FStroke.Free;
  inherited;
end;

procedure TRatingColors.DoChanged(Sender: TObject);
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TRatingColors.SetBackground(const Value: TBrush);
begin
  FBackground := Value;
end;

procedure TRatingColors.SetOnChanged(const Value: TNotifyEvent);
begin
  FOnChanged := Value;
end;

procedure TRatingColors.SetStarColor(const Value: TBrush);
begin
  FStarColor := Value;
end;

procedure TRatingColors.SetStroke(const Value: TStrokeBrush);
begin
  FStroke := Value;
end;

end.
