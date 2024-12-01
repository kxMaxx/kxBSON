unit uMain;

interface

uses
    Winapi.Windows,
    Winapi.Messages,
    System.SysUtils,
    System.Variants,
    System.Classes,
    System.Math,
    System.Diagnostics,
    Vcl.Graphics,
    Vcl.Controls,
    Vcl.Forms,
    Vcl.Dialogs,
    Vcl.StdCtrls,
    Vcl.ExtCtrls,
    Vcl.ComCtrls,
    kxBSON;

type
    TMain=class(TForm)
        PTop: TPanel;
        PMemo: TPanel;
        Memo: TMemo;
        BNewRnd: TButton;
        StatusBar: TStatusBar;
        BWriteFile: TButton;
        BReadFile: TButton;
        BStreamCopy: TButton;
    BNewHandMade: TButton;
        procedure BNewRndClick(Sender: TObject);
        procedure BWriteFileClick(Sender: TObject);
        procedure BReadFileClick(Sender: TObject);
        procedure BStreamCopyClick(Sender: TObject);
    procedure BNewHandMadeClick(Sender: TObject);
    private
        FBSONDoc  : TBSONDocument;
        FStopWatch: TStopWatch;
        procedure BSONRandomItemsAdd(const aBase: TBSONItemList; const aItemCount: Integer);
        procedure UpdateMemo();
        procedure UpdateStatusBar;
    public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
    end;

var
    Main: TMain;

implementation
{$R *.dfm}

constructor TMain.Create(AOwner: TComponent);
begin
    inherited;
    Randomize();
    FBSONDoc:=TBSONDocument.Create();
end;

destructor TMain.Destroy;
begin
    FBSONDoc.Free();
    inherited;
end;

procedure TMain.UpdateMemo;
begin
    Memo.Clear;
    Memo.Lines.BeginUpdate;
//    FBSONDoc.ToStringsJSON(Memo.Lines, '    ');
    FBSONDoc.ToStringsSimple(Memo.Lines, '    ');
    Memo.Lines.EndUpdate;
end;

procedure TMain.UpdateStatusBar;
begin
    StatusBar.Panels[0].Text:=Format('RunTime: %dms', [FStopWatch.ElapsedMilliseconds]);
end;

procedure TMain.BNewRndClick(Sender: TObject);
begin
    FStopWatch:=TStopWatch.StartNew;
    FBSONDoc.Clear;
    BSONRandomItemsAdd(FBSONDoc.Values, 1000);
    FStopWatch.Stop;
    UpdateMemo();
    UpdateStatusBar();
end;

procedure TMain.BNewHandMadeClick(Sender: TObject);
var I1: PBSONItemArray;
begin
    FStopWatch:=TStopWatch.StartNew;

    FBSONDoc.Clear;

    FBSONDoc.Values.Add( TBSONItemInt32.Create('1', -1) );
    FBSONDoc.Values.Add( TBSONItemInt32.Create('2', 0) );
    FBSONDoc.Values.Add( TBSONItemInt32.Create('3', 1) );
    FBSONDoc.Values.Add( TBSONItemInt32.Create('4', High(Int8)+1) );
    FBSONDoc.Values.Add( TBSONItemInt32.Create('5', High(Int16)+1) );
    FBSONDoc.Values.Add( TBSONItemInt32.Create('6', MAXInt) );

    FBSONDoc.Values.Add( TBSONItemDouble.Create('11', -1) );
    FBSONDoc.Values.Add( TBSONItemDouble.Create('12', 0) );
    FBSONDoc.Values.Add( TBSONItemDouble.Create('13', 1) );
    FBSONDoc.Values.Add( TBSONItemDouble.Create('14', Pi) );

    FBSONDoc.Values.Add( TBSONItemString.Create('String1', 'ABC') );
    FBSONDoc.Values.Add( TBSONItemString.Create('String2', '1') );
    FBSONDoc.Values.Add( TBSONItemString.Create('String3(empty)', '') );

    I1:=TBSONItemArray.Create('Arr1');
    FBSONDoc.Values.Add( I1 );
    I1.Values.Add( TBSONItemInt32.Create(''{not needed by arrays}, 1) );
    I1.Values.Add( TBSONItemInt64.Create(''{not needed by arrays}, 2) );
    I1.Values.Add( TBSONItemDouble.Create(''{not needed by arrays}, 3.123) );
    I1.Values.Add( TBSONItemDateTime.Create(''{not needed by arrays}, Now) );
    I1.Values.Add( TBSONItemInt32.Create(''{not needed by arrays}, 0) );      //converted to NULL item in the stream

    FStopWatch.Stop;
    UpdateMemo();
    UpdateStatusBar();
end;



procedure TMain.BWriteFileClick(Sender: TObject);
begin
    FStopWatch:=TStopWatch.StartNew;
    FBSONDoc.SaveToFile(ExtractFilePath(Application.ExeName)+'BSONDoc01.bson');
    FStopWatch.Stop;
    UpdateStatusBar();
end;

procedure TMain.BReadFileClick(Sender: TObject);
begin
    FStopWatch:=TStopWatch.StartNew;
    FBSONDoc.LoadFromFile(ExtractFilePath(Application.ExeName)+'BSONDoc01.bson');
    FStopWatch.Stop;
    UpdateMemo();
    UpdateStatusBar();
end;


procedure TMain.BStreamCopyClick(Sender: TObject);
var MStream: TMemoryStream;
begin
    MStream:=TMemoryStream.Create();
    try
        FStopWatch:=TStopWatch.StartNew;

        // Write to memory stream
        FBSONDoc.WriteStream(MStream);

        // Clear the BSON-Doc
        FBSONDoc.Clear;

        // Read back from memory stream
        MStream.Seek(0, soBeginning);
        FBSONDoc.ReadStream(MStream);

        FStopWatch.Stop;
    finally
        MStream.Free();
        UpdateMemo();
        UpdateStatusBar();
    end;
end;

procedure TMain.BSONRandomItemsAdd(const aBase: TBSONItemList; const aItemCount: Integer);
const
    cItemName='Item';
var i         : Integer;
    PItem     : PBSONItem;
    PItemDoc  : PBSONItemDoc;
    PItemArray: PBSONItemArray;

    DataObjID : TBSONObjectID;
    DataDec128: TBSONDecimal128;
begin
    // Fill FBSONDoc with random data
    for i:=1 to aItemCount do begin
        PItem:=nil;
        case Random(17) of
        0: PItem:=TBSONItemDouble.Create(cItemName+IntToStr(i), Random*10000);
        1: PItem:=TBSONItemString.Create(cItemName+IntToStr(i), 'Text'+IntToStr(i));
        2: begin
                PItemDoc:=TBSONItemDoc.Create(cItemName+IntToStr(i));
                BSONRandomItemsAdd(PItemDoc.Values, Min(aItemCount div 2, 20)); // add some sub items
                PItem:=PItemDoc;
            end;
        3: begin
                PItemArray:=TBSONItemArray.Create(cItemName+IntToStr(i));
                BSONRandomItemsAdd(PItemArray.Values, Min(aItemCount div 2, 20)); // add some sub items
                PItem:=PItemArray;
            end;
        4: PItem:=TBSONItemBinary.Create(cItemName+IntToStr(i));
        5: PItem:=TBSONItemObjectID.Create(cItemName+IntToStr(i), DataObjID);
        6: PItem:=TBSONItemBoolean.Create(cItemName+IntToStr(i), true);
        7: PItem:=TBSONItemDateTime.Create(cItemName+IntToStr(i), Now);
        8: PItem:=TBSONItemNull.Create(cItemName+IntToStr(i));
        9: PItem:=TBSONItemRegEx.Create(cItemName+IntToStr(i), 'Pattern'+IntToStr(i), 'Options'+IntToStr(i));
        10: PItem:=TBSONItemJS.Create(cItemName+IntToStr(i), 'js-txt');
        11: PItem:=TBSONItemInt32.Create(cItemName+IntToStr(i), Random(MaxInt));
        12: PItem:=TBSONItemUInt64.Create(cItemName+IntToStr(i), Random(MaxInt));
        13: PItem:=TBSONItemInt64.Create(cItemName+IntToStr(i), Random(MaxInt));
        14: PItem:=TBSONItemDecimal128.Create(cItemName+IntToStr(i), DataDec128);
        15: PItem:=TBSONItemMinKey.Create(cItemName+IntToStr(i));
        16: PItem:=TBSONItemMaxKey.Create(cItemName+IntToStr(i));
        end;
        if (PItem<>nil) then begin
            aBase.Add(PItem);
        end;
    end;
end;

end.
