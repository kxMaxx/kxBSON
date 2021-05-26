# kxBSON
Class for reading and writing a stream in BSON format

* Delphi (Pascal)
* BSON: Binary-JSON
* Specification: [bsonspec.org](http://bsonspec.org/)
* Compiler: Embarcadero Delphi

## History
* Version 1 from 12/2020

## Usage
```pascal
uses 
  kxBSON;

procedure BSON_New();
var
  FBSONDoc: TBSONDocument;
begin
  FBSONDoc:=TBSONDocument.Create();
  FBSONDoc.Values.Add( TBSONItemInt32.Create('Item1', MAXInt) );
  FBSONDoc.Values.Add( TBSONItemDouble.Create('Item2', Pi) );
  FBSONDoc.SaveToFile( ExtractFilePath( Application.ExeName ) + 'hello.bson' );
  FBSONDoc.Free;
end;
```
