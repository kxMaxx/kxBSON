{================================================================================
  BSON: Binary-JSON
  Spec: bsonspec.org
  Compiler: Embarcadero Delphi
  Author: Michael Koch
  GitHub: kxMaxx/kxBSON
  License: MIT

  Copyright (c) 2020 Michael Koch

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Version: 1.0 | 12/2020
  - initial release
 ================================================================================}

unit kxBSON;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

interface

uses
    DateUtils,
    SysUtils,
    Classes;

type
    EBSONException=class(Exception);

    TBSONType = type Byte;

const
    // indicate the version of the BSON implementation
    BSON_Version = 1;

    // value types
    BSON_TYPE_EOF       = $00;
    BSON_TYPE_DOUBLE    = $01;  // alias FLOAT
    BSON_TYPE_STRING    = $02;
    BSON_TYPE_DOC       = $03;
    BSON_TYPE_ARRAY     = $04;
    BSON_TYPE_BINARY    = $05;
//  BSON_TYPE_UNDEFINED = $06;  // deprecated
    BSON_TYPE_OBJECTID  = $07;
    BSON_TYPE_BOOLEAN   = $08;
    BSON_TYPE_DATETIME  = $09;
    BSON_TYPE_NULL      = $0A;
    BSON_TYPE_REGEX     = $0B;
//  BSON_TYPE_DBPTR     = $0C;  // deprecated
    BSON_TYPE_JS        = $0D;
//  BSON_TYPE_SYMBOL    = $0E;  // deprecated
//  BSON_TYPE_JSSCOPE   = $0F;  // deprecated
    BSON_TYPE_INT32     = $10;
    BSON_TYPE_UINT64    = $11; // alias TIMESTAMP
    BSON_TYPE_INT64     = $12;
    BSON_TYPE_DECIMAL128= $13;
    BSON_TYPE_MINKEY    = $FF;
    BSON_TYPE_MAXKEY    = $7F;

    // binary subtype
    BSON_BINTYPE_FUNC  =$01;
    BSON_BINTYPE_BINARY=$02;
    BSON_BINTYPE_UUID  =$03;
    BSON_BINTYPE_MD5   =$05;
    BSON_BINTYPE_USER  =$80;

resourcestring
    Str_BSONValueDateTime='dd.mm.yyyy hh:nn:ss';

    Str_BSONExceptionValueType='No code implementation for the BSON-Type ';
    Str_BSONExceptionRead='stream read failed (EOF)';
    Str_BSONExceptionNull='stream read failed (null expected)';
    Str_BSONExceptionValueCast='Unable to cast type %d';

type
    TBSONObjectID=array [0..11] of byte;

    TBSONDecimal128=packed record
        Value: array [0..15] of byte; // 128Bit
    end;

    //General Pointer; can cast to individual BSONItem if match the ValueType
    PBSONItem=type Pointer;

    // Specific Pointer of BSONItem
    PBSONItemDouble=^TBSONItemDouble;
    PBSONItemString=^TBSONItemString;
    PBSONItemDoc=^TBSONItemDoc;
    PBSONItemArray=^TBSONItemArray;
    PBSONItemBinary=^TBSONItemBinary;
    PBSONItemObjectID=^TBSONItemObjectID;
    PBSONItemBoolean=^TBSONItemBoolean;
    PBSONItemDateTime=^TBSONItemDateTime;
    PBSONItemNull=^TBSONItemNull;
    PBSONItemRegEx=^TBSONItemRegEx;
    PBSONItemJS=^TBSONItemJS;
    PBSONItemInt32=^TBSONItemInt32;
    PBSONItemUInt64=^TBSONItemUInt64;
    PBSONItemInt64=^TBSONItemInt64;
    PBSONItemDecimal128=^TBSONItemDecimal128;
    PBSONItemMinKey=^TBSONItemMinKey;
    PBSONItemMaxKey=^TBSONItemMaxKey;

    //BSON item base record
    PBSONItemBase=^TBSONItemBase;
    TBSONItemBase=record
        Name: string;
        BSONType: TBSONType;
        class procedure ReadUTF8(const F: TStream; out aString: String; const aReadLen: Boolean); static;
        class procedure WriteUTF8(const F: TStream; const aString: String; const aWriteLen: Boolean); static;
        class function ReadStreamValue(const F: TStream): TBSONType; static;
        class procedure ReadStreamNull(const F: TStream); static;
        procedure ReadStreamName(const F: TStream);
        procedure WriteStreamName(const F: TStream);
        procedure WriteStream(const F: TStream);

        function ValueTypeToString: string;

        //implizite cast to specific pointer of BSONItem (or nil if not match)
        function PBSONDouble: PBSONItemDouble;        //BSON_DOUBLE
        function PBSONString: PBSONItemString;        //BSON_STRING
        function PBSONDoc: PBSONItemDoc;              //BSON_DOC
        function PBSONArray: PBSONItemArray;          //BSON_ARRAY
        function PBSONBinary: PBSONItemBinary;        //BSON_BINARY
        function PBSONObjectID: PBSONItemObjectID;    //BSON_OBJECTID
        function PBSONBoolean: PBSONItemBoolean;      //BSON_BOOLEAN
        function PBSONDateTime: PBSONItemDateTime;    //BSON_DATETIME
        function PBSONNull: PBSONItemNull;            //BSON_NULL
        function PBSONRegEx: PBSONItemRegEx;          //BSON_REGEX
        function PBSONJS: PBSONItemJS;                //BSON_JS
        function PBSONInt32: PBSONItemInt32;          //BSON_INT32
        function PBSONUInt64: PBSONItemUInt64;        //BSON_UINT64
        function PBSONInt64: PBSONItemInt64;          //BSON_INT64
        function PBSONDecimal128: PBSONItemDecimal128;//BSON_DECIMAL128
        function PBSONMinKey: PBSONItemMinKey;        //BSON_MINKEY
        function PBSONMaxKey: PBSONItemMaxKey;        //BSON_MAXKEY

        //standard value access (if possible or exception)
        function ToString: string;
        function ToDouble: Double;
        function ToSingle: Single;
        function ToInt: Integer;
        function ToUInt: Cardinal;
        function ToInt64: Int64;
        function ToUInt64: UInt64;
    end;

    TBSONItemList=record
    strict private
        function GetItem(const Index: Integer): PBSONItemBase;
    public
        Items : array of PBSONItem;
        Count : Integer;
        property Item[const Index: Integer]: PBSONItemBase read GetItem; default;
        function Capacity: Integer;
        procedure Grow();
        procedure Init();
        procedure Clear;
        procedure FreeItem(const aItem: PBSONItem);
        function IndexOf(const aItem: PBSONItem): Integer;
        procedure Add(const aItem: PBSONItem);
        procedure Del(const aItem: PBSONItem); overload;
        procedure Del(const aIndex: Integer); overload;
        procedure NameNCount();
        function ByName(const aName: string): PBSONItem; overload;
        function ByName(const aName: string; const aBSONType: TBSONType): PBSONItem; overload;
        procedure ToStringsJSON(const aString:TStrings; const aIndenting:string; const aLevel:Integer; const aOutName:Boolean);
        procedure ToStringsSimple(const aString:TStrings; const aIndenting:string; const aLevel:Integer);

        procedure ReadStream(const F: TStream);
        procedure WriteStream(const F: TStream);
    end;

    TBSONItemDouble=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: Double;
        class function Create(const aName: string; const aValue: Double): PBSONItemDouble; static;
        class procedure Free(const aItem: PBSONItemDouble); static;
        class function ReadStream(const F: TStream): PBSONItemDouble; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemString=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: string;
        class function Create(const aName: string; const aValue: string): PBSONItemString; static;
        class procedure Free(const aItem: PBSONItemString); static;
        class function ReadStream(const F: TStream): PBSONItemString; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemDoc=record
        Base: TBSONItemBase;
        Values: TBSONItemList; // SubItems
        class function Create(const aName: string): PBSONItemDoc; static;
        class procedure Free(const aItem: PBSONItemDoc); static;
        class function ReadStream(const F: TStream): PBSONItemDoc; static;
        procedure WriteStream(const F: TStream);
    end;

    TBSONItemArray=record
        Base: TBSONItemBase;   // Must be the first entry in record
        Values: TBSONItemList; // SubItems
        class function Create(const aName: string): PBSONItemArray; static;
        class procedure Free(const aItem: PBSONItemArray); static;
        class function ReadStream(const F: TStream): PBSONItemArray; static;
        procedure WriteStream(const F: TStream);
    end;

    TBSONItemBinary=record
        Base: TBSONItemBase; // Must be the first entry in record
        BinLen: Cardinal;
        BinSubType: byte;
        BinData: Pointer;
        OwnsData: Boolean; // true = FreeMem(BinData)
        class function Create(const aName: string): PBSONItemBinary; static;
        class procedure Free(const aItem: PBSONItemBinary); static;
        class function ReadStream(const F: TStream): PBSONItemBinary; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemObjectID=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: TBSONObjectID;
        class function Create(const aName: string; const aValue: TBSONObjectID): PBSONItemObjectID; static;
        class procedure Free(const aItem: PBSONItemObjectID); static;
        class function ReadStream(const F: TStream): PBSONItemObjectID; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemBoolean=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: Boolean;
        class function Create(const aName: string; const aValue: Boolean): PBSONItemBoolean; static;
        class procedure Free(const aItem: PBSONItemBoolean); static;
        class function ReadStream(const F: TStream): PBSONItemBoolean; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemDateTime=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: TDateTime;
        class function Create(const aName: string; const aValue: TDateTime): PBSONItemDateTime; static;
        class procedure Free(const aItem: PBSONItemDateTime); static;
        class function ReadStream(const F: TStream): PBSONItemDateTime; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemNull=record
        Base: TBSONItemBase; // Must be the first entry in record
        class function Create(const aName: string): PBSONItemNull; static;
        class procedure Free(const aItem: PBSONItemNull); static;
        class function ReadStream(const F: TStream): PBSONItemNull; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemRegEx=record
        Base: TBSONItemBase; // Must be the first entry in record
        ValuePattern: string;
        ValueOptions: string;
        class function Create(const aName: string; const aValuePattern, aValueOptions: string): PBSONItemRegEx; static;
        class procedure Free(const aItem: PBSONItemRegEx); static;
        class function ReadStream(const F: TStream): PBSONItemRegEx; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemJS=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: string;
        class function Create(const aName: string; const aValue: string): PBSONItemJS; static;
        class procedure Free(const aItem: PBSONItemJS); static;
        class function ReadStream(const F: TStream): PBSONItemJS; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemInt32=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: Integer;
        class function Create(const aName: string; const aValue: Integer): PBSONItemInt32; static;
        class procedure Free(const aItem: PBSONItemInt32); static;
        class function ReadStream(const F: TStream): PBSONItemInt32; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemUInt64=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: UInt64;
        class function Create(const aName: string; const aValue: UInt64): PBSONItemUInt64; static;
        class procedure Free(const aItem: PBSONItemUInt64); static;
        class function ReadStream(const F: TStream): PBSONItemUInt64; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemInt64=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: Int64;
        class function Create(const aName: string; const aValue: Int64): PBSONItemInt64; static;
        class procedure Free(const aItem: PBSONItemInt64); static;
        class function ReadStream(const F: TStream): PBSONItemInt64; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemDecimal128=record
        Base: TBSONItemBase; // Must be the first entry in record
        Value: TBSONDecimal128;
        class function Create(const aName: string; const aValue: TBSONDecimal128): PBSONItemDecimal128; static;
        class procedure Free(const aItem: PBSONItemDecimal128); static;
        class function ReadStream(const F: TStream): PBSONItemDecimal128; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemMinKey=record
        Base: TBSONItemBase; // Must be the first entry in record
        class function Create(const aName: string): PBSONItemMinKey; static;
        class procedure Free(const aItem: PBSONItemMinKey); static;
        class function ReadStream(const F: TStream): PBSONItemMinKey; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    TBSONItemMaxKey=record
        Base: TBSONItemBase; // Must be the first entry in record
        class function Create(const aName: string): PBSONItemMaxKey; static;
        class procedure Free(const aItem: PBSONItemMaxKey); static;
        class function ReadStream(const F: TStream): PBSONItemMaxKey; static;
        procedure WriteStream(const F: TStream);
        function ToString: string;
    end;

    ///Main-Class of an BSON-Document
    TBSONDocument=class(TObject)
    private
        FValues: TBSONItemList;
    public
        constructor Create; virtual;
        destructor Destroy; override;
        procedure Clear();

        property Values: TBSONItemList read FValues;

        procedure ReadStream(const F: TStream);
        procedure WriteStream(const F: TStream);

        procedure LoadFromFile(aFilename: string);
        procedure SaveToFile(aFilename: string);

        procedure ToStringsJSON(const aString:TStrings; const aIndenting:string=' ');
        procedure ToStringsSimple(const aString:TStrings; const aIndenting:string=' ');
    end;


implementation

const
    // Null (e.g. after string)
    cBSON_NULL: AnsiChar=#0;

    //JSON String output
    Str_BSONStringQuote='"';
    Str_BSONComma=',';
    Str_BSONTypeSeperator=' | ';
    Str_BSONValueSeperator=' : ';
    Str_BSONArraySeperatorO='[';
    Str_BSONArraySeperatorC=']';
    Str_BSONDocSeperatorO='{';
    Str_BSONDocSeperatorC='}';
    Str_BSONValueTrue='true';
    Str_BSONValueFalse='false';
    Str_BSONValueNULL='null';
    Str_BSONValueBinary='SubType:%d Len:%d Data:$%x';
    Str_BSONValueRegEx='pattern=%s options=%s';
    Str_BSONValueMinKey='minkey';
    Str_BSONValueMaxKey='maxkey';

var
    BSON_FormatSettingsFloat: TFormatSettings;

{$REGION 'TBSONDocument'}

constructor TBSONDocument.Create;
begin

end;

destructor TBSONDocument.Destroy;
begin
    Clear();
    inherited;
end;

procedure TBSONDocument.Clear;
begin
    FValues.Clear();
end;

procedure TBSONDocument.LoadFromFile(aFilename: string);
var
    F: TFileStream;
begin
    F:=TFileStream.Create(aFilename, fmOpenRead);
    try
        ReadStream(F);
    finally
        F.Free;
    end;
end;

procedure TBSONDocument.SaveToFile(aFilename: string);
var F: TFileStream;
begin
    F:=TFileStream.Create(aFilename, fmCreate);
    try
        WriteStream(F);
    finally
        F.Free;
    end;
end;

procedure TBSONDocument.ReadStream(const F: TStream);
begin
    FValues.ReadStream(F);
end;

procedure TBSONDocument.WriteStream(const F: TStream);
begin
    FValues.WriteStream(F);
end;

procedure TBSONDocument.ToStringsJSON(const aString:TStrings; const aIndenting:string);
begin
    aString.Add(Str_BSONDocSeperatorO);
    FValues.ToStringsJSON(aString, aIndenting, 1, true);
    aString.Add(Str_BSONDocSeperatorC);
end;

procedure TBSONDocument.ToStringsSimple(const aString:TStrings; const aIndenting:string);
begin
    aString.Add(Str_BSONDocSeperatorO);
    FValues.ToStringsSimple(aString, aIndenting, 1);
    aString.Add(Str_BSONDocSeperatorC);
end;


{$ENDREGION}

{$REGION 'TBSONItemBase'}

class procedure TBSONItemBase.ReadUTF8(const F: TStream; out aString: String; const aReadLen: Boolean);
var i, k, l: Integer;
    sUTF8  : UTF8String;
begin
    if (aReadLen) then begin
        F.read(l, sizeof(Integer));
        l:=l-1 { NULL };
        // Known len ...
        SetLength(sUTF8, l);
        if l > 1 then
            F.read(sUTF8[1], l);
        TBSONItemBase.ReadStreamNull(F);
    end else begin
        // Unknown len, parse until found NULL ...
        i:=0; // Index in elname
        k:=0; // Block a 16 Chars
        repeat
            inc(k);
            l:=k*16; // New length
            SetLength(sUTF8, l);
            repeat
                inc(i);
                F.read(sUTF8[i], 1);
            until (sUTF8[i]=cBSON_NULL)or(i>=l); // read until NULL or Length
        until (sUTF8[i]=cBSON_NULL);
        SetLength(sUTF8, i-1);
    end;
    aString:=UTF8ToString(sUTF8);
end;

class procedure TBSONItemBase.WriteUTF8(const F: TStream; const aString: String; const aWriteLen: Boolean);
var sUTF8: UTF8String;
    sLen : Integer;
begin
    sUTF8:=UTF8Encode(aString);
    sLen:=Length(sUTF8)+1 { NULL };
    if (aWriteLen) then
        F.write(sLen, sizeof(Integer));
    if sLen > 1 then
        F.write(sUTF8[1], sLen-1);
    F.write(cBSON_NULL, sizeof(cBSON_NULL));
end;


class procedure TBSONItemBase.ReadStreamNull(const F: TStream);
var iNull: TBSONType;
begin
    if F.read(iNull, sizeof(TBSONType))<>sizeof(TBSONType) then
        raise EBSONException.Create(Str_BSONExceptionRead);
    if (iNull<>0) then
        raise EBSONException.Create(Str_BSONExceptionNull);
end;

class function TBSONItemBase.ReadStreamValue(const F: TStream): TBSONType;
begin
    if F.read(result, sizeof(TBSONType))<>sizeof(TBSONType) then begin
        raise EBSONException.Create(Str_BSONExceptionRead);
    end;
end;

function TBSONItemBase.ValueTypeToString: string;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: result:='DOUBLE';
    BSON_TYPE_STRING: result:='STRING';
    BSON_TYPE_DOC: result:='DOC';
    BSON_TYPE_ARRAY: result:='ARRAY';
    BSON_TYPE_BINARY: result:='BINARY';
    BSON_TYPE_OBJECTID: result:='OBJECTID';
    BSON_TYPE_BOOLEAN: result:='BOOLEAN';
    BSON_TYPE_DATETIME: result:='DATETIME';
    BSON_TYPE_NULL: result:='NULL';
    BSON_TYPE_REGEX: result:='REGEX';
    BSON_TYPE_JS: result:='JS';
    BSON_TYPE_INT32: result:='INT32';
    BSON_TYPE_UINT64: result:='UINT32';
    BSON_TYPE_INT64: result:='INT64';
    BSON_TYPE_DECIMAL128: result:='DECIMAL128';
    BSON_TYPE_MINKEY: result:='MINKEY';
    BSON_TYPE_MAXKEY: result:='MAXKEY';
    else result:='UNKNOWN';
    end;
end;

function TBSONItemBase.ToString: string;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: result:=PBSONItemDouble(@self).ToString;
    BSON_TYPE_STRING: result:=PBSONItemString(@self).ToString;
//    BSON_TYPE_DOC: result:=PBSONItemDoc(@self).ToString;
//    BSON_TYPE_ARRAY: result:=PBSONItemArray(@self).ToString;
    BSON_TYPE_BINARY: result:=PBSONItemBinary(@self).ToString;
    BSON_TYPE_OBJECTID: result:=PBSONItemObjectID(@self).ToString;
    BSON_TYPE_BOOLEAN: result:=PBSONItemBoolean(@self).ToString;
    BSON_TYPE_DATETIME: result:=PBSONItemDateTime(@self).ToString;
    BSON_TYPE_NULL: result:=PBSONItemNull(@self).ToString;
    BSON_TYPE_REGEX: result:=PBSONItemRegEx(@self).ToString;
    BSON_TYPE_JS: result:=PBSONItemJS(@self).ToString;
    BSON_TYPE_INT32: result:=PBSONItemInt32(@self).ToString;
    BSON_TYPE_UINT64: result:=PBSONItemUInt64(@self).ToString;
    BSON_TYPE_INT64: result:=PBSONItemInt64(@self).ToString;
    BSON_TYPE_DECIMAL128: result:=PBSONItemDecimal128(@self).ToString;
    BSON_TYPE_MINKEY: result:=PBSONItemMinKey(@self).ToString;
    BSON_TYPE_MAXKEY: result:=PBSONItemMaxKey(@self).ToString;
    else
        raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
    end;
end;

function TBSONItemBase.ToDouble: Double;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: result:=PBSONItemDouble(@self).Value;
    BSON_TYPE_BOOLEAN: result:=Ord(PBSONItemBoolean(@self).Value);
    BSON_TYPE_DATETIME: result:=PBSONItemDateTime(@self).Value;
    BSON_TYPE_NULL: result:=0;
    BSON_TYPE_INT32: result:=PBSONItemInt32(@self).Value;
    BSON_TYPE_UINT64: result:=PBSONItemUInt64(@self).Value;
    BSON_TYPE_INT64: result:=PBSONItemInt64(@self).Value;
    else
        raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
    end;
end;

function TBSONItemBase.ToSingle: Single;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: result:=PBSONItemDouble(@self).Value;
    BSON_TYPE_BOOLEAN: result:=Ord(PBSONItemBoolean(@self).Value);
    BSON_TYPE_DATETIME: result:=PBSONItemDateTime(@self).Value;
    BSON_TYPE_NULL: result:=0;
    BSON_TYPE_INT32: result:=PBSONItemInt32(@self).Value;
    BSON_TYPE_UINT64: result:=PBSONItemUInt64(@self).Value;
    BSON_TYPE_INT64: result:=PBSONItemInt64(@self).Value;
    else
        raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
    end;
end;

function TBSONItemBase.ToInt: Integer;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: begin
        if (PBSONItemDouble(@self).Value<Low(Integer))or(PBSONItemDouble(@self).Value>MAXINT) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=Round(PBSONItemDouble(@self).Value);  //accepted rounding
    end;
    BSON_TYPE_BOOLEAN: result:=Ord(PBSONItemBoolean(@self).Value);
    BSON_TYPE_NULL: result:=0;
    BSON_TYPE_INT32: result:=PBSONItemInt32(@self).Value;
    BSON_TYPE_UINT64: begin
        if (PBSONItemUInt64(@self).Value>MAXINT) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemUInt64(@self).Value;
    end;
    BSON_TYPE_INT64: begin
        if (PBSONItemInt64(@self).Value<Low(Integer))or(PBSONItemInt64(@self).Value>MAXINT) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemInt64(@self).Value;
    end;
    else
        raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
    end;
end;

function TBSONItemBase.ToUInt: Cardinal;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: begin
        if (PBSONItemDouble(@self).Value<0)or(PBSONItemDouble(@self).Value>High(Cardinal)) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=Round(PBSONItemDouble(@self).Value);  //accepted rounding
    end;
    BSON_TYPE_BOOLEAN: result:=Ord(PBSONItemBoolean(@self).Value);
    BSON_TYPE_NULL: result:=0;
    BSON_TYPE_INT32: begin
        if (PBSONItemInt32(@self).Value<0) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemInt32(@self).Value;
    end;
    BSON_TYPE_UINT64: begin
        if (PBSONItemDouble(@self).Value>High(Cardinal)) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemUInt64(@self).Value;
    end;
    BSON_TYPE_INT64: begin
        if (PBSONItemInt64(@self).Value<0)or(PBSONItemDouble(@self).Value>High(Cardinal)) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemInt64(@self).Value;
    end;
    else
        raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
    end;
end;


function TBSONItemBase.ToInt64: Int64;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: begin
        if (PBSONItemDouble(@self).Value<Low(Int64))or(PBSONItemDouble(@self).Value>High(Int64)) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=Round(PBSONItemDouble(@self).Value);  //accepted rounding
    end;
    BSON_TYPE_BOOLEAN: result:=Ord(PBSONItemBoolean(@self).Value);
    BSON_TYPE_NULL: result:=0;
    BSON_TYPE_INT32: result:=PBSONItemInt32(@self).Value;
    BSON_TYPE_UINT64: begin
        if (PBSONItemUInt64(@self).Value>High(Int64)) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemUInt64(@self).Value;
    end;
    BSON_TYPE_INT64: begin
        result:=PBSONItemInt64(@self).Value;
    end;
    else
        raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
    end;
end;

function TBSONItemBase.ToUInt64: UInt64;
begin
    case BSONType of
    BSON_TYPE_DOUBLE: begin
        if (PBSONItemDouble(@self).Value<0)or(PBSONItemDouble(@self).Value>High(UInt64)) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=Round(PBSONItemDouble(@self).Value);  //accepted rounding
    end;
    BSON_TYPE_BOOLEAN: result:=Ord(PBSONItemBoolean(@self).Value);
    BSON_TYPE_NULL: result:=0;
    BSON_TYPE_INT32: begin
        if (PBSONItemInt32(@self).Value<0) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemInt32(@self).Value;
    end;
    BSON_TYPE_UINT64: begin
        result:=PBSONItemUInt64(@self).Value;
    end;
    BSON_TYPE_INT64: begin
        if (PBSONItemInt64(@self).Value<0) then raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
        result:=PBSONItemInt64(@self).Value;
    end;
    else
        raise EBSONException.CreateFmt(Str_BSONExceptionValueCast, [BSONType]);
    end;
end;

function TBSONItemBase.PBSONDouble: PBSONItemDouble;
begin
    if BSONType=BSON_TYPE_DOUBLE then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONString: PBSONItemString;
begin
    if BSONType=BSON_TYPE_STRING then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONDoc: PBSONItemDoc;
begin
    if BSONType=BSON_TYPE_DOC then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONArray: PBSONItemArray;
begin
    if BSONType=BSON_TYPE_ARRAY then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONBinary: PBSONItemBinary;
begin
    if BSONType=BSON_TYPE_BINARY then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONObjectID: PBSONItemObjectID;
begin
    if BSONType=BSON_TYPE_OBJECTID then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONBoolean: PBSONItemBoolean;
begin
    if BSONType=BSON_TYPE_BOOLEAN then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONDateTime: PBSONItemDateTime;
begin
    if BSONType=BSON_TYPE_DATETIME then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONNull: PBSONItemNull;
begin
    if BSONType=BSON_TYPE_NULL then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONRegEx: PBSONItemRegEx;
begin
    if BSONType=BSON_TYPE_REGEX then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONJS: PBSONItemJS;
begin
    if BSONType=BSON_TYPE_JS then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONInt32: PBSONItemInt32;
begin
    if BSONType=BSON_TYPE_INT32 then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONUInt64: PBSONItemUInt64;
begin
    if BSONType=BSON_TYPE_UINT64 then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONInt64: PBSONItemInt64;
begin
    if BSONType=BSON_TYPE_INT64 then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONDecimal128: PBSONItemDecimal128;
begin
    if BSONType=BSON_TYPE_DECIMAL128 then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONMinKey: PBSONItemMinKey;
begin
    if BSONType=BSON_TYPE_MINKEY then result:=@self
    else result:=nil;
end;

function TBSONItemBase.PBSONMaxKey: PBSONItemMaxKey;
begin
    if BSONType=BSON_TYPE_MAXKEY then result:=@self
    else result:=nil;
end;


procedure TBSONItemBase.ReadStreamName(const F: TStream);
begin
    ReadUTF8(F, Name, false);
end;

procedure TBSONItemBase.WriteStreamName(const F: TStream);
begin
    WriteUTF8(F, Name, false);
end;

procedure TBSONItemBase.WriteStream(const F: TStream);
begin
    F.write(BSONType, sizeof(TBSONType));
    WriteUTF8(F, Name, false);
end;

{$ENDREGION}

{$REGION 'TBSONItemDouble'}

class function TBSONItemDouble.Create(const aName: string; const aValue: Double): PBSONItemDouble;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DOUBLE;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemDouble.Free(const aItem: PBSONItemDouble);
begin
    Dispose(aItem);
end;

class function TBSONItemDouble.ReadStream(const F: TStream): PBSONItemDouble;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DOUBLE;
    result.Base.ReadStreamName(F);
    F.read(result.Value, sizeof(result.Value));
end;

procedure TBSONItemDouble.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(Value, sizeof(Value));
end;

function TBSONItemDouble.ToString: string;
begin
    result:=FloatToStr(Value, BSON_FormatSettingsFloat);
end;


{$ENDREGION}

{$REGION 'TBSONItemString'}


class function TBSONItemString.Create(const aName, aValue: string): PBSONItemString;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_STRING;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemString.Free(const aItem: PBSONItemString);
begin
    Dispose(aItem);
end;

class function TBSONItemString.ReadStream(const F: TStream): PBSONItemString;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_STRING;
    result.Base.ReadStreamName(F);
    TBSONItemBase.ReadUTF8(F, result.Value, true);
end;

procedure TBSONItemString.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    TBSONItemBase.WriteUTF8(F, Value, true);
end;

function TBSONItemString.ToString: string;
begin
    result:=Value;
end;

{$ENDREGION}

{$REGION 'TBSONItemDoc'}

class function TBSONItemDoc.Create(const aName: string): PBSONItemDoc;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DOC;
    result.Base.Name:=aName;
    result.Values.Init();
end;

class procedure TBSONItemDoc.Free(const aItem: PBSONItemDoc);
begin
    aItem.Values.Clear();
    Dispose(aItem);
end;

class function TBSONItemDoc.ReadStream(const F: TStream): PBSONItemDoc;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DOC;
    result.Base.ReadStreamName(F);
    result.Values.Init();
    result.Values.ReadStream(F);
end;

procedure TBSONItemDoc.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    Values.WriteStream(F);
end;


{$ENDREGION}

{$REGION 'TBSONItemArray'}

class function TBSONItemArray.Create(const aName: string): PBSONItemArray;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_ARRAY;
    result.Base.Name:=aName;
    result.Values.Init();
end;

class procedure TBSONItemArray.Free(const aItem: PBSONItemArray);
begin
    aItem.Values.Clear();
    Dispose(aItem);
end;

class function TBSONItemArray.ReadStream(const F: TStream): PBSONItemArray;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_ARRAY;
    result.Base.ReadStreamName(F);
    result.Values.Init();
    result.Values.ReadStream(F);
end;

procedure TBSONItemArray.WriteStream(const F: TStream);
begin
    Values.NameNCount();
    Base.WriteStream(F);
    Values.WriteStream(F);
end;

{$ENDREGION}

{$REGION 'TBSONItemBinary'}

class function TBSONItemBinary.Create(const aName: string): PBSONItemBinary;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_BINARY;
    result.Base.Name:=aName;
    result.BinLen:=0;
    result.BinSubType:=BSON_BINTYPE_USER;
    result.BinData:=nil;
    result.OwnsData:=false;
end;

class procedure TBSONItemBinary.Free(const aItem: PBSONItemBinary);
begin
    if (aItem.OwnsData)AND(aItem.BinData<>nil) then
        FreeMem(aItem.BinData);
    Dispose(aItem);
end;

class function TBSONItemBinary.ReadStream(const F: TStream): PBSONItemBinary;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_BINARY;
    result.Base.ReadStreamName(F);
    F.read(result.BinLen, sizeof(Integer));
    F.read(result.BinSubType, sizeof(byte));
    GetMem(result.BinData, result.BinLen);
    F.read(result.BinData^, result.BinLen);
    result.OwnsData:=true;
end;

procedure TBSONItemBinary.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(BinLen, sizeof(Integer));
    F.write(BinSubType, sizeof(byte));
    if (BinData<>nil) then
        F.write(BinData^, BinLen);
end;


function TBSONItemBinary.ToString: string;
begin
    result:=Format(Str_BSONValueBinary,[BinSubType, BinLen, NativeInt(BinData)]);
end;

{$ENDREGION}

{$REGION 'TBSONItemObjectID'}

class function TBSONItemObjectID.Create(const aName: string; const aValue: TBSONObjectID): PBSONItemObjectID;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_OBJECTID;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemObjectID.Free(const aItem: PBSONItemObjectID);
begin
    Dispose(aItem);
end;

class function TBSONItemObjectID.ReadStream(const F: TStream): PBSONItemObjectID;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_OBJECTID;
    result.Base.ReadStreamName(F);
    F.read(result.Value[0], 12);
end;

procedure TBSONItemObjectID.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(Value[0], 12);
end;

function TBSONItemObjectID.ToString: string;
var P:PWideChar;
begin
    SetLength(result, sizeof(Value)*2);
    P:=@(result[1]);
    {$IFDEF FPC}
    BinToHex(@(Value[0]), PChar(P), sizeof(Value));
    {$ELSE}
    BinToHex(@(Value[0]), P, sizeof(Value));
    {$ENDIF}
end;

{$ENDREGION}

{$REGION 'TBSONItemBoolean'}

class function TBSONItemBoolean.Create(const aName: string; const aValue: Boolean): PBSONItemBoolean;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_BOOLEAN;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemBoolean.Free(const aItem: PBSONItemBoolean);
begin
    Dispose(aItem);
end;

class function TBSONItemBoolean.ReadStream(const F: TStream): PBSONItemBoolean;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_BOOLEAN;
    result.Base.ReadStreamName(F);
    result.Value:=false;
    F.read(result.Value, sizeof(byte));
end;

procedure TBSONItemBoolean.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(Value, sizeof(byte));
end;

function TBSONItemBoolean.ToString: string;
begin
    if (Value) then result:=Str_BSONValueTrue
    else result:=Str_BSONValueFalse;
end;


{$ENDREGION}

{$REGION 'TBSONItemDateTime'}

class function TBSONItemDateTime.Create(const aName: string; const aValue: TDateTime): PBSONItemDateTime;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DATETIME;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemDateTime.Free(const aItem: PBSONItemDateTime);
begin
    Dispose(aItem);
end;

class function TBSONItemDateTime.ReadStream(const F: TStream): PBSONItemDateTime;
var iData: Int64;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DATETIME;
    result.Base.ReadStreamName(F);
    F.read(iData, sizeof(Int64));
    result.Value:=UnixToDateTime(iData);
end;

procedure TBSONItemDateTime.WriteStream(const F: TStream);
var iData: Int64;
begin
    Base.WriteStream(F);
    iData:=DateTimeToUnix(Value);
    F.write(iData, sizeof(Int64));
end;

function TBSONItemDateTime.ToString: string;
begin
    result:=FormatDateTime(Str_BSONValueDateTime, Value);
end;

{$ENDREGION}

{$REGION 'TBSONItemNull'}

class function TBSONItemNull.Create(const aName: string): PBSONItemNull;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_NULL;
    result.Base.Name:=aName;
end;

class procedure TBSONItemNull.Free(const aItem: PBSONItemNull);
begin
    Dispose(aItem);
end;

class function TBSONItemNull.ReadStream(const F: TStream): PBSONItemNull;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_NULL;
    result.Base.ReadStreamName(F);
end;

procedure TBSONItemNull.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
end;

function TBSONItemNull.ToString: string;
begin
    result:=Str_BSONValueNULL;
end;

{$ENDREGION}

{$REGION 'TBSONItemRegEx'}

class function TBSONItemRegEx.Create(const aName: string; const aValuePattern, aValueOptions: string): PBSONItemRegEx;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_REGEX;
    result.Base.Name:=aName;
    result.ValuePattern:=aValuePattern;
    result.ValueOptions:=aValueOptions;
end;

class procedure TBSONItemRegEx.Free(const aItem: PBSONItemRegEx);
begin
    Dispose(aItem);
end;

class function TBSONItemRegEx.ReadStream(const F: TStream): PBSONItemRegEx;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_REGEX;
    result.Base.ReadStreamName(F);
    TBSONItemBase.ReadUTF8(F, result.ValuePattern, true);
    TBSONItemBase.ReadUTF8(F, result.ValueOptions, true);
end;

procedure TBSONItemRegEx.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    TBSONItemBase.WriteUTF8(F, ValuePattern, true);
    TBSONItemBase.WriteUTF8(F, ValueOptions, true);
end;

function TBSONItemRegEx.ToString: string;
begin
    result:=Format(Str_BSONValueRegEx, [ValuePattern,ValueOptions]);
end;


{$ENDREGION}

{$REGION 'TBSONItemJS'}

class function TBSONItemJS.Create(const aName: string; const aValue: string): PBSONItemJS;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_JS;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemJS.Free(const aItem: PBSONItemJS);
begin
    Dispose(aItem);
end;

class function TBSONItemJS.ReadStream(const F: TStream): PBSONItemJS;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_JS;
    result.Base.ReadStreamName(F);
    TBSONItemBase.ReadUTF8(F, result.Value, true);
end;

procedure TBSONItemJS.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    TBSONItemBase.WriteUTF8(F, Value, true);
end;

function TBSONItemJS.ToString: string;
begin
    result:=Value;
end;


{$ENDREGION}

{$REGION 'TBSONItemInt32'}

class function TBSONItemInt32.Create(const aName: string; const aValue: Integer): PBSONItemInt32;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_INT32;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemInt32.Free(const aItem: PBSONItemInt32);
begin
    Dispose(aItem);
end;


class function TBSONItemInt32.ReadStream(const F: TStream): PBSONItemInt32;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_INT32;
    result.Base.ReadStreamName(F);
    F.read(result.Value, sizeof(result.Value));
end;

procedure TBSONItemInt32.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(Value, sizeof(Value));
end;

function TBSONItemInt32.ToString: string;
begin
    result:=IntToStr(Value);
end;

{$ENDREGION}

{$REGION 'TBSONItemUInt64'}

class function TBSONItemUInt64.Create(const aName: string; const aValue: UInt64): PBSONItemUInt64;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_UINT64;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemUInt64.Free(const aItem: PBSONItemUInt64);
begin
    Dispose(aItem);
end;

class function TBSONItemUInt64.ReadStream(const F: TStream): PBSONItemUInt64;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_UINT64;
    result.Base.ReadStreamName(F);
    F.read(result.Value, sizeof(result.Value));
end;

procedure TBSONItemUInt64.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(Value, sizeof(Value));
end;

function TBSONItemUInt64.ToString: string;
begin
    result:=UIntToStr(Value);
end;

{$ENDREGION}

{$REGION 'TBSONItemInt64'}

class function TBSONItemInt64.Create(const aName: string; const aValue: Int64): PBSONItemInt64;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_INT64;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemInt64.Free(const aItem: PBSONItemInt64);
begin
    Dispose(aItem);
end;


class function TBSONItemInt64.ReadStream(const F: TStream): PBSONItemInt64;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_INT64;
    result.Base.ReadStreamName(F);
    F.read(result.Value, sizeof(result.Value));
end;

procedure TBSONItemInt64.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(Value, sizeof(Value));
end;

function TBSONItemInt64.ToString: string;
begin
    result:=IntToStr(Value);
end;

{$ENDREGION}

{$REGION 'TBSONItemDecimal128'}

class function TBSONItemDecimal128.Create(const aName: string; const aValue: TBSONDecimal128): PBSONItemDecimal128;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DECIMAL128;
    result.Base.Name:=aName;
    result.Value:=aValue;
end;

class procedure TBSONItemDecimal128.Free(const aItem: PBSONItemDecimal128);
begin
    Dispose(aItem);
end;


class function TBSONItemDecimal128.ReadStream(const F: TStream): PBSONItemDecimal128;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_DECIMAL128;
    result.Base.ReadStreamName(F);
    F.read(result.Value, sizeof(result.Value));
end;

procedure TBSONItemDecimal128.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
    F.write(Value, sizeof(Value));
end;


function TBSONItemDecimal128.ToString: string;
var P:PWideChar;
begin
    SetLength(result, sizeof(Value)*2);
    P:=@(result[1]);
    {$IFDEF FPC}
    BinToHex(@Value, PChar(P), sizeof(Value));
    {$ELSE}
    BinToHex(@Value, P, sizeof(Value));
    {$ENDIF}
end;

{$ENDREGION}

{$REGION 'TBSONItemMinKey'}

class function TBSONItemMinKey.Create(const aName: string): PBSONItemMinKey;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_MINKEY;
    result.Base.Name:=aName;
end;

class procedure TBSONItemMinKey.Free(const aItem: PBSONItemMinKey);
begin
    Dispose(aItem);
end;

class function TBSONItemMinKey.ReadStream(const F: TStream): PBSONItemMinKey;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_MINKEY;
    result.Base.ReadStreamName(F);
end;

procedure TBSONItemMinKey.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
end;

function TBSONItemMinKey.ToString: string;
begin
    result:=Str_BSONValueMinKey;
end;

{$ENDREGION}

{$REGION 'TBSONItemMaxKey'}

class function TBSONItemMaxKey.Create(const aName: string): PBSONItemMaxKey;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_MAXKEY;
    result.Base.Name:=aName;
end;

class procedure TBSONItemMaxKey.Free(const aItem: PBSONItemMaxKey);
begin
    Dispose(aItem);
end;

class function TBSONItemMaxKey.ReadStream(const F: TStream): PBSONItemMaxKey;
begin
    New(result);
    result.Base.BSONType:=BSON_TYPE_MAXKEY;
    result.Base.ReadStreamName(F);
end;

procedure TBSONItemMaxKey.WriteStream(const F: TStream);
begin
    Base.WriteStream(F);
end;

function TBSONItemMaxKey.ToString: string;
begin
    result:=Str_BSONValueMaxKey;
end;


{$ENDREGION}

{$REGION 'TBSONItemList'}

procedure TBSONItemList.Clear;
var i: Integer;
begin
    // Rule: ItemList is owner of the items. Dispose here!

    for i:=0 to Count-1 do begin
        FreeItem(Items[i]);
    end;

    Items:=nil;
    Count:=0;
end;

procedure TBSONItemList.Add(const aItem: PBSONItem);
begin
    if (Count=Capacity) then
        Grow();
    Items[Count]:=aItem;
    inc(Count);
end;

procedure TBSONItemList.Del(const aItem: PBSONItem);
begin
    Del(IndexOf(aItem));
end;

procedure TBSONItemList.Del(const aIndex: Integer);
begin
    if (aIndex>=0) then begin
        FreeItem(Items[aIndex]);
        Dec(Count);
        if aIndex<Count then
            System.Move(Items[aIndex+1], Items[aIndex], (Count-aIndex)*sizeof(PBSONItem));
    end;
end;

function TBSONItemList.Capacity: Integer;
begin
    result:=Length(Items);
end;

function TBSONItemList.GetItem(const Index: Integer): PBSONItemBase;
begin
    result:=Items[Index];
end;

procedure TBSONItemList.Grow;
var Cap  : Integer;
    Delta: Integer;
begin
    Cap:=Capacity;
    if Cap>64 then Delta:=Capacity div 4
    else if Cap>8 then Delta:=16
    else Delta:=4;
    SetLength(Items, Cap+Delta);
end;

function TBSONItemList.IndexOf(const aItem: PBSONItem): Integer;
var i: Integer;
begin
    for i:=0 to Count-1 do begin
        if (Items[i]=aItem) then exit(i);
    end;
    result:=-1;
end;


function TBSONItemList.ByName(const aName: string): PBSONItem;
var i: Integer;
begin
    for i:=0 to Count-1 do begin
        result:=PBSONItemBase(Items[i]);
        if PBSONItemBase(result).Name=aName then exit(result);
    end;
    result:=nil;
end;

function TBSONItemList.ByName(const aName: string; const aBSONType: TBSONType): PBSONItem;
var i: Integer;
begin
    for i:=0 to Count-1 do begin
        result:=Items[i];
        if (PBSONItemBase(result).BSONType=aBSONType)AND(PBSONItemBase(result).Name=aName) then exit(result);
    end;
    result:=nil;
end;


procedure TBSONItemList.Init;
begin
    self:=System.Default(TBSONItemList);
end;

procedure TBSONItemList.NameNCount();
var i: Integer;
begin
    // Array of items has name "0", "1", ...
    for i:=0 to Count-1 do begin
        if PBSONItemBase(Items[i]).Name = '' then
          PBSONItemBase(Items[i]).Name:=IntToStr(i);
    end;
end;

procedure TBSONItemList.ToStringsJSON(const aString:TStrings; const aIndenting:string; const aLevel:Integer; const aOutName:Boolean);
var i: Integer;
    s: string;
    sIndenting:string;
    iItem:PBSONItemBase;
begin
    sIndenting:='';
    for i:=0 to aLevel-1 do
        sIndenting:=sIndenting+aIndenting;


    for i:=0 to Count-1 do begin

        iItem:=Items[i];

        s:=sIndenting;
        if (aOutName) then
            s:=s+Str_BSONStringQuote+iItem.Name+Str_BSONStringQuote+Str_BSONValueSeperator;

        // Cast to typed record
        case iItem.BSONType of
        BSON_TYPE_DOUBLE: s:=s+PBSONItemDouble(iItem).ToString;
        BSON_TYPE_STRING: s:=s+Str_BSONStringQuote+PBSONItemString(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_DOC: s:=s+Str_BSONDocSeperatorO;
        BSON_TYPE_ARRAY: s:=s+Str_BSONArraySeperatorO;
        BSON_TYPE_BINARY: s:=s+Str_BSONStringQuote+PBSONItemBinary(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_OBJECTID: s:=s+Str_BSONStringQuote+PBSONItemObjectID(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_BOOLEAN: s:=s+PBSONItemBoolean(iItem).ToString;
        BSON_TYPE_DATETIME: s:=s+Str_BSONStringQuote+PBSONItemDateTime(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_NULL: s:=s+PBSONItemNull(iItem).ToString;
        BSON_TYPE_REGEX: s:=s+Str_BSONStringQuote+PBSONItemRegEx(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_JS: s:=s+Str_BSONStringQuote+PBSONItemJS(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_INT32: s:=s+PBSONItemInt32(iItem).ToString;
        BSON_TYPE_UINT64: s:=s+Str_BSONStringQuote+PBSONItemUInt64(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_INT64: s:=s+PBSONItemInt64(iItem).ToString;
        BSON_TYPE_DECIMAL128: s:=s+Str_BSONStringQuote+PBSONItemDecimal128(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_MINKEY: s:=s+Str_BSONStringQuote+PBSONItemMinKey(iItem).ToString+Str_BSONStringQuote;
        BSON_TYPE_MAXKEY: s:=s+Str_BSONStringQuote+PBSONItemMaxKey(iItem).ToString+Str_BSONStringQuote;
        else
        raise EBSONException.Create(Str_BSONExceptionValueType+IntToStr(iItem.BSONType));
        end;

        if (iItem.BSONType<>BSON_TYPE_DOC)AND(iItem.BSONType<>BSON_TYPE_ARRAY)AND(i<Count-1) then
            s:=s+Str_BSONComma;

        aString.Add(s);

        case iItem.BSONType of
        BSON_TYPE_DOC: begin
            PBSONItemDoc(iItem).Values.ToStringsJSON(aString, aIndenting, aLevel+1, true);
            s:=sIndenting+Str_BSONDocSeperatorC;
            if (i<Count-1) then
                s:=s+Str_BSONComma;
            aString.Add(s);
        end;
        BSON_TYPE_ARRAY: begin
            PBSONItemArray(iItem).Values.NameNCount;
            PBSONItemArray(iItem).Values.ToStringsJSON(aString, aIndenting, aLevel+1, false);
            s:=sIndenting+Str_BSONArraySeperatorC;
            if (i<Count-1) then
                s:=s+Str_BSONComma;
            aString.Add(s);
        end;
        end;

    end;
end;

procedure TBSONItemList.ToStringsSimple(const aString:TStrings; const aIndenting:string; const aLevel:Integer);
var i: Integer;
    s: string;
    sIndenting:string;
    iItem:PBSONItemBase;
begin
    //Simple StringList output:
    //without quotes, without comma
    //with typename, arrayindex as numbers

    sIndenting:='';
    for i:=0 to aLevel-1 do
        sIndenting:=sIndenting+aIndenting;

    for i:=0 to Count-1 do begin

        iItem:=PBSONItemBase(Items[i]);

        s:=sIndenting+iItem.ValueTypeToString+Str_BSONTypeSeperator+iItem.Name+Str_BSONValueSeperator;

        // Cast to typed record
        case iItem.BSONType of
        BSON_TYPE_DOUBLE: s:=s+PBSONItemDouble(iItem).ToString;
        BSON_TYPE_STRING: s:=s+PBSONItemString(iItem).ToString;
        BSON_TYPE_DOC: s:=s+Str_BSONDocSeperatorO;
        BSON_TYPE_ARRAY: s:=s+Str_BSONArraySeperatorO;
        BSON_TYPE_BINARY: s:=s+PBSONItemBinary(iItem).ToString;
        BSON_TYPE_OBJECTID: s:=s+PBSONItemObjectID(iItem).ToString;
        BSON_TYPE_BOOLEAN: s:=s+PBSONItemBoolean(iItem).ToString;
        BSON_TYPE_DATETIME: s:=s+PBSONItemDateTime(iItem).ToString;
        BSON_TYPE_NULL: s:=s+PBSONItemNull(iItem).ToString;
        BSON_TYPE_REGEX: s:=s+PBSONItemRegEx(iItem).ToString;
        BSON_TYPE_JS: s:=s+PBSONItemJS(iItem).ToString;
        BSON_TYPE_INT32: s:=s+PBSONItemInt32(iItem).ToString;
        BSON_TYPE_UINT64: s:=s+PBSONItemUInt64(iItem).ToString;
        BSON_TYPE_INT64: s:=s+PBSONItemInt64(iItem).ToString;
        BSON_TYPE_DECIMAL128: s:=s+PBSONItemDecimal128(iItem).ToString;
        BSON_TYPE_MINKEY: s:=s+PBSONItemMinKey(iItem).ToString;
        BSON_TYPE_MAXKEY: s:=s+PBSONItemMaxKey(iItem).ToString;
        else
        raise EBSONException.Create(Str_BSONExceptionValueType+IntToStr(iItem.BSONType));
        end;

        aString.Add(s);

        case iItem.BSONType of
        BSON_TYPE_DOC: begin
            PBSONItemDoc(Items[i]).Values.ToStringsSimple(aString, aIndenting, aLevel+1);
            s:=sIndenting+Str_BSONDocSeperatorC;
            aString.Add(s);
        end;
        BSON_TYPE_ARRAY: begin
            PBSONItemArray(Items[i]).Values.NameNCount;
            PBSONItemArray(Items[i]).Values.ToStringsSimple(aString, aIndenting, aLevel+1);
            s:=sIndenting+Str_BSONArraySeperatorC;
            aString.Add(s);
        end;
        end;

    end;
end;


procedure TBSONItemList.ReadStream(const F: TStream);
var IntSize  : Integer;
    ValueType: TBSONType;
    Item     : PBSONItem;
begin
    Clear();
    F.read(IntSize, sizeof(IntSize));

    ValueType:=TBSONItemBase.ReadStreamValue(F);
    while ValueType<>BSON_TYPE_EOF do begin
        case ValueType of
        BSON_TYPE_DOUBLE: Item:=TBSONItemDouble.ReadStream(F);
        BSON_TYPE_STRING: Item:=TBSONItemString.ReadStream(F);
        BSON_TYPE_DOC: Item:=TBSONItemDoc.ReadStream(F);
        BSON_TYPE_ARRAY: Item:=TBSONItemArray.ReadStream(F);
        BSON_TYPE_BINARY: Item:=TBSONItemBinary.ReadStream(F);
        BSON_TYPE_OBJECTID: Item:=TBSONItemObjectID.ReadStream(F);
        BSON_TYPE_BOOLEAN: Item:=TBSONItemBoolean.ReadStream(F);
        BSON_TYPE_DATETIME: Item:=TBSONItemDateTime.ReadStream(F);
        BSON_TYPE_NULL: Item:=TBSONItemNull.ReadStream(F);
        BSON_TYPE_REGEX: Item:=TBSONItemRegEx.ReadStream(F);
        BSON_TYPE_JS: Item:=TBSONItemJS.ReadStream(F);
        BSON_TYPE_INT32: Item:=TBSONItemInt32.ReadStream(F);
        BSON_TYPE_UINT64: Item:=TBSONItemUInt64.ReadStream(F);
        BSON_TYPE_INT64: Item:=TBSONItemInt64.ReadStream(F);
        BSON_TYPE_DECIMAL128: Item:=TBSONItemDecimal128.ReadStream(F);
        BSON_TYPE_MINKEY: Item:=TBSONItemMinKey.ReadStream(F);
        BSON_TYPE_MAXKEY: Item:=TBSONItemMaxKey.ReadStream(F);
        else
        raise EBSONException.Create(Str_BSONExceptionValueType+IntToStr(ValueType));
        end;

        Add(Item);

        ValueType:=TBSONItemBase.ReadStreamValue(F); // Next ValueType or EOF
    end;
end;

procedure TBSONItemList.WriteStream(const F: TStream);
var i      : Integer;
var IntSize: Integer;
    PosSize: Int64;
begin
    PosSize:=F.Position;
    IntSize:=0;
    F.write(IntSize, sizeof(IntSize));

    for i:=0 to Count-1 do begin
        // Cast to typed record
        case PBSONItemBase(Items[i]).BSONType of
        BSON_TYPE_DOUBLE: PBSONItemDouble(Items[i]).WriteStream(F);
        BSON_TYPE_STRING: PBSONItemString(Items[i]).WriteStream(F);
        BSON_TYPE_DOC: PBSONItemDoc(Items[i]).WriteStream(F);
        BSON_TYPE_ARRAY: PBSONItemArray(Items[i]).WriteStream(F);
        BSON_TYPE_BINARY: PBSONItemBinary(Items[i]).WriteStream(F);
        BSON_TYPE_OBJECTID: PBSONItemObjectID(Items[i]).WriteStream(F);
        BSON_TYPE_BOOLEAN: PBSONItemBoolean(Items[i]).WriteStream(F);
        BSON_TYPE_DATETIME: PBSONItemDateTime(Items[i]).WriteStream(F);
        BSON_TYPE_NULL: PBSONItemNull(Items[i]).WriteStream(F);
        BSON_TYPE_REGEX: PBSONItemRegEx(Items[i]).WriteStream(F);
        BSON_TYPE_JS: PBSONItemJS(Items[i]).WriteStream(F);
        BSON_TYPE_INT32: PBSONItemInt32(Items[i]).WriteStream(F);
        BSON_TYPE_UINT64: PBSONItemUInt64(Items[i]).WriteStream(F);
        BSON_TYPE_INT64: PBSONItemInt64(Items[i]).WriteStream(F);
        BSON_TYPE_DECIMAL128: PBSONItemDecimal128(Items[i]).WriteStream(F);
        BSON_TYPE_MINKEY: PBSONItemMinKey(Items[i]).WriteStream(F);
        BSON_TYPE_MAXKEY: PBSONItemMaxKey(Items[i]).WriteStream(F);
    else
        raise EBSONException.Create(Str_BSONExceptionValueType+IntToStr(PBSONItemBase(Items[i]).BSONType));
        end;
    end;
    F.write(cBSON_NULL, sizeof(TBSONType));

    // Size of ItemList
    IntSize:=Integer(F.Position-PosSize);

    // Write at stream
    F.Seek(PosSize, soBeginning);
    F.write(IntSize, sizeof(IntSize));
    F.Seek(0, soEnd);
end;

procedure TBSONItemList.FreeItem(const aItem: PBSONItem);
begin
    case PBSONItemBase(aItem).BSONType of
    BSON_TYPE_DOUBLE: TBSONItemDouble.Free(aItem);
    BSON_TYPE_STRING: TBSONItemString.Free(aItem);
    BSON_TYPE_DOC: TBSONItemDoc.Free(aItem);
    BSON_TYPE_ARRAY: TBSONItemArray.Free(aItem);
    BSON_TYPE_BINARY: TBSONItemBinary.Free(aItem);
    BSON_TYPE_OBJECTID: TBSONItemObjectID.Free(aItem);
    BSON_TYPE_BOOLEAN: TBSONItemBoolean.Free(aItem);
    BSON_TYPE_DATETIME: TBSONItemDateTime.Free(aItem);
    BSON_TYPE_NULL: TBSONItemNull.Free(aItem);
    BSON_TYPE_REGEX: TBSONItemRegEx.Free(aItem);
    BSON_TYPE_JS: TBSONItemJS.Free(aItem);
    BSON_TYPE_INT32: TBSONItemInt32.Free(aItem);
    BSON_TYPE_UINT64: TBSONItemUInt64.Free(aItem);
    BSON_TYPE_INT64: TBSONItemInt64.Free(aItem);
    BSON_TYPE_DECIMAL128: TBSONItemDecimal128.Free(aItem);
    BSON_TYPE_MINKEY: TBSONItemMinKey.Free(aItem);
    BSON_TYPE_MAXKEY: TBSONItemMaxKey.Free(aItem);
    else
    raise EBSONException.Create(Str_BSONExceptionValueType+IntToStr(PBSONItemBase(aItem).BSONType));
    end;
end;

{$ENDREGION}

initialization
  BSON_FormatSettingsFloat:= FormatSettings;
  BSON_FormatSettingsFloat.ThousandSeparator:= #0;
  BSON_FormatSettingsFloat.DecimalSeparator:= '.'
end.
