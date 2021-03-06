unit ReadDiskUnit;

interface

uses
  myf_consts, myf_main, myf_plugins,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, UsefulPrcs, ExtCtrls, Buttons, CheckLst, TZip,
  AppVerInfo, VersInfo, jpeg, db,
  dbtables, ImgList, Menus, MapChar, DIB, CorelButton, FlatButton,
  CommCtrl, Animate, OleCtrls, SHDocVw, GifImge2, ShellApi, ToolWin,
  Mask, ToolEdit, FoldrDlg, IniFiles, XPMenu, gfx_tiff;

type
  EPreview = class(Exception);
  EPreReadDisk = class(Exception);

type
  TInfoExtractor = class(TObject)
  private
    FslPList,FslProps,FslTemp : TStringList;
    FslPICache : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function ExtractInfo(const fn: string): string;
    property InfoDef: TStringList read FslPList;
  end;

type
  TfrmReadDisk = class(TForm)
    extZipFile: TZipFile;
    ilMenus: TImageList;
    pmRDOpt: TPopupMenu;
    pmOpt: TPopupMenu;
    menDelRule: TMenuItem;
    menNewFolderRule: TMenuItem;
    menNewFileRule: TMenuItem;
    N1: TMenuItem;
    pmRDOptDel: TPopupMenu;
    Shape1: TShape;
    lblCaption: TLabel;
    imgCaption: TImage;
    btnStart: TFlatButton;
    btnFinish: TFlatButton;
    btnCancel: TFlatButton;
    ilDrives: TImageList;
    ImageList2: TImageList;
    pmEinlesen: TPopupMenu;
    DebugModus1: TMenuItem;
    pmUsedPlugins: TPopupMenu;
    menDel: TMenuItem;
    pmInstalled: TPopupMenu;
    menAdd: TMenuItem;
    N2: TMenuItem;
    menPlug: TMenuItem;
    menPlugConfig: TMenuItem;
    menPlugAbout: TMenuItem;
    menAddAll: TMenuItem;
    tsOptions: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tsPlugIns: TTabSheet;
    GroupBox1: TGroupBox;
    lvDrives: TListView;
    gbLabel: TGroupBox;
    Label5: TLabel;
    edtLabel: TEdit;
    GroupBox5: TGroupBox;
    ToolBar1: TToolBar;
    tbOpen: TToolButton;
    tbSave: TToolButton;
    cbStapel: TCheckBox;
    tvInstalled: TTreeView;
    fbAdd: TFlatButton;
    fbDel: TFlatButton;
    lvUsedPlugins: TListView;
    fbPUp: TFlatButton;
    fbPDown: TFlatButton;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    tsStatus: TTabSheet;
    lblCurF: TLabel;
    Image1: TImage;
    lblState: TLabel;
    lblErr: TLabel;
    anim: TAnimate;
    pbScan: TProgressBar;
    Panel2: TPanel;
    icB: TImage;
    icF: TImage;
    gbMM: TGroupBox;
    ckMP3Prev: TCheckBox;
    fbCfgMP3: TFlatButton;
    gbNotes: TGroupBox;
    ckFILEIDDIZ: TCheckBox;
    gbDontRead: TGroupBox;
    Label6: TLabel;
    ckIgHidden: TCheckBox;
    ckIg0Byte: TCheckBox;
    ckIgEmptyFolder: TCheckBox;
    cbIgFiles: TComboEdit;
    fd: TFolderDialog;
    od: TOpenDialog;
    sd: TSaveDialog;
    ckImgPrev: TCheckBox;
    fbCfgImg: TFlatButton;
    gbStat: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    lblstatFolders: TLabel;
    lblstatFiles: TLabel;
    lblstatInfos: TLabel;
    lblstatPreview: TLabel;
    ckUpdatePrev: TCheckBox;
    ckDescriptION: TCheckBox;
    lblsstatFolders: TLabel;
    lblsstatFiles: TLabel;
    lblsstatPreview: TLabel;
    lblsstatInfos: TLabel;
    Label4: TLabel;
    pnlWait: TPanel;
    Label11: TLabel;
    Label13: TLabel;
    lblEject: TLabel;
    lblPreset: TLabel;
    cbIncludeFiles: TComboEdit;
    Label12: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tvOptEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure btnFinishClick(Sender: TObject);
    procedure edtLabelKeyPress(Sender: TObject; var Key: Char);
    procedure edtLabelChange(Sender: TObject);
    procedure cbStapelClick(Sender: TObject);
    procedure lvDrivesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure DebugModus1Click(Sender: TObject);
    procedure fbAddClick(Sender: TObject);
    procedure lvUsedPluginsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure fbDelClick(Sender: TObject);
    procedure menPlugConfigClick(Sender: TObject);
    procedure pmInstalledPopup(Sender: TObject);
    procedure menPlugAboutClick(Sender: TObject);
    procedure fbPUpClick(Sender: TObject);
    procedure fbPDownClick(Sender: TObject);
    procedure tvInstalledChange(Sender: TObject; Node: TTreeNode);
    procedure fbBasisOrdnerClick(Sender: TObject);
    procedure cbIgFilesButtonClick(Sender: TObject);
    procedure tbOpenClick(Sender: TObject);
    procedure tbSaveClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure fbCfgGenClick(Sender: TObject);
    procedure edtLabelExit(Sender: TObject);
  private
    p_maxh, p_maxw, p_qual: integer;
    p_dur: integer;
    p_bitrate, p_param: string;
    level: Byte;
    Pg: Int64;
    running, isabort, finish: Boolean;
    disklabel: string;
   { slfileopt,} slfolderopt: TStringList;
    CurFID: integer; // zuletzt vergebene AutoInc-FolderID
    FOldWindowProc: TWndMethod;
    InfExtr : TInfoExtractor;

    { Einlesen }
    { Statistik } stat_folders, stat_files, stat_info, stat_preview : integer;
    lFolders, lFiles, lInfo, lPreview : integer;
    lastdone, laststat : dword;
    nor0Byte, norHidden, norEmptyFolders : Boolean;
    norMasks : TStringList;
    IncludeMasks : TStringList;
    optFileIDDiz, optUpdatePrev,optDESCRIPTION : Boolean;
    domp3, doimg : Boolean;
    FThreadRunning : Boolean;

    { --------- }

    procedure InitDriveListView;
    function ReadDir(Verzeichnis: string; DiskId: longint): Int64;
    procedure ReadThis(drive: char);
    procedure loadautoinc;
    { Preview Procedures }
    function doprevwork(verzeichnis, filen: string): Boolean;
{    procedure ext_ZipNote(verzeichnis, filen: string; Options: integer);
    procedure ext_verinfo(verzeichnis, filen: string; Options: integer); }
    procedure ext_picprev(verzeichnis, filen: string);
    procedure ext_mp3preview(verzeichnis, filen: string);
//    procedure ext_importm3u(verzeichnis, filen: string; Options: integer);
//    procedure ext_txtpreview(verzeichnis, filen: string; Options: integer; ishtml: boolean);
    { Options }
//    procedure ReadOptList;
//    procedure buildoptions;
//    procedure setpreset(s: string);
    procedure HookForm;
    procedure UnhookForm;
    procedure WndProcForm(var AMsg: TMessage);
    function DriveSelct: char;
    procedure LoadPlugins;

    procedure LoadSettings(FileName: string);
    procedure SaveSettings(FileName: string);
    function PlugInsToString:string;
    procedure PlugInsFromString(const str:string);
    procedure doStats;
    function FileMatchesMasks(fn:string;Masks:TStringList):Boolean;
    procedure disablefrm;
    procedure updprogresscaption;
  protected
    procedure CreateWnd; override;

 //    ext_id3preview(verzeichnis,filen:string;fd:TDateTime);
  public
    preset: string;
    tooktime: dword;
    disksread: integer;
    ReadDiskId : Smallint;
    updmode, dbug: Boolean;
//    procedure OpenOpts(s: string);
    destructor Destroy; override;
  end;



var
  frmReadDisk: TfrmReadDisk;
  QueryCancelAutoPlay: Cardinal;

implementation

uses DataModule, Unit1, selfMP3header, NewListUnit, StringListEditUnit;

const
  bit_noidx = 1; // nicht indizieren
  bit_fldr = 2;
  bit_files = 4;
  bit_id3 = 8;
  bit_mp3 = 16;
  bit_prev = 32;
  bit_vers = 64;
  bit_zip = 128;
  bit_text = 256;
  bit_playlists = 512;
  bit__updateall = 1024;

//  csid = 'AutoInc'; // AutoInc - ID in tblFolders

{$R *.DFM}




{ * * * * * * * * * * * * *  Preview - Funktionen * * * * * * * * * * * * * * }

constructor TInfoExtractor.Create;
begin
  FslPList := TStringList.Create;
  FslPICache := TStringList.Create;
  FslProps := TStringList.Create;
end;

function TInfoExtractor.ExtractInfo(const fn: string): string;
var
  prop : string;
  plug : TMyPlugin;
  i    : integer;
  idx : integer;

begin
  FslProps.Clear;
  for i := 0 to FslPList.Count - 1 do
  begin
    prop := FslPList[i];
    if FslProps.Values[ prop ] = '' then  { Eigenschaft noch nicht gefunden? }
    begin
      plug := TMyPlugin(FslPList.Objects[i]);
      { Cache befragen ... }
      idx := FslPICache.IndexOf(plug.ID);
      if idx = -1 then { kein Cache Eintrag }
      begin
        FslTemp := TStringList.Create;
        FslTemp.CommaText := plug.Execute(fn);
        FslPICache.AddObject( plug.ID, FslTemp);
      end else
        FslTemp := FslPICache.Objects[idx] as TStringList;
      { Eigenschaft �bernehmen }
      if FslTemp.Values[ prop ] <> '' then
        FslProps.Values[ prop ] := FslTemp.Values[ prop ];
    end;
  end;
  //  slProps.Sort;

  Result := '';
  for i := 0 to FslProps.Count - 1 do
    Result := Result + FslProps.Names[i] + ': ' + FslProps.Values[FslProps.Names[i]] + #13#10;

  for i := 0 to FslPICache.Count - 1 do FslPICache.Objects[i].Free;
  FslPICache.Clear;
end;

destructor TInfoExtractor.Destroy;
begin
  FslPList.Free;
  FslPICache.Free;
  FslProps.Free;
end;

{ AutoPlay disabled }

procedure TfrmReadDisk.CreateWnd;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit; {Don't need to hook when designing}
  if Enabled then
  begin
    HookForm; {Hook the main form's Window}
  end;
end;

function TfrmReadDisk.DriveSelct:char;
var
  s : string;
begin
  if assigned(lvDrives.Selected) then
  begin
    s := lvDrives.Selected.Caption;
    result := s[Length(s)-2];
  end else result := '*';
end;

destructor TfrmReadDisk.Destroy;
begin
  if not (csDesigning in ComponentState) then
    UnhookForm; {Stop interfering ...}
  norMasks.Free;
  IncludeMasks.Free;
  inherited Destroy;
end;

procedure TfrmReadDisk.HookForm;
begin
  if csDesigning in ComponentState then
    Exit;
  FOldWindowProc := WindowProc;
  WindowProc := WndProcForm;
end;

procedure TfrmReadDisk.UnhookForm;
begin
  if csDesigning in ComponentState then
    Exit;
  {If we are "hooked" then undo what Hookform did}
  if Assigned(FOldWindowProc) then
  begin
    if HandleAllocated then
    begin
      WindowProc := FOldWindowProc;
    end;
    FOldWindowProc := nil;
  end;
end;

procedure TfrmReadDisk.WndProcForm(var AMsg: TMessage);
begin
  if Enabled then
  begin
    if AMsg.Msg = QueryCancelAutoPlay then
    begin
      AMsg.Result := 1;
      Exit;
    end;
  end;
  {Call the default windows procedure}
  FOldWindowProc(AMsg);
end;


{ String zur�ckgeben, wenn s nicht leer }

function IfStr(prefix, s: string): string;
begin
  if s <> '' then Result := prefix + s + #13#10 else Result := '';
end;

{procedure TfrmReadDisk.ext_ZipNote(verzeichnis, filen: string; Options: integer);
var
  i: integer;
  s, fn: string;
  gessize: Int64;

  function Subs(S: string; Sub, Sost: Char): string;
  var i: Longint;
  begin
    for i := 1 to Length(S) do
      if s[i] = Sub then
        s[i] := Sost;
    Result := s;
  end;

begin
  if not bool(Options and bit_zip) then Exit;
  with extZipFile do
  begin
    lblCurF.Caption := Verzeichnis + filen;
    lblState.Caption := str_r1;
//    Application.ProcessMessages;
    filename := verzeichnis + filen;
    gessize := 0;
    for i := 0 to filecount - 1 do
    begin
      fn := subs(oemtoansistr(files[i].FileName), '/', '\');
      if fn = '' then continue;
      if fn[Length(fn)] = '\' then
      begin
        fn := Copy(fn, 1, Length(fn) - 1);
        s := s + #13#10 + extractfilename(fn) + '|-1|' + extractfilepath(fn)
      end else
        s := s + #13#10 +
          extractfilename(fn) + '|' +
          IntToStr(files[i].UncompressedSize) + '|' +
          extractfilepath(fn);
      Inc(gessize, files[i].UncompressedSize);
    end;
    s := inttostr(filecount) + #13#10 + inttostr(gessize) + s
  end;
  // In DB Speichern
  with dm, tblFiles do
  begin
    tblFilesTextPreview.Value := s;
    tblFilesTKind.Value := pk_zipfile;
  end;
end;

procedure TfrmReadDisk.ext_verinfo(verzeichnis, filen: string; Options: integer);
var
  s: string;


begin
  if not bool(Options and bit_vers) then Exit;
  lblCurF.Caption := Verzeichnis + filen;
  lblState.Caption := str_r2;
  Application.ProcessMessages;
  with TdfsVersionInfoResource.Create(Self) do
  try
    filename := verzeichnis + filen;
    s := IfStr('', FileDescription) +
      IfStr(str_d1 + ' ', ProductName) +
      IfStr(str_d2 + ' ', CompanyName) +
      IfStr(str_d3 + ' ', OriginalFilename) +
      IfStr(str_d4 + ' ', Comments) +
      IfStr(str_d5 + ' ', InternalName) +
      IfStr(str_d6 + ' ', ProductVersion.AsString) +
      IfStr(str_d7 + ' ', FileVersion.AsString) +
      IfStr(str_d8 + ' ', LegalCopyright) +
      IfStr(str_d9 + ' ', LegalTradeMarks) +
      IfStr(str_d10 + ' ', BFlags);
    if s = '' then raise EAbort.Create('');
  finally
    Free;
  end;
  // In DB Speichern
  with dm, tblFiles do
  begin
    if Length(s) > 0 then
      s := Copy(s, 1, Length(s) - 2);
    tblFilesTextPreview.Value := s;
    tblFilesTKind.Value := pk_verinfo;
  end;
end;
}
procedure TfrmReadDisk.ext_picprev(verzeichnis, filen: string);
var
  jpg, jpg2: TJPEGImage;
  bmp: TBitmap;
  MS: TMemoryStream;
  h, w: integer;
  ratio: Double;
  fx, s: string;
//  pf: TPixelFormat;

begin
//  lblCurF.Caption := Verzeichnis + filen;
//  lblState.Caption := str_r3;
//  Application.ProcessMessages;

  s := lowercase(extractfileext(filen));
  if (s = '.jpeg') or (s = '.jpg') then
    begin
      jpg2 := TJpegImage.Create;
      try
        jpg2.Scale := jsEighth;
        jpg2.loadfromfile(verzeichnis + filen);
        image1.picture.assign(jpg2);
      finally
        jpg2.Free;
      end;
    end else
     image1.picture.loadfromfile(verzeichnis + filen);
  MS := TMemoryStream.Create; //BlobStream.Create(dm.tblPreviewBinPreview,bmWrite);
  bmp := TBitmap.Create;
  jpg := TJPEGImage.Create;

  try

//    pf := pfCustom;
    h := image1.picture.graphic.Height;
    w := image1.picture.graphic.Width;
    fx := '*' + ansilowercase(extractfileext(filen));
    if (h <= p_maxh) and (w <= p_maxw) then
    begin
      bmp.Height := h;
      bmp.Width := w;
    end else
    begin
      ratio := h / w;
      if h < w then
      begin
        bmp.Width := p_maxw;
        bmp.Height := round(p_maxw * ratio);
      end else
      begin
        bmp.Height := p_maxh;
        bmp.Width := round(p_maxh / ratio);
      end;
    end;
    if h * w = 0 then begin
      lblErr.Caption := Format(str_Epicempty, [verzeichnis, filen]);
      raise EAbort.Create('');
    end;
    bmp.Canvas.stretchdraw(bmp.Canvas.cliprect, image1.picture.graphic);
    with jpg do
    begin
      Assign(bmp);
      CompressionQuality := p_qual;
      SaveToStream(MS);
      Performance := jpBestSpeed;
    end;
    MS.Seek(soFromBeginning, 0);

    with dm, tblFiles do
    begin
      tblFilesBinPreview.LoadFromStream(MS);
      tblFilesBKind.Value := pk_img;
      Inc(stat_preview);
    end;
  finally
    MS.Free;
    bmp.Free;
    jpg.Free;
  end;
end;

{procedure TfrmReadDisk.ext_txtpreview(verzeichnis, filen: string; Options: integer; ishtml: boolean);
var
  fs: TFileStream;
  sz: integer;
  buf: array[0..1024] of char;
  s, note: string;

  idx: integer;
begin
  // Init-Kram
  if not bool(Options and bit_text) then Exit;
  lblCurF.Caption := Verzeichnis + filen;
  lblState.Caption := str_r4;
  Application.ProcessMessages;
  fs := TFileStream.Create(verzeichnis + filen, fmOpenRead or fmShareDenyWrite);
  try
    if fs.Size < 1024 then sz := fs.Size else sz := 1024;
    fillchar(buf, SizeOf(buf), #0);
    fs.Read(buf, sz);
    s := strpas(buf);
  finally
    fs.Free;
  end;
  if ishtml then
  begin
    idx := Pos('<title>', ansilowercase(s)); // Title-Tag suchen
    if idx <> 0 then
    begin
      Delete(s, 1, idx + 6);
      idx := Pos('<', s);
      note := XML2Ansi(Copy(s, 1, idx - 1));
    end;
  end else
    with TStringList.Create do { die ersten 3 Zeilen ... }
{    try
      Text := s;
      while Count > 3 do
        Delete(3);
      note := Text;
    finally
      Free;
    end;
  // in DB speichern
  note := trim(note);
  if note <> '' then
    with dm, tblFiles do
    begin
      tblFilesTextPreview.Value := note;
      if ishtml then tblFilesTKind.Value := pk_html
      else tblFilesTKind.Value := pk_txt;
    end;
end;
}
procedure TfrmReadDisk.ext_mp3preview(verzeichnis, filen: string);

  function ExecAndWait(const Filename, Params: string; WindowState: word): boolean;
  var
    SUInfo: TStartupInfo;
    ProcInfo: TProcessInformation;
    CmdLine: string;
  begin
    CmdLine := '"' + Filename + '" ' + Params;
    FillChar(SUInfo, SizeOf(SUInfo), #0);
    with SUInfo do begin
      cb := SizeOf(SUInfo);
      dwFlags := STARTF_USESHOWWINDOW;
      wShowWindow := WindowState;
    end;
    Result := CreateProcess(nil, PChar(CmdLine), nil, nil, FALSE,
      CREATE_NEW_CONSOLE or
      NORMAL_PRIORITY_CLASS, nil,
      PChar(ExtractFilePath(Filename)),
      SUInfo, ProcInfo);
    if Result then
      if WaitForSingleObject(ProcInfo.hProcess, lame_timeout) = WAIT_TIMEOUT then
        lblErr.Caption := Format(str_Elame, [verzeichnis, filen]);
  end;

var
  fnLameIn, fnLameOut: string;

var
  fsIn, fsOut: TFileStream;
  header: dword;
  mph: TselfMPEGHeader;
  fbuf: Pointer;
  time: Double;
  Count, frames: integer;

begin
//  lblCurF.Caption := Verzeichnis + filen;
//  if hbsp then lblState.Caption := str_r5;
//  Application.ProcessMessages;

  { Dateinamen etc. Init }
  fsIn := nil;
  fsOut := nil;
  Count := 0;
  frames := 0;
  time := 0;
  fnLameIn := gettempdir + 'MyFiles1.mp3';
  fnLameOut := gettempdir + 'MyFiles2.mp3';
  mph := TselfMPEGHeader.Create;
  try
    try
      fsIn := TFileStream.Create(verzeichnis + filen, fmOpenRead or fmShareDenyWrite);
      fsOut := TFileStream.Create(fnLameIn, fmCreate or fmShareExclusive);
      repeat
        if fsIn.Read(header, SizeOf(dword)) < 4 then break;
        mph.data := header;
        { syncronisieren falls defekter Dateianfang }
(*        while (frames = 0) and (mph.error) and (fsIn.Position < fsIn.Size) and (Count < 5 * 1024) do
        begin
          fsIn.Seek(-3, soFromCurrent);
          fsIn.Read(header, SizeOf(dword));
          mph.data := header;
        end; *)
        { Abbruchbedingung }
        if mph.error then break;
        { Frame lesen }
        Inc(frames);
        if fsIn.Position > (fsIn.Size div 3) then
        begin
          getMem(fbuf, mph.FrameSize - 4);
          fsIn.read(fbuf^, mph.FrameSize - 4);
          fsOut.Write(header, SizeOf(dword));
          fsOut.Write(fbuf^, mph.FrameSize - 4);
          FreeMem(fbuf, mph.FrameSize - 4);
          with mph do
            time := time + ((FrameSize - 4) / ((1024 * Bitrate) / 8));
        end
        else
          fsIn.Seek(mph.FrameSize - 4, soFromCurrent);
        if time > p_dur then break;
      until mph.error;
      if fsOut.Size < 1 then raise EAbort.Create(str_Emp3);
    finally
      if Assigned(fsIn) then fsIn.Free;
      if Assigned(fsOut) then fsOut.Free;
      if Assigned(mph) then mph.Free;
    end;
    if not fileexists(fnLameIn) then raise EPreview.Create(format('File not created (%s%s)', [verzeichnis, filen]));

    deletefile(fnLameOut);
    if fileexists(fnLameOut) then raise EPreview.Create('File readonly');
    { Lame Starten ... }
    if not ExecAndWait(file_lame,
      Format(p_param, [p_bitrate, fnLameIn, fnLameOut]),
      sw_hide) then raise EPreview.Create(Format(str_Elamemissing, [verzeichnis, filen]));
    if not fileexists(fnLameOut) then raise EPreview.Create(format(str_Elameerror, [verzeichnis, filen]));

    with dm, tblFiles do
    begin
        tblFilesBinPreview.LoadFromFile(fnLameOut);
    //      if tblPreviewBinPreview.Size < 1 then raise EAbort.Create('Datei ung�ltig.');
        tblFilesBKind.Value := pk_mp3;
        Inc(stat_preview);
    end;
  finally
    deletefile(fnLameIn);
    deletefile(fnLameOut);
  end;
end;

{procedure TfrmReadDisk.ext_importm3u(verzeichnis, filen: string; Options: integer);
(*var
  sl: TStringList;
  i: integer;
  s: string; *)
begin
  // not implemented
(*

  if not WordBool(Options and bit_playlists) then Exit;
  if fileexists(dm.tblFiles.DatabaseName + filen + '.lst') then
    if not WordBool(Options and bit__updateall) then Exit;

  sl := TStringList.Create;
  try
    sl.loadfromfile(verzeichnis + filen);
    i := 0;
    while i < sl.Count do
      if Copy(sl[i], 1, 1) = '#' then
        sl.Delete(i) else // Kommentare
      begin
        s := sl[i];
        if Copy(s, 1, 1) = '\' then s := Format('<%s>%s', [disklabel, s])
        else s := Format('<%s>%s%s', [disklabel, Copy(verzeichnis, 3, maxInt), s]);
        sl[i] := s;
        Inc(i);
      end;
    sl.savetofile(dm.tblFiles.DatabaseName + filen + '.lst');
  finally
    sl.Free;
  end;
  *)
end;
}

function TfrmReadDisk.doprevwork(verzeichnis, filen: string): Boolean;
var
  ext: string;
  info : string;

begin
  Result := True;
  with dm, tblFiles do
  begin
    info := InfExtr.ExtractInfo(verzeichnis+filen);
    tblFilesTextPreview.Value := info;
    tblFilesTKind.Value := pk_std;
//    tblFilesTKind.Value := pk_txt;
     if info <> '' then
        Inc(stat_info);
  end;

  ext := ansilowercase(extractfileext(filen));
  if (doimg) and ((ext = '.bmp') or (ext = '.ico') or (ext = '.jpg') or (ext = '.jpeg') or (ext = '.jpg') or (ext = '.jpe') or (ext = '.gif') or (ext = '.tif') or (ext = '.tiff')) then
    ext_picprev(verzeichnis, filen) else
      if (domp3) and ((ext = '.mp3') or (ext = '.mp2') or (ext = '.mp1') or (ext = '.mpa')) then
        ext_mp3preview(verzeichnis, filen);
{


  if ext = '.zip' then
    ext_zipnote(verzeichnis, filen, options) else
    if (ext = '.exe') or (ext = '.dll') or (ext = '.scr') or (ext = '.cpl') or (ext = '.vxd') or (ext = '.ocx') or (ext = '.bpl') or (ext = '.cpl') or (ext = '.drv') then
      ext_verinfo(verzeichnis, filen, options) else
          if (ext = '.htm') or (ext = '.html') or (ext = '.phtml') then
            ext_txtpreview(verzeichnis, filen, Options, true) else
            if (ext = '.txt') then
              ext_txtpreview(verzeichnis, filen, Options, false)
            else Result := False;
  }
end;

{ In tblFolders einen Datensatz mit "Autoinc" als Folder-Wert suchen und
  FOLDERID auslesen // nicht vorhanden: 0 }


procedure TfrmReadDisk.Loadautoinc;
var
  i, step : integer;
begin
  with dm.tblFolders do
  begin
    Filtered := False;
    step := 10000;
    i := 0;
    while step > 0 do
    begin
      repeat
        Inc(i,step);
        Filter := 'FOLDERID > ' + IntToStr(i);
        Filtered := True;
      until RecordCount = 0;
      Dec(i,step);
      step := step div 2;
    end;
    Filtered := False;
    CurFID := i + 1;
  end;
end;

{ CurFID speichern }
{ entf�llt }
{
procedure TfrmReadDisk.Saveautoinc;
begin
(*  with dm, tblFolders do
  begin
    First;
    if tblFoldersFolder.Value <> csid then
    begin
      Append;
      tblFoldersFolder.Value := csid;
      tblFoldersDISKID.Value := -1;
    end else Edit;
    tblFoldersFOLDERID.Value := -abs(CurFID);
    Post;
  end; *)
end;
}

{ 1. nicht-ASCII Zeichen (>127, <32) bis auf '�','�' etc. beseitigen }
{ 2. falls durch OemToAnsi weniger Zeichen beseitigt werden, dann
  OemToAnsi verwenden... }

function bestcharset(s: string): string;
const
  valid = [#32..#127, '�', '�', '�', '�', '�', '�', '�', #10, #13];
var
  i, j,
    invalid: integer;
  temp: string;
begin
  invalid := 0;
  for i := 1 to Length(s) do
    if not (s[i] in valid) then Inc(invalid);
  for i := 1 to Length(temp) do
    if not (temp[i] in valid) then dec(invalid);
  if invalid > 0 then { OemToAnsiStr war erfolgreich ... }
  else temp := s;
  j := 0;
  SetLength(Result, Length(temp));
  for i := 1 to Length(temp) do
    if s[i] in valid then
    begin
      Inc(j);
      Result[j] := s[i];
    end;
  SetLength(Result, j);
end;

{ descript.ion Datei in StringListen laden }

procedure loaddesc(fname: string; descfiles, descriptions: TStringList);
var
  sl: TStringList;
  s, fn, desc: string;
  i, idx: integer;

begin
  descfiles.sorted := True;
  sl := TStringList.Create;
  try
    sl.LoadFromFile(fname);
    for i := 0 to sl.Count - 1 do
    begin
      s := sl[i];
      if Copy(s, 1, 1) = '"' then { Dateinamen mit Leerzeichen etc. }
      begin
        idx := Pos('" ', s) + 2;
        fn := Copy(S, 2, idx - 4);
      end else
      begin
        idx := Pos(' ', s) + 1;
        fn := Copy(S, 1, idx - 1);
      end;
      if fn <> '' then
      begin
        desc := Copy(s, idx, maxInt);
        idx := descriptions.Add(desc);
        descfiles.addobject(ansilowercase(fn), TObject(idx));
      end;
    end;
  finally
    sl.Free;
  end;
end;

function TfrmReadDisk.FileMatchesMasks(fn:string;Masks:TStringList):Boolean;
var
  i : integer;
begin
  fn := ansilowercase(fn);
  Result := False;
  with Masks do
    for i := 0 to Count - 1 do
      if like(fn, Strings[i]) then
      begin
        Result := True;
        Exit;
      end;
end;

function TfrmReadDisk.ReadDir(Verzeichnis: string; DiskId: Longint): Int64;
var SR: TSearchRec;
  FolderId: integer;
  Groesse, ThisSize: Int64;
  res: integer;
  bookmark1, bookmark2: Pointer;
  hsf: Boolean; // hassubfolders
  i, idx, fileid: integer;

  idlist: TStringList;
  s: string;
  delfldr: string;
  descfiles, descriptions: TStringList;

  gotfileiddiz: Boolean;
  b : Boolean;
  dt : TDateTime;
begin
  Inc(stat_folders);

  Result := 0;
  if isabort then Exit;

  Groesse := 0;
  Inc(level);
  Verzeichnis := Verzeichnis + '\';


  pbScan.Position := Pg div 1024;
  updprogresscaption;
//  if Verzeichnis[length(Verzeichnis)]<>'\' then
  with dm, tblFolders do
  begin
    if updmode then SetKey else Append;
    tblFoldersDISKID.AsInteger := DiskId;
    tblFoldersFolder.AsString := Copy(Verzeichnis, 3, Length(Verzeichnis));
    if updmode then
    begin
      if GotoKey then begin
        FolderId := tblFoldersFolderId.AsInteger;
        Edit;
      end else
      begin
        Append;
        Inc(curfid);
        FolderId := CurFID;
        tblFoldersDISKID.AsInteger := DiskId;
        tblFoldersFolder.AsString := Copy(Verzeichnis, 3, Length(Verzeichnis));
      end;
    end else  // no Updatemode
    begin
      Inc(curfid);
      FolderId := CurFID;
    end;
    tblFoldersLevel.AsInteger := Level;
    tblFoldersFolderId.AsInteger := FolderId;
    Post;
    bookmark2 := getbookmark;
  end;
  try
    lblCurF.Caption := Verzeichnis;
//    Application.ProcessMessages;
    hsf := False;
    if True {not bool(opt_thisfolder and bit_noidx)} then
    begin
      s := Verzeichnis + 'descript.ion';
      if fileexists(s) then
      begin
        descriptions := TStringList.Create;
        descfiles := TStringList.Create;
        loaddesc(s, descfiles, descriptions)
      end else
      begin
        descriptions := nil;
        descfiles := nil;
      end;
      if updmode then { UPDATING }
      begin
        idlist := TStringList.Create;
        idlist.sorted := True;
//        with idlist do { List aufbauen; Zuordnung: Dateiname -> Index }
        begin { au�erdem: gr��te FileId suchen }
          { und: Dateien, die nicht mehr existieren l�schen }
          fileid := -1;
          delfldr := '';
          with dm, tblFiles do
          begin
            Filter :=
              Format('DISKID = %d and FOLDERID = %d', [DiskId, FolderId]);
            Filtered := True;
            First;
            while not eof do
            begin
              i := tblFilesFILEID.Value;
              s := Verzeichnis + tblFilesFileName.Value;
              if tblFilesEntryKind.Value = ek_folder then
                b := DirectoryExists(s)
              else
                b := fileexists(s);
              if b then
              begin
                idlist.AddObject(ansilowercase(tblFilesFileName.Value), TObject(i));
                if i > fileid then fileid := i;
                Next;
              end else
              begin
                if tblFilesEntryKind.Value = ek_folder then
                begin
                  with dm, tblFolders do
                  begin
                    s := LookUp('FOLDERID', FolderId, 'Folder') + tblFilesFileName.Value + '\';
                    SetKey;
                    tblFoldersDISKID.Value := diskid;
                    tblFoldersFolder.Value := s;
                    if GotoKey then
                    begin
                      delfldr := delfldr + tblFoldersFolderId.AsString + ',';
                    end else raise Exception.Create('Datenbankfehler, Databaseerror (ReadDisk/Delfldr)');
                    IndexName := '';
                    Filter := Format('FOLDER = ''%s'' and DISKID = %d', [s + '*', diskid]);
                    Filtered := True;
                    First;
                    while not eof do
                      Delete;
                    Filtered := False;
                  end;
                end;
                Delete;
              end;
            end;
            Filtered := False;
            if delfldr <> '' then { Markierte Ordner incl. Dateien entfernen }
            begin
              with dm, tblFiles do
              begin
                First;
                while not eof do
                  if Pos(tblFilesFolderId.AsString + ',', delfldr) <> 0 then Delete else Next;
              end;
            end;
            Inc(fileid);
          end;
        end;
      end else { kein Updateing }
      begin
        idlist := nil;
        fileid := 0;
      end;
//      lblState.Caption := str_index;

      res := FindFirst(Verzeichnis + '*.*', $3F, SR);
      try
        while res = 0 do
        begin
          if dbug then
            with MyFiles3Form.ColIni do
            begin
              WriteString(ini_colcleanup,ini_lastfile,Verzeichnis+sr.Name);
              UpdateFile;
            end;

          if (SR.Name <> '.') and (SR.Name <> '..') and (Bool(SR.Attr and faDirectory) or FileMatchesMasks(Verzeichnis+SR.Name,IncludeMasks)) then
//            if not bool(opt_file and bit_noidx) then { nur, wenn Datei auch indiziert werden soll }
            if not (((not Bool(SR.Attr and faDirectory)) and (nor0Byte) and (SR.Size = 0)) or
               ((norHidden) and (Bool(SR.Attr and faHidden) or Bool(SR.Attr and faHidden))) or
               FileMatchesMasks(Verzeichnis+SR.Name,norMasks)) then
            begin
              if Bool(SR.Attr and faDirectory) then
              begin { Folder }
                hsf := True;
                with dm, tblFiles do
                begin
                  if updmode then idx := idlist.indexof(ansilowercase(SR.Name)) else idx := -1;
                  if idx <> -1 then
                  begin
                    SetKey;
                    tblFilesDISKID.AsInteger := DiskId;
                    tblFilesFOLDERID.AsInteger := FolderId;
                    tblFilesFILEID.Value := integer(idlist.Objects[idx]);
                    GotoKey;
                    Edit;
                  end else
                  begin
                    Append;
                    Inc(fileid);
                    tblFilesDISKID.AsInteger := DiskId;
                    tblFilesFOLDERID.AsInteger := FolderId;
                    tblFilesFILEID.Value := FileId;
                  end;
                  tblFilesEntryKind.Value := ek_folder;
                  tblFilesFileName.AsString := SR.Name;
                  try
                    tblFilesChanged.AsDateTime := FileDateToDateTime(SR.Time);
                  except
                    tblFilesChanged.Clear;
                  end;
                  tblFilesAttr.Value := SR.Attr;
                  tblFilesSize.Value := -1;
                { FILE_ID.DIZ auslesen }
                  gotfileiddiz := False;
                  if optFileIDDiz then
                  begin
                    s := Format('%s%s\file_id.diz', [verzeichnis, sr.Name]);
                    if fileexists(s) then { Datei existiert + Notiz ist leer bzw. updateall }
                      if (tblFilesNote.IsNull) or (optUpdatePrev) then
                      begin
                        gotfileiddiz := True;
                        tblFilesNote.LoadFromFile(s);
                        tblFilesNote.AsString := bestcharset(tblFilesNote.AsString);
                      end;
                  end;
                { DESCRIPT.ION auslesen }
                  if not gotfileiddiz then
                    if (optDESCRIPTION) and Assigned(descfiles) then
                      if (tblFilesNote.IsNull) or (optUpdatePrev) then
                      begin
                        idx := descfiles.indexof(ansilowercase(sr.Name));
                        if idx <> -1 then tblFilesNote.AsString := descriptions[integer(descfiles.Objects[idx])];
                      end;
                  Post;
                  bookmark1 := GetBookmark;
                  try
                  { Recurse Folder }
                    i := stat_files;
                    ThisSize := ReadDir(Verzeichnis + SR.Name, DiskId);
                    Groesse := Groesse + ThisSize;
                    gotobookmark(bookmark1);
                  finally
                    freebookmark(bookmark1);
                  end;
                  if (norEmptyFolders) and (i = stat_files) then Delete else
                  begin
                    Edit;
                    tblFilesSize.Value := ThisSize;
                    Post;
                  end;
                end;
              end
              else
                begin { File }
                  Inc(pg, sr.Size);
                  Groesse := Groesse + SR.Size;
                  with dm, tblFiles do
                  begin
                    if updmode then idx := idlist.indexof(SR.Name) else idx := -1;
                    if idx <> -1 then
                    begin
                      SetKey;
                      tblFilesDISKID.AsInteger := DiskId;
                      tblFilesFOLDERID.AsInteger := FolderId;
                      tblFilesFILEID.Value := integer(idlist.Objects[idx]);
                      GotoKey;
                      Edit;
                    end else
                    begin
                      Append;
                      Inc(fileid);
                      tblFilesDISKID.AsInteger := DiskId;
                      tblFilesFOLDERID.AsInteger := FolderId;
                      tblFilesFILEID.Value := FileId;
                    end;
                    tblFilesEntryKind.Value := ek_file;
                    tblFilesFileName.AsString := SR.Name;
                    tblFilesAttr.Value := SR.Attr;
                    tblFilesSize.Value := SR.Size;
      (*          assignfile(f,'c:\win98\desktop\log.txt');
                  append(f);
                  writeln(f,verzeichnis+sr.Name);
                  closefile(f);
      *)
                    if isabort then Exit;
                    try
                      try
                        dt := FileDateToDateTime(SR.Time);
                      except
                        dt := 0;
                      end;
                    { Entweder: Normalmodus
                      oder: updatemode + (�nderung oder (alles �berschreiben oder garkeine Vorschau bisher)) }
//                      if (ansilowercase(extractfileext(sr.Name))) = '.m3u' then
//                        ext_importm3u(verzeichnis, sr.Name, opt_file);
                      if (not updmode) or ((updmode) and
                        ((tblFilesChanged.AsDateTime <> dt)
                        or (optUpdatePrev) or ((tblFilesTKind.Value = 0) and (tblFilesBKind.Value = 0)))) then
                        if doprevwork(verzeichnis, sr.Name) then
                        begin
                          pbScan.Position := Pg div 1024;
                          updprogresscaption;
                        end;
                    except
                      on E: EPreview do lblErr.Caption := E.Message;
                    else ;
                    end;
                    try
                      tblFilesChanged.AsDateTime := FileDateToDateTime(SR.Time);
                    except
                      tblFilesChanged.Clear;
                    end;

                    if optDESCRIPTION and Assigned(descfiles) then
                      if (tblFilesNote.IsNull) or (optUpdatePrev) then
                      begin
                        idx := descfiles.indexof(ansilowercase(sr.Name));
                        if idx <> -1 then tblFilesNote.AsString := descriptions[integer(descfiles.Objects[idx])];
                      end;

                    Post;
                    Inc(stat_files);
                    doStats;
                  end;
                end;
              end;
          res := FindNext(SR);
        end;
      finally
        FindClose(SR);
        if Assigned(idlist) then idlist.Free;
        if Assigned(descfiles) then descfiles.Free;
        if Assigned(descriptions) then descriptions.Free;
      end;
    end else
      lblState.Caption := str_rignore;
    with dm, tblFolders do
    begin
      GotoBookmark(bookmark2);
      Edit;
      tblFoldersHasSubFolders.Value := hsf;
      Post;
    end;
  finally
    dm.tblFolders.FreeBookmark(bookmark2);
  end;

  Dec(Level);
  Result := Groesse;
end;


{ Sortproc: umgekehrt nach L�nge sortieren }{ geh�rt zu slfolderopt }

function sortcompare_lengthD(List: TStringList; Index1, Index2: Integer): Integer; far;
var
  a, b: integer;
begin
  a := Length(List[index1]);
  b := Length(List[index2]);
  if a > b then Result := -1 else
    if a < b then Result := 1 else Result := 0;
end;

{ slfolderopt / slfileopt mit den aktuellen Daten aus tvOpt best�cken }

(*
procedure TfrmReadDisk.buildoptions;
var
  i: integer;
begin
  slfolderopt := TStringList.Create;
  slfileopt := TStringList.Create;
  with tvOpt.Items[0] do
    for i := 1 to Count - 1 do
      slFolderOpt.AddObject(Item[i].Text, TObject(Item[i].StateIndex));
  with tvOpt.Items[0].GetNextSibling do
    for i := 1 to Count - 1 do
      slFileOpt.AddObject(Item[i].Text, TObject(Item[i].StateIndex));
  slfolderopt.customsort(sortcompare_lengthD);
  slfileopt.customsort(sortcompare_lengthD);
end;

*)

procedure TfrmReadDisk.ReadThis(drive: char);
var
  bookmark: Pointer;
  Size: Int64;
  i : integer;
var
  Msg: string;
begin
  stat_folders := 0;
  stat_files := 0;
  stat_info := 0;
  stat_preview := 0;
  lastdone := 0; laststat := 0; lFolders := 0; lFiles := 0; lInfo := 0; lPreview := 0;
  optFileIDDiz := ckFILEIDDIZ.Checked;
  optUpdatePrev := ckUpdatePrev.Checked;
  optDESCRIPTION := ckDescriptION.Checked;
  nor0Byte  := ckIg0Byte.Checked;
  norHidden := ckIgHidden.Checked;
  norEmptyFolders := ckIgEmptyFolder.Checked;
  norMasks.CommaText := cbIgFiles.Text;
  IncludeMasks.CommaText := cbIncludeFiles.Text;
  for i := 0 to norMasks.Count-1 do
    norMasks[i] := ansilowercase(norMasks[i]);
  for i := 0 to IncludeMasks.Count-1 do
    IncludeMasks[i] := ansilowercase(IncludeMasks[i]);

  Msg := ' ' + str_readgen + ' ';
  with dm do
  begin
    if cbStapel.Checked then
      disklabel := MyFiles3Form.MyVolumeID(drive)
    else disklabel := edtLabel.Text;
    if disklabel = '' then
      raise Exception.Create('Fehler: ReadThis, DiskLabel Empty');
    tblDisks.DisableControls;
    tblFolders.DisableControls;
    tblFiles.DisableControls;
    tblFiles.Filtered := False;
    tblFolders.Filtered := False;
    tblDisks.Filtered := False;

    with tblDisks do
    begin
      IndexName := 'IdxLabel';
      SetKey;
      tblDisksLabel.Value := disklabel;
      if gotokey <> updmode then
        if not updmode then
          raise EPreReadDisk.Create(str_diskexists) else
          raise EPreReadDisk.Create(str_diskmis);
    end;

    disablefrm;
    if not MyFiles3Form.ColIni.ReadBool('Options','UseLabel',False) then
    begin
      if cbStapel.Checked then
        MyFiles3Form.ColIni.WriteString(ini_labels, VolumeSN(Drive), MyFiles3Form.MyVolumeId(Drive))
      else
        MyFiles3Form.ColIni.WriteString(ini_labels, VolumeSN(Drive), edtLabel.Text);
    end;
    running := True;
    anim.Active := True;
    isabort := False;
    if not updmode then
    begin
      tblDisks.Append;
      tblDisksLABEL.AsString := disklabel;
      tblDisks.Post;
    end;
    bookmark := tblDisks.GetBookMark;
    level := 0;
    lblCurF.Caption := '';
    if updmode then
    begin
      gbStat.Caption := Format(Msg, [tblDisksLABEL.AsString, str_readupd1]);
//      lblState.Caption := str_readupd0;
    end else
    begin
      gbStat.Caption := Format(Msg, [tblDisksLABEL.AsString, str_readnew1]);
//      lblState.Caption := str_readnew0;
    end;

    pbScan.Max := DiskSize(Ord(drive) - ord('A') + 1) div 1024;
    if pbScan.Max = 0 then pbScan.Max := 1;
    pg := 0;

    with MyFiles3Form.ini do
    begin
      p_dur := ReadInteger(ini_config, ini_ph_duration, 3);
      p_bitrate := ReadString(ini_config, ini_ph_qual, '16kbps');
      p_param := ReadString(ini_config, ini_ph_param, '--mp3input -m mono -a -b %0:s -o %1:s %2:s');
      p_maxw := ReadInteger(ini_config, ini_pb_width, 63);
      p_maxh := ReadInteger(ini_config, ini_pb_height, 63);
      p_qual := ReadInteger(ini_config, ini_pb_qual, 39);
    end;
    ReadDiskid := tblDisksDISKID.AsInteger;
    MyFiles3Form.ColIni.WriteString(ini_colcleanup,IntToStr(ReadDiskid),DiskLabel);
    MyFiles3Form.ColIni.UpdateFile;
    Size := ReadDir( drive + ':', tblDisksDISKID.AsInteger);
    tblDisks.GotoBookMark(bookmark);
    tblDisks.FreeBookMark(bookmark);
    tblDisks.Edit;
    tblDisksSIZE.Value := Size;
    tblDisksREAD.Value := now;
    tblDisks.Post;

    dm.SaveChanges;
    tblDisks.EnableControls;
    tblFolders.EnableControls;
    tblFiles.EnableControls;
    running := False;
    MyFiles3Form.ColIni.EraseSection(ini_colcleanup);
  end;
end;

procedure TfrmReadDisk.disablefrm;
var
  i : integer;
begin
  for i := 0 to tsOptions.ControlCount -1 do
    (tsOptions.Controls[i] as TControl).Enabled := False;
  tsStatus.TabVisible := True;
  gbStat.Show;
end;

procedure TfrmReadDisk.btnStartClick(Sender: TObject);
var
  i: integer;
  drv: char;
  drives, s, lastlog, log: string;

begin
  ModalResult := mrNone;
  if not cbStapel.Checked then
  begin
    if not updmode then
      with dm, tblDisks do
      begin
        IndexName := 'IdxLabel';
        SetKey;
        tblDisksLabel.Value := edtLabel.Text;
        if GotoKey then
        begin
          Application.messagebox(PChar(str_cantrename),
            PChar(str_error), mb_ICONERROR or MB_OK);
          Exit;
        end;
      end;

    s := MyFiles3Form.ini.ReadString(ini_colpre + MyFiles3Form.curcol, 'drives', '');
    if Pos(DriveSelct, s) = 0 then
    case
      Application.MessageBox('Soll das gew�hlte Laufwerk in Zukunft �berwacht werden, um'+#13#10+
                             'Datentr�ger wiederzuerkennen und Dateien direkt aus MyFindex �ffnen'+#13#10+
                             'zu k�nnen?','Einlesen',mb_yesnocancel or mb_iconquestion) of
      idYes :
      begin
        s := s + DriveSelct;
        MyFiles3Form.ini.WriteString(ini_colpre + MyFiles3Form.curcol, 'drives', s);
        MyFiles3Form.tmrDrivestateTimer(nil);
      end;
      idCancel : Exit;
    end;
  end;
  { Info Definitionen (PlugIns.Eigenschaften) aus ListView -> TInfoExtractor }
  with InfExtr do
  begin
    InfoDef.Clear;
    with lvUsedPlugins do
      for i := 0 to Items.Count - 1 do
        InfoDef.AddObject( Items[i].Caption, Items[i].Data );
  end;

  Tag := 1;
  with MyFiles3Form do
  begin
    mNotesExit(nil);
    if Assigned(notedb) then
      notedb.freebookmark(notebm);
    notedb := nil;
  end;
  lvDrives.Enabled := False;
  edtLabel.Enabled := False;
  btnStart.Enabled := False;
  lblPreset.Enabled := False;

  if updmode then btnCancel.Enabled := False;
  cbStapel.Enabled := False;

  doimg := ckImgPrev.Checked;
  domp3 := ckMP3Prev.Checked;

  try
    if not cbStapel.Checked  then
    begin { Ein Datentr�ger }
      tooktime := GetTickCount;
//        buildoptions;
      LoadAutoinc;
      try
        readthis(DriveSelct);
      except
        on EPreReadDisk do raise
      else isabort := True;
      end;
      if isabort then modalResult := mrAbort
      else begin
        tooktime := GetTickCount - tooktime;
        disksread := 1;
        modalResult := mrOk;
      end;
    end else
    begin { BATCH-Mode }
      pnlWait.Show;
      disablefrm;
      disksread := 0;
      lastlog := '';
      tooktime := GetTickCount;
      finish := False;
//        buildoptions;
      repeat
        drv := '*';
        log := '';
        drives := '';
        with lvDrives do
          for i := 0 to Items.Count-1 do
            with Items[i] do
              if Checked then
                drives := drives + Copy(Caption,Length(Caption)-2,1);

//        with MyFiles3Form do
//          drives := ini.ReadString(ini_colpre + curcol, 'drives', '');
        for i := 1 to Length(drives) do
        begin
          s := MyFiles3Form.MyVolumeID(drives[i]);
          if s <> '*' then
            with dm, tblDisks do
            begin
              IndexName := 'IdxLabel';
              SetKey;
              tblDisksLabel.Value := s;
              if not gotokey then
              begin
                drv := drives[i];
                break;
              end;
//                  log := log + Format(str_autor1 + #13#10, [drives[i], s]);
            end// else log := log + Format(str_autor2 + #13#10, [drives[i]]);
        end;
        if (drv = '*') or (isabort) then
        begin
          Application.processmessages;
          btnCancel.hide;
          btnFinish.show;
        end else
        begin
          btnCancel.show;
          btnFinish.hide;
          loadautoinc;
          try
            pnlWait.Hide;
            readthis(drv);
            Application.title := 'Warten...';            
            Inc(disksread);
          except
            on E: Exception do begin
              isabort := True;
            end;
          end;
          if not isabort then begin gbStat.Caption := ' Statisik '; pnlWait.show; lblEject.Show; lastdone := 0; doStats; Application.ProcessMessages; ejectdrive(drv); lblEject.Hide;  end;
        end;
      until isabort or finish;

      if isabort then modalResult := mrAbort
      else begin
        tooktime := GetTickCount - tooktime;
        modalResult := mrOk;
      end;
    end;
  finally
    btnStart.Enabled := True;
    cbStapel.Enabled := True;
    lvDrives.Enabled := True;
    edtLabel.Enabled := True;
    lblPreset.Enabled := True;
    Tag := 0;
  end;
end;

procedure TfrmReadDisk.InitDriveListView;
var
  i: integer;
  uebwdrives, drives: string;
begin
  uebwdrives := MyFiles3Form.ini.ReadString('Collection.' + MyFiles3Form.curcol, 'Drives', '');
  drives := uebwdrives;
  for i := Ord('A') to Ord('Z') do
    if Pos(chr(i), drives) = 0 then
      drives := drives + chr(i);
  lvDrives.Checkboxes := True;
  with lvDrives.Items do
  begin
    Clear;
    for i := 1 to Length(drives) do
      with Add do
      begin
        Caption := '('+drives[i]+':)';
        case GetDriveType(PChar(drives[i]+':\')) of
          DRIVE_RAMDISK: ImageIndex := 5;
          DRIVE_REMOVABLE: ImageIndex:=4;
          DRIVE_REMOTE: ImageIndex := 3;
          DRIVE_FIXED : ImageIndex := 2;
          DRIVE_CDROM : ImageIndex := 1;
          else ImageIndex := 0;
        end;
        Checked := Pos(drives[i],uebwdrives) <> 0;
      end;
  end;
  lvDrives.Checkboxes := False;
  lvDrives.Items[0].selected := true;
  ListView_SetIconSpacing(lvDrives.Handle, 64 + 16, 0);
  Listview_arrange(lvDrives.Handle, LVA_DEFAULT);

(*  cbDrive.ItemIndex := 0;
  cbDriveChange(nil); *)
end;

procedure TfrmReadDisk.FormCreate(Sender: TObject);
var
  dir : string;
begin
  MyFiles3Form.GimmeXP(Self);
  slfolderopt := TStringList.Create;
  dbug := False;

  QueryCancelAutoPlay := RegisterWindowMessage('QueryCancelAutoPlay');

  icF.picture.icon.Handle := LoadIcon(hInstance, PChar(504));
  icB.picture.icon.Handle := LoadIcon(hInstance, PChar(505));

  InitDriveListView;
  LoadPlugIns;

  dir := dir_templ;
  od.InitialDir := dir;
  sd.InitialDir := dir;
  LoadSettings( dir + 'default.myo' );
  InfExtr := TInfoExtractor.Create;
  norMasks := TStringList.Create;
  IncludeMasks := TStringList.Create;
//  readoptlist;
end;

procedure TfrmReadDisk.btnCancelClick(Sender: TObject);
begin
  if running then isabort := True;
  modalresult := mrCancel;
end;

function clb2int(clb: TCheckListBox): integer;
var
  i, max: Byte;
begin
  Result := 0;
  if clb.Items.Count > 32 then max := 32 else max := clb.Items.Count;
  for i := 0 to max - 1 do
    if clb.Checked[i] then
      Result := Result + trunc(IntPower(2, i));
end;

procedure int2clb(clb: TCheckListBox; int: integer);
var
  i, max: Byte;
begin
  if clb.Items.Count > 32 then max := 32 else max := clb.Items.Count;
  for i := 0 to max - 1 do
    clb.Checked[i] := int and trunc(IntPower(2, i)) <> 0;
end;

procedure TfrmReadDisk.tvOptEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  allowedit := Node.StateIndex > -1;
end;

procedure TfrmReadDisk.btnFinishClick(Sender: TObject);
begin
  finish := True;
end;

procedure TfrmReadDisk.edtLabelKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in LabelForbiddenChars then Key := #0;
end;

procedure TfrmReadDisk.edtLabelChange(Sender: TObject);
begin
  with edtLabel do
    if Text <> Filter(Text,LabelForbiddenChars) then
      Text := Filter(Text,LabelForbiddenChars);
end;

procedure TfrmReadDisk.cbStapelClick(Sender: TObject);
begin
  with lvDrives do
  begin
    LargeImages := ImageList2;
    Checkboxes := cbStapel.Checked;
    LargeImages := ilDrives;
    gbLabel.Visible := not cbStapel.Checked;
    btnStart.Enabled := cbStapel.Checked or (DriveSelct <> '*');
  end;
end;

procedure TfrmReadDisk.lvDrivesChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  lbl: string;
begin
  lbl := MyFiles3Form.MyVolumeId(DriveSelct);
  if lbl = '*' then
  begin
    btnStart.Enabled := cbStapel.Checked;
//    Exit;
  end else
    btnStart.Enabled := lbl <> '*';
  with edtLabel do
    if lbl = '*' then
    begin
      Text := str_nodisc;
      Enabled := False;
    end
    else
    begin
      Text := lbl;
      Font.Color := clWindowText;
      Enabled := True;
      ReadOnly := False;
      edtLabel.ReadOnly :=
        (MyFiles3Form.ColIni.ReadString(ini_labels, VolumeSN(DriveSelct), '*') <> '*') or
        MyFiles3Form.ColIni.ReadBool('Options','UseLabel',False);
 (*     if not updmode then
      begin
        with dm, tblDisks do
        begin
          IndexName := 'IdxLabel';
          SetKey;
          tblDisksLabel.Value := edtLabel.Text;
          if gotokey then edtLabel.ReadOnly := True;
        end;
      end
      else ReadOnly := True; *)
    end;
  gbLabel.Caption := ' Datentr�ger in '+DriveSelct+': ';
end;

procedure TfrmReadDisk.DebugModus1Click(Sender: TObject);
begin
  dbug := True;
  if Pos('Debugmodus',Caption) = 0 then
    Caption := Caption + ' - Debugmodus';
  Application.messagebox(
    'Der Debugmodus wurde aktiviert.'#13#10+
    'Lies nun den verd�chtigen Datentr�ger mit den gleichen Optionen ein,'#13#10+
    'die du beim Absturz von MyFindex gew�hlt hattest.'#13#10+
    'Falls MyFindex aufgrund von defekten Dateien auf dem Datentr�ger erneut'#13#10+
    'abst�rzen sollte, starte MyFindex neu, w�hle die aktuelle Sammlung und'#13#10+
    'folge den Anweisungen.','Debugmodus', mb_ICONINFORMATION or MB_OK);
end;

procedure TfrmReadDisk.fbAddClick(Sender: TObject);

  procedure AddMe(tn:TTreeNode);
  var
    i : integer;
  begin
    with lvUsedPlugins.Items do
    begin
      for i := 0 to Count -1 do
        if (Item[i].Caption = tn.Text) and (Item[i].Data = tn.Data) then
        begin
          Item[i].Selected := True;
          Exit;
        end;
      with Add do
      begin
        Data := tn.Data;
        Caption := tn.Text;
        SubItems.Add(tn.Parent.Text);
        Selected := True;
      end;
    end;
  end;

var
  i,j : integer;
begin
  lvUsedPlugins.Selected := nil;
  with tvInstalled do
    if Sender = menAddAll then
    begin
      for i := 0 to Items.Count-1 do
        with Items[i] do
          for j := 0 to Count-1 do
            AddMe(Item[j]);
    end else
      if Assigned(Selected) then
        with Selected do
          case level of
            0 : for i := 0 to Count-1 do
                  AddMe(Item[i]);
            1 : AddMe(tvInstalled.Selected);
          end;
  lvUsedPluginsSelectItem(nil,nil,True);
end;

procedure TfrmReadDisk.lvUsedPluginsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  fbDel.Enabled := Selected;
  fbPDown.Enabled := (lvUsedPlugins.SelCount = 1) and (lvUsedPlugins.Selected.Index < lvUsedPlugins.Items.Count-1);
  fbPUp.Enabled := (lvUsedPlugins.SelCount = 1) and (lvUsedPlugins.Selected.Index > 0);
  menDel.Enabled := Selected;
end;

procedure TfrmReadDisk.fbDelClick(Sender: TObject);
var
  i : integer;
begin
  with lvUsedPlugins.Items do
    for i := Count-1 downto 0 do
      with Item[i] do
        if Selected then Delete;
//  lvUsedPluginsSelectItem(nil,nil,false);
end;

procedure TfrmReadDisk.menPlugConfigClick(Sender: TObject);
begin
  with tvInstalled do
    if Assigned(Selected) then
      TMyPlugIn(Selected.Data).Config;
end;

procedure TfrmReadDisk.menPlugAboutClick(Sender: TObject);
begin
  with tvInstalled do
    if Assigned(Selected) then
      if Selected.StateIndex = -1 then
        TMyPlugIn(Selected.Data).About;
end;

procedure TfrmReadDisk.pmInstalledPopup(Sender: TObject);
begin
  with tvInstalled do
    if Assigned(Selected) then
    case Selected.StateIndex of
      -1 :
      begin
        menPlugConfig.Enabled := TMyPlugIn(Selected.Data).CanConfig;
        menPlugAbout.Enabled := TMyPlugIn(Selected.Data).CanAbout;
      end;
      -211,-212 :
      begin
        menPlugConfig.Enabled := True;
        menPlugAbout.Enabled := False;
      end;
      else begin
        menPlugConfig.Enabled := False;
        menPlugAbout.Enabled := False;
      end;
    end;
end;

procedure TfrmReadDisk.LoadPlugins;
var
  i,j : integer;
  newitem,child : TTreeNode;
  sl : TStringList;
begin
  sl := TStringList.Create;
  try
    with MyFiles3Form.PlugIns do
      for i := 0 to Count-1 do
      begin
        newitem := tvInstalled.Items.Add(nil, Items[i].Caption);
        newitem.data := Items[i];
        newitem.ImageIndex := 1;
        newitem.SelectedIndex := 1;
        sl.Clear;
        Items[i].AddAllFieldsTo(sl);
        for j := 0 to sl.Count-1 do
        begin
          child := tvInstalled.Items.AddChild(newitem, sl[j]);
          child.Data := Items[i];
        end;
      end;
   finally
     sl.Free;
   end;
end;

procedure TfrmReadDisk.fbPUpClick(Sender: TObject);
var
  sel, old : TListItem;
begin
  sel := lvUsedPlugIns.Selected;
  old := lvUsedPlugins.Items[sel.Index-1];
  with lvUsedPlugins.Items.Insert(sel.Index+1) do
  begin
    data := old.data;
    Caption := old.Caption;
    SubItems.Add(old.Subitems[0]);
  end;
  old.Delete;
  lvUsedPluginsSelectItem(nil,nil,True);
  sel.MakeVisible(False);
end;

procedure TfrmReadDisk.fbPDownClick(Sender: TObject);
var
  sel, old : TListItem;
begin
  sel := lvUsedPlugIns.Selected;
  old := lvUsedPlugins.Items[sel.Index+1];
  with lvUsedPlugins.Items.Insert(sel.Index) do
  begin
    data := old.data;
    Caption := old.Caption;
    SubItems.Add(old.Subitems[0]);
  end;
  old.Delete;
  lvUsedPluginsSelectItem(nil,nil,True);
  sel.MakeVisible(False);  
end;

function TfrmReadDisk.PlugInsToString:string;
var
  sl : TStringList;
  i : integer;
begin
  sl := TStringList.Create;
  with lvUsedPlugins do
  try
    for i := 0 to Items.Count - 1 do
      sl.Add( TMyPlugin(Items[i].Data).ID + '.'+ Items[i].Caption );
     result := sl.commatext;
  finally
    sl.Free;
  end;

end;

procedure TfrmReadDisk.tvInstalledChange(Sender: TObject; Node: TTreeNode);
begin
  with tvInstalled do
  begin
    if Assigned(Selected) then
      begin
(*        with Selected do
          case level of
            0 : lblSelected.Caption := Format('%s (Alle)',[Text]);
            1 : lblSelected.Caption := Format('%s.%s',[Parent.Text, Text]);
          end; *)
          fbAdd.Enabled := True;
          menAdd.Enabled := True;
          menPlug.Enabled := True;
      end
        else
      begin
//        lblSelected.Caption := '';
        fbAdd.Enabled := False;
        menAdd.Enabled := False;
        menPlug.Enabled := False;
      end;
  end;
end;

procedure TfrmReadDisk.fbBasisOrdnerClick(Sender: TObject);
begin
  fd.execute;
end;

procedure TfrmReadDisk.PlugInsFromString(const str:string);
var
  sl : TStringList;
  i : integer;
  plug, prop : string;
  pi : TMyPlugin;

begin
  lvUsedPlugins.Items.Clear;
  if str = '*' then fbAddClick(menAddAll) else
  begin
    sl := TStringList.Create;
    with lvUsedPlugins do
    try
      sl.Commatext := str;
      for i := 0 to sl.Count - 1 do
      begin
        plug := Copy(sl[i],1,5);
        prop := Copy(sl[i],7,maxInt);

        pi := MyFiles3Form.PlugIns.ByID[plug];
        if Assigned(pi) then
        with lvUsedPlugins.Items do
        begin
          with Add do
          begin
            Data := pi;
            Caption := prop;
            SubItems.Add(pi.Caption);
          end;
        end;
      end;
    finally
      sl.Free;
    end;
  end;
end;

procedure TfrmReadDisk.cbIgFilesButtonClick(Sender: TObject);
var
  MousePos : TPoint;
begin
  with TfrmBegriffe.Create(Self) do
  try
    GetCursorPos(MousePos);
    Left := MousePos.x - 5;
    Top := MousePos.y - 5;
    lbList.Items.CommaText := (Sender as TComboEdit).Text;
    pnlHead.Caption := 'Dateimasken';
    lblCount.Visible := False;
    if ShowModal = mrOK then
      (Sender as TComboEdit).Text := lbList.Items.CommaText;
  finally
    Free;
  end;
end;

procedure TfrmReadDisk.tbOpenClick(Sender: TObject);
begin
  with od do
    if Execute then
      LoadSettings(FileName);
end;


procedure TfrmReadDisk.LoadSettings(FileName: string);
begin
  with TIniFile.Create(FileName) do
  try
    ckFILEIDDIZ.Checked := ReadBool('Options','FileIDDIZ',True);
    ckDescriptION.Checked := ReadBool('Options','DescriptION',True);
    cbIncludeFiles.Text := ReadString('Options','Files','*.*');
    ckIgHidden.Checked := ReadBool('Ignore','Hidden',True);
    ckIg0Byte.Checked := ReadBool('Ignore','0Byte',False);
    ckIgEmptyFolder.Checked := ReadBool('Ignore','EmptyFolder',False);
    cbIgFiles.Text := ReadString('Ignore','Files','*.~*,*.tmp');
    PlugInsFromString( ReadString('Preview','PlugIns','*') );
    ckMP3Prev.Checked := ReadBool('Preview','MP3',True);
    ckImgPrev.Checked := ReadBool('Preview','Img',True);
  finally
    Free;
  end;
  sd.FileName := FileName;
  od.FileName := FileName;
  lblPreset.Caption := ExtractFileName(ChangeFileExt(FileName,''));  
end;

procedure TfrmReadDisk.SaveSettings(FileName: string);
begin
  with TIniFile.Create(FileName) do
  try
    WriteBool('Options','FileIDDIZ',ckFILEIDDIZ.Checked);
    WriteBool('Options','DescriptION',ckDescriptION.Checked);
    WriteString('Options','Files',cbIncludeFiles.Text);
    WriteBool('Ignore','Hidden',ckIgHidden.Checked);
    WriteBool('Ignore','0Byte',ckIg0Byte.Checked);
    WriteBool('Ignore','EmptyFolder',ckIgEmptyFolder.Checked);
    WriteString('Ignore','Files',cbIgFiles.Text);
    WriteString('Preview','PlugIns',PlugInsToString);
    WriteBool('Preview','MP3',ckMP3Prev.Checked);
    WriteBool('Preview','Img',ckImgPrev.Checked);
  finally
    Free;
  end;
  lblPreset.Caption := ExtractFileName(ChangeFileExt(FileName,''));
end;

procedure TfrmReadDisk.tbSaveClick(Sender: TObject);
begin
  with sd do
  begin
    if FileName = '' then FileName := 'default.myo';
    if Execute then
      SaveSettings(FileName);
  end;
end;

procedure TfrmReadDisk.FormDestroy(Sender: TObject);
begin
  slfolderopt.Free;
  InfExtr.Free;
end;

procedure TfrmReadDisk.fbCfgGenClick(Sender: TObject);
begin
  MyFiles3Form.menConfigClick(Sender);
end;

procedure TfrmReadDisk.doStats;
begin
  if laststat < GetTickCount - 5000 then
  begin
    laststat := GetTickCount;
    lblsstatFolders.Caption := Format('%.1n/s',[(stat_Folders - lFolders) / 5]);
    lblsstatFiles.Caption := Format('%.0n/s',[(stat_Files - lFiles) / 5]);
    lblsstatInfos.Caption := Format('%.1n/s',[(stat_Info - lInfo) / 5]);
    lblsstatPreview.Caption := Format('%.1n/s',[(stat_Preview - lPreview) / 5]);
    lFolders := stat_Folders;
    lFiles := stat_Files;
    lInfo := stat_Info;
    lPreview := stat_Preview;
  end;
  if lastdone < GetTickCount - 500 then
  begin
    lastdone := GetTickCount;
    lblstatFolders.Caption := Format('%.0n',[stat_Folders * 1.0]);
    lblstatFiles.Caption := Format('%.0n',[stat_Files * 1.0]);
    lblstatInfos.Caption := Format('%.0n',[stat_Info * 1.0]);
    lblstatPreview.Caption := Format('%.0n',[stat_Preview * 1.0]);
    Application.ProcessMessages;
  end;
end;

procedure TfrmReadDisk.edtLabelExit(Sender: TObject);
begin
  edtLabel.Text := trim(edtLabel.Text);
end;

procedure TfrmReadDisk.updprogresscaption;
const
  percent : integer = 0;
var
  p : integer;
begin
  p := round((pbScan.Position / pbScan.Max) * 100);
  if (percent > p) or (p > percent + 2) then
    Application.Title := Format(str_readstatus,[p]);
end;

initialization
  TPicture.RegisterFileFormat('jpe', 'JPEG-Grafikdatei', TJPEGImage);
finalization
  TPicture.UnRegisterGraphicClass(TJPEGImage);

end.
