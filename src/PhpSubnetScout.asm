; PHP Subnet Scout - native x86 Win32 / FASM. No CRT or bundled runtime.
format PE GUI 5.0
entry start
include 'win32ax.inc'

WORKERS = 32
PORT_COUNT = 10
R_SIZE = 64
R_IP = 0
R_PORT = 4
R_HTTP = 8
R_PHP = 12
R_ERROR = 16
R_MS = 20
R_DETAIL = 24
R_DONE = 28
R_WSA = 32
R_STAGE = 36
R_PEER = 40
D_SERVER = 0
D_POWER = 256
D_COOKIE = 768
D_LOCATION = 1792
D_RAW = 2816
D_SIZE = 68352
WM_RESULT = 8000h+1
WM_FINISHED = 8000h+2
LVM_SETBKCOLOR = 1001h
LVM_SETTEXTCOLOR = 1024h
LVM_SETTEXTBKCOLOR = 1026h
LVM_SETEXTENDEDLISTVIEWSTYLE = 1036h
LVM_GETHEADER = 101Fh

section '.data' data readable writeable
  appTitle db 'PHP Subnet Scout 1.2.0',0
  className db 'PhpSubnetScout.Main',0
  titleText db 'PHP SUBNET SCOUT',0
  hintText db 'HTTP: 80, 81, 5000, 8000, 8008, 8080, 8081, 8888   |   HTTPS: 443, 8443   |   32 parallel',0
  cidrLabel db '&Doel: subnet, IP of FQDN',0
  timeoutLabel db '&Timeout/poort (ms)',0
  scanText db '&Scannen',0
  stopText db 'S&toppen',0
  exportText db '&Exporteer CSV',0
  detectText db '&Detecteer',0
  themeDark db '&Thema: donker',0
  themeLight db '&Thema: licht',0
  tlsOff db 'TLS-controle: &uit',0
  tlsOn db 'TLS-controle: &aan',0
  filters dd filterWeb,filterPHP,filterAll
  filterWeb db '&Filter: overzicht',0
  filterPHP db '&Filter: PHP',0
  filterAll db '&Filter: problemen',0
  noteText db 'PHP: header = bevestigd, PHPSESSID = indicatie. Geen signaal betekent onbekend. HTTPS gebruikt standaard geen certificaatcontrole.',0
  readyText db 'Gereed. Lokaal subnet standaard; ook externe IP-adressen en FQDN werken. Redirects blijven uit.',0
  invalidText db 'Gebruik IPv4, IPv6, een DNS-servernaam/FQDN of een IPv4-subnet /16 t/m /32. Geen URL, poort of pad. Timeout: 250 t/m 30000 ms.',0
  detectFail db 'Geen actieve IPv4-interface gevonden. Vul zelf een lokaal CIDR-subnet in.',0
  memFail db 'Onvoldoende geheugen of Windows kan geen scanworker starten.',0
  saveFail db 'CSV opslaan mislukt. Controleer pad, vrije ruimte en schrijfrechten.',0
  exported db 'CSV opgeslagen (alle afgeronde endpoints, inclusief fouten en time-outs).',0
  detailEmpty db 'Selecteer een resultaat voor URL, detectiebewijs, TLS-instelling en ontvangen HTTP-headers.',0
  timeoutDefault db '2000',0
  empty db 0
  editClass db 'EDIT',0
  staticClass db 'STATIC',0
  buttonClass db 'BUTTON',0
  listClass db 'SysListView32',0
  fontName db 'Segoe UI',0
  monoName db 'Consolas',0
  colNames dd colIP,colPort,colHTTP,colPHP,colEvidence,colServer,colMs,colStatus
  colWidths dd 130,65,60,110,230,180,80,220
  colIP db 'Doel',0
  colPort db 'Poort',0
  colHTTP db 'HTTP',0
  colPHP db 'PHP',0
  colEvidence db 'Detectiebewijs',0
  colServer db 'Server',0
  colMs db 'Tijd (ms)',0
  colStatus db 'Resultaat',0
  phpUnknown db 'Onbekend',0
  phpHeader db 'Bevestigd',0
  phpCookie db 'Indicatie',0
  evidenceNone db 'Geen PHP-signaal',0
  evidenceHeader db 'PHP in X-Powered-By / Server',0
  evidenceCookie db 'Set-Cookie: PHPSESSID',0
  resultOK db 'HTTP ontvangen',0
  resultTimeout db 'Time-out',0
  resultStopped db 'Afgebroken',0
  resultError db 'Netwerk/TLS-fout',0
  resultRefused db 'Geen verbinding',0
  resultDenied db 'Uitgaand lokaal geweigerd',0
  resultDNS db 'DNS-resolutie mislukt',0
  resultDNSTimeout db 'DNS-timeout',0
  resultTCPTimeout db 'TCP-timeout; oorzaak onbekend',0
  resultTCPRefused db 'Verbinding geweigerd',0
  resultUnreachable db 'Netwerk/doel onbereikbaar',0
  diagOK db 0
  diagDenied db 'Windows weigert de uitgaande verbinding. Mogelijke oorzaak: lokale firewall, endpointbeleid of toegangsbeperking. Geen specifieke firewallregel vastgesteld.',0
  diagTCP db 'Geen TCP-verbinding tot stand gekomen. Uitgaande, tussenliggende of doelfirewall, routing en doelbereikbaarheid zijn niet van elkaar te onderscheiden zonder aanvullend bewijs.',0
  diagRefused db 'Een TCP-weigering is ontvangen. Dit kan van de doelserver of een netwerkfilter komen; geen bewijs voor een uitgaande firewallblokkade.',0
  diagDNS db 'De servernaam kon niet tijdig worden vertaald. Controleer naam, DNS-server, DNS-bereikbaarheid en eventuele DNS-filtering.',0
  diagAfterConnect db 'TCP-verbinding is tot stand gekomen. De fout ontstond daarna bij TLS of HTTP; geen bewijs voor een geblokkeerde uitgaande TCP-poort.',0
  stageNames dd stageDNS,stageConnect,stageConnected,stageHTTP,stageHeaders
  stageDNS db 'DNS / aanvraag voorbereiden',0
  stageConnect db 'TCP verbinden',0
  stageConnected db 'TCP verbonden / TLS',0
  stageHTTP db 'HTTP-aanvraag / headers',0
  stageHeaders db 'HTTP-headers ontvangen',0
  fmtIP db '%u.%u.%u.%u',0
  fmtCIDR db '%s/%u',0
  fmtUInt db '%u',0
  fmtError db 'Fout %u',0
  fmtURL db '%s://%s:%u/',0
  fmtURL6 db '%s://[%s]:%u/',0
  fmtLiteral6 db '[%s]',0
  schemeHTTP db 'http',0
  schemeHTTPS db 'https',0
  fmtProgress db '%s | %u / %u endpoints | %u websites | %u PHP-signalen | %u s',0
  progressRunning db 'Scannen',0
  progressStopped db 'Gestopt',0
  progressDone db 'Klaar',0
  fmtDetails db '%s',13,10,'Resultaat: %s | HTTP %u | %u ms | WinHTTP %u | Winsock %u',13,10,'Adres: %s | Fase: %s',13,10,'%s',13,10,'PHP: %s - %s',13,10,'HTTPS-certificaatcontrole: %s | redirects: uit | proxy: uit',13,10,13,10,0
  tlsChecked db 'aan',0
  tlsUnchecked db 'uit (inventarisatie; identiteit niet geverifieerd)',0
  tlsNA db 'n.v.t. (HTTP)',0
  csvHeader db 0EFh,0BBh,0BFh,'"Target","IP","Port","URL","HTTPStatus","PHP","Evidence","Server","XPoweredBy","Location","ElapsedMs","Result","WinHTTPError","TLSCertificateValidation","RawHeaders","WinsockError","ConnectionStage","ConnectionDiagnostic"',13,10,0
  quote db '"',0
  comma db ',',0
  newline db 13,10,0
  csvFilter db 'CSV-bestanden (*.csv)',0,'*.csv',0,0
  csvExt db 'csv',0
  csvName db 'php-subnet-scan.csv',0
  agent du 'PHPSubnetScout/1.2',0
  verb du 'GET',0
  rootPath du '/',0
  headerPower du 'X-Powered-By',0
  headerCookie du 'Set-Cookie',0
  headerServer du 'Server',0
  headerLocation du 'Location',0
  needlePHP db 'PHP',0
  needleSession db 'PHPSESSID=',0
  darkTheme du 'DarkMode_Explorer',0
  lightTheme du 'Explorer',0
  ; Ten selected general-purpose web ports; rationale and sources: docs/PORT_RESEARCH.md.
  ports dd 80,443,8080,8888,81,8443,8000,8008,5000,8081
  ; COLORREF values, mapped from jaap-design-language semantic tokens.
  paletteDark dd 001C1714h,002B2420h,00F6F4F1h,00B3A79Eh,00473C35h
  paletteLight dd 00F8F5F3h,00FCFAF8h,002A2017h,0072655Bh,00D8D0C9h
  accent dd 002E98FFh
  onAccent dd 001D1815h
  bgColor dd ?
  controlColor dd ?
  textColor dd ?
  mutedColor dd ?
  borderColor dd ?
  bgBrush dd ?
  controlBrush dd ?
  accentBrush dd ?
  font dd ?
  monoFont dd ?
  titleFont dd ?
  hInstance dd ?
  hWnd dd ?
  hHeap dd ?
  hCIDR dd ?
  hTimeout dd ?
  hScan dd ?
  hStop dd ?
  hExport dd ?
  hDetect dd ?
  hTheme dd ?
  hTLS dd ?
  hFilter dd ?
  hList dd ?
  hHeader dd ?
  headerOld dd ?
  hDetail dd ?
  hStatus dd ?
  hTitle dd ?
  hHint dd ?
  hCIDRLabel dd ?
  hTimeoutLabel dd ?
  hNote dd ?
  dark dd 1
  strictTLS dd 0
  scanTLS dd 0
  filterMode dd 0
  dpi dd 96
  running dd 0
  stopFlag dd 0
  closePending dd 0
  rows dd 0
  total dd 0
  hostStart dd 0
  hostCount dd 0
  nextJob dd -1
  completed dd 0
  webCount dd 0
  phpCount dd 0
  liveWorkers dd 0
  scanStart dd 0
  scanElapsed dd 0
  timeoutMs dd 2000
  workersReady dd 0
  createFailed dd 0
  preferredIndex dd 0
  chosenAdapter dd 0
  scanMode dd 0 ; 0=IPv4/CIDR, 1=DNS name, 2=IPv6 literal
  parsedMode dd 0
  icc dd 8,1
  workArea RECT
  cidrBuf rb 256
  scanName rb 256
  numberBuf rb 32
  statusBuf rb 512
  detailBuf rb 70000
  fileName rb 1024
  csvField rb 131100
  csvWide rw 131100
  csvUTF8 rb 393300
  csvFile dd ?
  csvOkay dd ?
  written dd ?
  wc WNDCLASS
  msg MSG

  ofn OPENFILENAME

section '.text' code readable executable
start:
  ; System DPI awareness is declared in the application manifest.
  invoke GetModuleHandle,0
  mov [hInstance],eax
  invoke GetProcessHeap
  mov [hHeap],eax
  invoke InitCommonControlsEx,icc
  invoke GetDC,0
  mov ebx,eax
  invoke GetDeviceCaps,ebx,88
  mov [dpi],eax
  invoke ReleaseDC,0,ebx
  stdcall Scale,16
  neg eax
  invoke CreateFont,eax,0,0,0,400,0,0,0,1,0,0,5,0,fontName
  mov [font],eax
  stdcall Scale,14
  neg eax
  invoke CreateFont,eax,0,0,0,400,0,0,0,1,0,0,5,0,monoName
  mov [monoFont],eax
  stdcall Scale,22
  neg eax
  invoke CreateFont,eax,0,0,0,600,0,0,0,1,0,0,5,0,fontName
  mov [titleFont],eax
  mov [wc.style],CS_HREDRAW or CS_VREDRAW
  mov [wc.lpfnWndProc],WndProc
  mov eax,[hInstance]
  mov [wc.hInstance],eax
  mov [wc.lpszClassName],className
  invoke LoadCursor,0,IDC_ARROW
  mov [wc.hCursor],eax
  invoke LoadIcon,[hInstance],1
  mov [wc.hIcon],eax
  invoke RegisterClass,wc
  stdcall Scale,1220
  mov ebx,eax
  stdcall Scale,780
  mov esi,eax
  invoke SystemParametersInfo,48,0,workArea,0 ; SPI_GETWORKAREA: fit the initial window at high DPI.
  test eax,eax
  jz .window
  mov eax,[workArea.right]
  sub eax,[workArea.left]
  sub eax,16
  cmp ebx,eax
  jbe @f
  mov ebx,eax
@@:
  mov eax,[workArea.bottom]
  sub eax,[workArea.top]
  sub eax,16
  cmp esi,eax
  jbe .window
  mov esi,eax
.window:
  invoke CreateWindowEx,0,className,appTitle,WS_OVERLAPPEDWINDOW or WS_VISIBLE,CW_USEDEFAULT,CW_USEDEFAULT,ebx,esi,0,0,[hInstance],0
  mov [hWnd],eax
.loop:
  invoke GetMessage,msg,0,0,0
  test eax,eax
  jz .exit
  invoke IsDialogMessage,[hWnd],msg
  test eax,eax
  jnz .loop
  invoke TranslateMessage,msg
  invoke DispatchMessage,msg
  jmp .loop
.exit:
  invoke ExitProcess,0

proc Scale value
  invoke MulDiv,[value],[dpi],96
  ret
endp

; Create the standard controls in tab order. Layout() applies DPI-scaled geometry.
proc Control cls,txt,style,id
  invoke CreateWindowEx,0,[cls],[txt],[style],0,0,1,1,[hWnd],[id],[hInstance],0
  push eax
  invoke SendMessage,eax,WM_SETFONT,[font],TRUE
  pop eax
  ret
endp

proc WndProc uses ebx esi edi,hwnd,message,wparam,lparam
  local rc:RECT, ps:PAINTSTRUCT, lv:LV_ITEM, dim:RECT
  mov eax,[message]
  cmp eax,WM_CREATE
  je .create
  cmp eax,WM_SIZE
  je .size
  cmp eax,WM_GETMINMAXINFO
  je .minsize
  cmp eax,WM_COMMAND
  je .command
  cmp eax,WM_DRAWITEM
  je .draw
  cmp eax,WM_CTLCOLORSTATIC
  je .colors
  cmp eax,WM_CTLCOLOREDIT
  je .colors
  cmp eax,WM_CTLCOLORLISTBOX
  je .colors
  cmp eax,WM_ERASEBKGND
  je .erase
  cmp eax,WM_NOTIFY
  je .notify
  cmp eax,WM_RESULT
  je .result
  cmp eax,WM_FINISHED
  je .finished
  cmp eax,WM_TIMER
  je .timer
  cmp eax,WM_CLOSE
  je .close
  cmp eax,WM_DESTROY
  je .destroy
  invoke DefWindowProc,[hwnd],[message],[wparam],[lparam]
  ret
.create:
  mov eax,[hwnd]
  mov [hWnd],eax
  stdcall Control,staticClass,titleText,WS_CHILD or WS_VISIBLE,0
  mov [hTitle],eax
  invoke SendMessage,eax,WM_SETFONT,[titleFont],TRUE
  stdcall Control,staticClass,hintText,WS_CHILD or WS_VISIBLE,0
  mov [hHint],eax
  stdcall Control,staticClass,cidrLabel,WS_CHILD or WS_VISIBLE,0
  mov [hCIDRLabel],eax
  stdcall Control,editClass,empty,WS_CHILD or WS_VISIBLE or WS_TABSTOP or WS_BORDER or ES_AUTOHSCROLL,101
  mov [hCIDR],eax
  invoke SendMessage,eax,EM_SETLIMITTEXT,253,0
  stdcall Control,buttonClass,detectText,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_OWNERDRAW,102
  mov [hDetect],eax
  stdcall Control,staticClass,timeoutLabel,WS_CHILD or WS_VISIBLE,0
  mov [hTimeoutLabel],eax
  stdcall Control,editClass,timeoutDefault,WS_CHILD or WS_VISIBLE or WS_TABSTOP or WS_BORDER or ES_NUMBER,103
  mov [hTimeout],eax
  invoke SendMessage,eax,EM_SETLIMITTEXT,5,0
  stdcall Control,buttonClass,scanText,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_OWNERDRAW,104
  mov [hScan],eax
  stdcall Control,buttonClass,stopText,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_OWNERDRAW,105
  mov [hStop],eax
  invoke EnableWindow,eax,FALSE
  stdcall Control,buttonClass,exportText,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_OWNERDRAW,106
  mov [hExport],eax
  stdcall Control,buttonClass,filterWeb,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_OWNERDRAW,107
  mov [hFilter],eax
  stdcall Control,buttonClass,tlsOff,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_OWNERDRAW,108
  mov [hTLS],eax
  stdcall Control,buttonClass,themeDark,WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_OWNERDRAW,109
  mov [hTheme],eax
  stdcall Control,staticClass,noteText,WS_CHILD or WS_VISIBLE,0
  mov [hNote],eax
  stdcall Control,listClass,empty,WS_CHILD or WS_VISIBLE or WS_TABSTOP or WS_BORDER or LVS_REPORT or LVS_SINGLESEL or LVS_SHOWSELALWAYS,110
  mov [hList],eax
  invoke SendMessage,eax,LVM_SETEXTENDEDLISTVIEWSTYLE,0,LVS_EX_FULLROWSELECT or 00010000h
  stdcall InitColumns
  invoke SendMessage,[hList],LVM_GETHEADER,0,0
  mov [hHeader],eax
  invoke SetWindowLong,eax,GWL_WNDPROC,HeaderProc
  mov [headerOld],eax
  stdcall Control,editClass,detailEmpty,WS_CHILD or WS_VISIBLE or WS_TABSTOP or WS_BORDER or ES_MULTILINE or ES_READONLY or WS_VSCROLL or ES_AUTOVSCROLL,111
  mov [hDetail],eax
  invoke SendMessage,eax,WM_SETFONT,[monoFont],TRUE
  stdcall Control,staticClass,readyText,WS_CHILD or WS_VISIBLE,0
  mov [hStatus],eax
  stdcall ApplyTheme
  stdcall DetectSubnet
  invoke SetTimer,[hwnd],1,200,0
  xor eax,eax
  ret
.size:
  stdcall Layout
  xor eax,eax
  ret
.minsize:
  mov ebx,[lparam]
  stdcall Scale,1120
  mov [ebx+24],eax
  stdcall Scale,650
  mov [ebx+28],eax
  xor eax,eax
  ret
.command:
  mov eax,[wparam]
  and eax,0FFFFh
  cmp eax,102
  je .detect
  cmp eax,104
  je .scan
  cmp eax,105
  je .stop
  cmp eax,106
  je .export
  cmp eax,107
  je .filter
  cmp eax,108
  je .tls
  cmp eax,109
  je .theme
  cmp eax,IDCANCEL
  je .stop
  cmp eax,IDOK
  je .scan
  xor eax,eax
  ret
.detect:
  stdcall DetectSubnet
  jmp .zero
.scan:
  cmp [running],0
  jne .zero
  stdcall BeginScan
  jmp .zero
.stop:
  mov [stopFlag],1
  jmp .zero
.export:
  cmp [running],0
  jne .zero
  stdcall ExportCSV
  jmp .zero
.filter:
  inc [filterMode]
  cmp [filterMode],3
  jb @f
  mov [filterMode],0
@@:
  mov eax,[filterMode]
  invoke SetWindowText,[hFilter],[filters+eax*4]
  stdcall RebuildList
  jmp .zero
.tls:
  cmp [running],0
  jne .zero
  xor [strictTLS],1
  mov eax,tlsOff
  cmp [strictTLS],0
  je @f
  mov eax,tlsOn
@@:
  invoke SetWindowText,[hTLS],eax
  jmp .zero
.theme:
  xor [dark],1
  stdcall ApplyTheme
  jmp .zero
.colors:
  invoke SetTextColor,[wparam],[textColor]
  invoke SetBkColor,[wparam],[bgColor]
  mov eax,[lparam]
  cmp eax,[hCIDR]
  je .inputcolor
  cmp eax,[hTimeout]
  je .inputcolor
  cmp eax,[hDetail]
  je .inputcolor
  mov eax,[bgBrush]
  ret
.inputcolor:
  invoke SetBkColor,[wparam],[controlColor]
  mov eax,[controlBrush]
  ret
.erase:
  invoke GetClientRect,[hwnd],addr rc
  invoke FillRect,[wparam],addr rc,[bgBrush]
  mov eax,1
  ret
.draw:
  stdcall DrawButton,[lparam]
  mov eax,1
  ret
.notify:
  mov ebx,[lparam]
  mov eax,[ebx]
  cmp eax,[hList]
  jne .zero
  cmp dword [ebx+8],LVN_ITEMCHANGED
  jne .zero
  mov eax,[ebx+20] ; NMLISTVIEW.uNewState (iSubItem is at +16)
  test eax,LVIS_SELECTED
  jz .zero
  mov [lv.mask],LVIF_PARAM
  mov eax,[ebx+12]
  mov [lv.iItem],eax
  mov [lv.iSubItem],0
  invoke SendMessage,[hList],LVM_GETITEM,0,addr lv
  test eax,eax
  jz .zero
  stdcall ShowDetails,[lv.lParam]
  jmp .zero
.result:
  cmp [closePending],0
  jne .zero
  stdcall AddRow,[lparam]
  jmp .zero
.finished:
  mov [running],0
  invoke GetTickCount
  sub eax,[scanStart]
  mov [scanElapsed],eax
  invoke EnableWindow,[hScan],TRUE
  invoke EnableWindow,[hDetect],TRUE
  invoke EnableWindow,[hCIDR],TRUE
  invoke EnableWindow,[hTimeout],TRUE
  invoke EnableWindow,[hExport],TRUE
  invoke EnableWindow,[hTLS],TRUE
  invoke EnableWindow,[hStop],FALSE
  stdcall Progress
  cmp [stopFlag],0
  jne @f
  mov eax,[completed]
  cmp eax,[total]
  je @f
  invoke SetWindowText,[hStatus],memFail
@@:
  cmp [closePending],0
  je .zero
  invoke DestroyWindow,[hwnd]
  jmp .zero
.timer:
  cmp [running],0
  je .zero
  stdcall Progress
  jmp .zero
.close:
  cmp [running],0
  je @f
  mov [closePending],1
  mov [stopFlag],1
  invoke SetWindowText,[hStatus],progressStopped
  jmp .zero
@@:
  invoke DestroyWindow,[hwnd]
  jmp .zero
.destroy:
  invoke PostQuitMessage,0
.zero:
  xor eax,eax
  ret
endp

proc Place hwnd,x,y,w,h
  local xx:DWORD,yy:DWORD,ww:DWORD
  stdcall Scale,[x]
  mov [xx],eax
  stdcall Scale,[y]
  mov [yy],eax
  stdcall Scale,[w]
  mov [ww],eax
  stdcall Scale,[h]
  invoke MoveWindow,[hwnd],[xx],[yy],[ww],eax,TRUE
  ret
endp

proc Layout uses ebx esi
  local r:RECT, width:DWORD,height:DWORD
  invoke GetClientRect,[hWnd],addr r
  invoke MulDiv,[r.right],96,[dpi]
  mov [width],eax
  invoke MulDiv,[r.bottom],96,[dpi]
  mov [height],eax
  stdcall Place,[hTitle],16,12,400,30
  stdcall Place,[hHint],16,48,900,22
  stdcall Place,[hCIDRLabel],16,80,240,20
  stdcall Place,[hCIDR],16,102,230,30
  stdcall Place,[hDetect],254,102,100,30
  stdcall Place,[hTimeoutLabel],370,80,150,20
  stdcall Place,[hTimeout],370,102,92,30
  stdcall Place,[hScan],478,102,106,30
  stdcall Place,[hStop],592,102,100,30
  stdcall Place,[hExport],700,102,132,30
  stdcall Place,[hTheme],848,102,156,30
  stdcall Place,[hFilter],16,148,162,30
  stdcall Place,[hTLS],190,148,156,30
  mov eax,[width]
  sub eax,370
  stdcall Place,[hNote],362,147,eax,38
  mov ebx,[width]
  sub ebx,32
  mov esi,[height]
  sub esi,400
  stdcall Place,[hList],16,192,ebx,esi
  mov esi,[height]
  sub esi,196
  stdcall Place,[hDetail],16,esi,ebx,148
  mov esi,[height]
  sub esi,36
  stdcall Place,[hStatus],16,esi,ebx,24
  ret
endp

proc InitColumns uses ebx
  local col:LV_COLUMN
  xor ebx,ebx
.loop:
  mov [col.mask],LVCF_TEXT or LVCF_WIDTH or LVCF_SUBITEM
  mov eax,[colNames+ebx*4]
  mov [col.pszText],eax
  mov [col.iSubItem],ebx
  stdcall Scale,[colWidths+ebx*4]
  mov [col.cx],eax
  invoke SendMessage,[hList],LVM_INSERTCOLUMN,ebx,addr col
  inc ebx
  cmp ebx,8
  jb .loop
  ret
endp

proc ApplyTheme uses ebx esi edi
  cmp [bgBrush],0
  je @f
  invoke DeleteObject,[bgBrush]
  invoke DeleteObject,[controlBrush]
  invoke DeleteObject,[accentBrush]
@@:
  mov esi,paletteDark
  mov ebx,darkTheme
  mov edx,themeDark
  cmp [dark],0
  jne @f
  mov esi,paletteLight
  mov ebx,lightTheme
  mov edx,themeLight
@@:
  invoke SetWindowText,[hTheme],edx
  mov edi,bgColor
  mov ecx,5
  rep movsd
  invoke CreateSolidBrush,[bgColor]
  mov [bgBrush],eax
  invoke CreateSolidBrush,[controlColor]
  mov [controlBrush],eax
  invoke CreateSolidBrush,[accent]
  mov [accentBrush],eax
  invoke SetWindowTheme,[hList],ebx,0
  invoke SetWindowTheme,[hCIDR],ebx,0
  invoke SetWindowTheme,[hTimeout],ebx,0
  invoke SetWindowTheme,[hDetail],ebx,0
  invoke SendMessage,[hList],LVM_SETBKCOLOR,0,[controlColor]
  invoke SendMessage,[hList],LVM_SETTEXTBKCOLOR,0,[controlColor]
  invoke SendMessage,[hList],LVM_SETTEXTCOLOR,0,[textColor]
  invoke DwmSetWindowAttribute,[hWnd],20,dark,4
  invoke DwmSetWindowAttribute,[hWnd],34,borderColor,4
  mov eax,[bgColor]
  cmp [dark],0
  jne @f
  mov eax,00FFFFFFh
@@:
  push eax
  mov eax,esp
  invoke DwmSetWindowAttribute,[hWnd],35,eax,4
  pop eax
  invoke DwmSetWindowAttribute,[hWnd],36,textColor,4
  invoke RedrawWindow,[hWnd],0,0,RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN
  ret
endp

proc DrawButton uses ebx esi edi,di
  local r:RECT,txt[96]:BYTE,old:DWORD,pen:DWORD
  mov ebx,[di]
  mov esi,[ebx+24] ; hDC
  lea edi,[ebx+28] ; rcItem
  mov eax,[controlBrush]
  test dword [ebx+16],ODS_DISABLED
  jnz .buttonFill
  cmp dword [ebx+4],104
  jne @f
  mov eax,[accentBrush]
@@:
.buttonFill:
  invoke FillRect,esi,edi,eax
  invoke GetWindowText,dword [ebx+20],addr txt,96
  invoke SelectObject,esi,[font]
  mov [old],eax
  invoke SetBkMode,esi,TRANSPARENT
  mov eax,[textColor]
  cmp dword [ebx+4],104
  jne @f
  mov eax,[onAccent]
@@:
  test dword [ebx+16],ODS_DISABLED
  jz @f
  mov eax,[mutedColor]
@@:
  invoke SetTextColor,esi,eax
  invoke DrawText,esi,addr txt,-1,edi,DT_CENTER or DT_VCENTER or DT_SINGLELINE
  test dword [ebx+16],ODS_FOCUS or ODS_SELECTED
  jz .done
  invoke FrameRect,esi,edi,[accentBrush]
  invoke DrawFocusRect,esi,edi
.done:
  invoke SelectObject,esi,[old]
  ret
endp

proc HeaderProc uses ebx esi,hwnd,message,wparam,lparam
  local ps:PAINTSTRUCT,r:RECT,old:DWORD
  cmp [message],WM_PAINT
  jne .default
  invoke BeginPaint,[hwnd],addr ps
  mov esi,eax
  invoke GetClientRect,[hwnd],addr r
  invoke FillRect,esi,addr r,[controlBrush]
  invoke SelectObject,esi,[font]
  mov [old],eax
  invoke SetTextColor,esi,[textColor]
  invoke SetBkMode,esi,TRANSPARENT
  xor ebx,ebx
.loop:
  invoke SendMessage,[hwnd],1207h,ebx,addr r ; HDM_GETITEMRECT
  add [r.left],8
  sub [r.right],4
  invoke DrawText,esi,[colNames+ebx*4],-1,addr r,DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS
  inc ebx
  cmp ebx,8
  jb .loop
  invoke SelectObject,esi,[old]
  invoke EndPaint,[hwnd],addr ps
  xor eax,eax
  ret
.default:
  invoke CallWindowProc,[headerOld],[hwnd],[message],[wparam],[lparam]
  ret
endp

; Strict unsigned decimal; advances ESI, returns EAX; CF on overflow/empty.
proc Decimal uses ebx ecx
  xor eax,eax
  xor ecx,ecx
.next:
  movzx ebx,byte [esi]
  sub ebx,'0'
  cmp ebx,9
  ja .done
  cmp eax,429496729
  ja .bad
  jne @f
  cmp ebx,5
  ja .bad
@@:
  imul eax,10
  add eax,ebx
  inc esi
  inc ecx
  jmp .next
.done:
  test ecx,ecx
  jz .bad
  clc
  ret
.bad:
  stc
  ret
endp

; Validate without DNS/network activity. Names are resolved asynchronously by WinHTTP.
proc ParseTarget uses ebx esi edi
  local address[16]:BYTE
  mov [parsedMode],0
  mov esi,numberBuf
  stdcall Decimal
  jc .bad
  cmp byte [esi],0
  jne .bad
  cmp eax,250
  jb .bad
  cmp eax,30000
  ja .bad
  mov [timeoutMs],eax
  mov esi,cidrBuf
  xor ebx,ebx ; alphabetic/hyphen present
.classify:
  mov al,[esi]
  test al,al
  jz .kind
  cmp al,':'
  je .ipv6
  cmp al,'/'
  je .ipv4
  cmp al,'A'
  jb @f
  cmp al,'Z'
  jbe .namechar
@@:
  cmp al,'a'
  jb @f
  cmp al,'z'
  jbe .namechar
@@:
  cmp al,'-'
  jne .continue
.namechar:
  mov ebx,1
.continue:
  inc esi
  jmp .classify
.kind:
  test ebx,ebx
  jz .ipv4
  mov esi,cidrBuf
  xor edi,edi ; length of current DNS label
  xor ebx,ebx ; total length
.hostname:
  mov al,[esi]
  test al,al
  jz .nameend
  cmp al,'.'
  je .dot
  cmp al,'-'
  je .hyphen
  cmp al,'0'
  jb .bad
  cmp al,'9'
  jbe .accept
  cmp al,'A'
  jb .bad
  cmp al,'Z'
  jbe .accept
  cmp al,'a'
  jb .bad
  cmp al,'z'
  ja .bad
  jmp .accept
.hyphen:
  test edi,edi
  jz .bad
.accept:
  inc edi
  cmp edi,63
  ja .bad
  jmp .advance
.dot:
  test edi,edi
  jz .bad
  cmp byte [esi-1],'-'
  je .bad
  xor edi,edi
.advance:
  inc esi
  inc ebx
  cmp ebx,253
  ja .bad
  jmp .hostname
.nameend:
  test ebx,ebx
  jz .bad
  cmp byte [esi-1],'-'
  je .bad
  mov [parsedMode],1
  jmp .single
.ipv6:
  invoke InetPtonA,23,cidrBuf,addr address
  cmp eax,1
  jne .bad
  mov [parsedMode],2
.single:
  mov [hostStart],0
  mov [hostCount],1
  mov [total],PORT_COUNT
  mov eax,1
  ret
.ipv4:
  stdcall ParseCIDR
  ret
.bad:
  xor eax,eax
  ret
endp

proc ParseCIDR uses ebx esi edi
  mov esi,cidrBuf
  xor edi,edi
  mov ebx,4
.octet:
  stdcall Decimal
  jc .bad
  cmp eax,255
  ja .bad
  shl edi,8
  or edi,eax
  dec ebx
  jz .prefix
  cmp byte [esi],'.'
  jne .bad
  inc esi
  jmp .octet
.prefix:
  mov ebx,32
  cmp byte [esi],0
  je .unicast
  cmp byte [esi],'/'
  jne .bad
  inc esi
  stdcall Decimal
  jc .bad
  cmp byte [esi],0
  jne .bad
  cmp eax,16
  jb .bad
  cmp eax,32
  ja .bad
  mov ebx,eax
.unicast:
  mov eax,edi
  shr eax,24
  test eax,eax
  jz .bad
  cmp eax,224
  jae .bad
.local:
  mov ecx,32
  sub ecx,ebx
  mov edx,1
  shl edx,cl
  mov eax,0FFFFFFFFh
  shl eax,cl
  and edi,eax
  cmp ebx,31
  jae @f
  inc edi
  sub edx,2
@@:
  mov [hostStart],edi
  mov [hostCount],edx
  imul edx,PORT_COUNT
  mov [total],edx
  mov eax,1
  ret
.bad:
  xor eax,eax
  ret
endp

proc FormatIP uses ebx,ip,outbuf
  mov eax,[ip]
  movzx edx,al
  shr eax,8
  movzx ecx,al
  shr eax,8
  movzx ebx,al
  shr eax,8
  cinvoke wsprintf,[outbuf],fmtIP,eax,ebx,ecx,edx
  ret
endp

proc TargetText row,outbuf
  cmp [scanMode],0
  jne .named
  mov eax,[row]
  stdcall FormatIP,dword [eax+R_IP],[outbuf]
  ret
.named:
  invoke lstrcpyn,[outbuf],scanName,256
  ret
endp

; The observed peer address is separate from the entered DNS name.
proc PeerText row,outbuf
  mov edx,[row]
  mov eax,[edx+R_PEER]
  test eax,eax
  jnz .copy
  cmp [scanMode],1
  je .unknown
  stdcall TargetText,[row],[outbuf]
  ret
.unknown:
  mov eax,empty
.copy:
  invoke lstrcpyn,[outbuf],eax,80
  ret
endp

proc DetectSubnet uses ebx esi edi
  local bytes:DWORD,buffer:DWORD,ipbuf[32]:BYTE,prefix:DWORD
  mov [bytes],0
  mov [preferredIndex],0
  invoke GetBestInterface,08080808h,preferredIndex
  invoke GetAdaptersInfo,0,addr bytes
  cmp eax,111
  jne .fail
  invoke HeapAlloc,[hHeap],HEAP_ZERO_MEMORY,[bytes]
  test eax,eax
  jz .fail
  mov [buffer],eax
  invoke GetAdaptersInfo,eax,addr bytes
  test eax,eax
  jnz .freeFail
  mov esi,[buffer]
  mov [chosenAdapter],0
.adapter:
  cmp dword [esi+416],24 ; loopback
  je .next
  lea eax,[esi+432] ; IpAddressList.IpAddress.String
  cmp byte [eax],'0'
  je .next
  cmp [chosenAdapter],0
  jne @f
  mov [chosenAdapter],esi
@@:
  mov eax,[esi+412]
  cmp eax,[preferredIndex]
  jne .next
  mov [chosenAdapter],esi
  jmp .found
.next:
  mov esi,[esi]
  test esi,esi
  jnz .adapter
.found:
  mov esi,[chosenAdapter]
  test esi,esi
  jz .freeFail
  lea eax,[esi+432]
  invoke inet_addr,eax
  mov edi,eax
  lea eax,[esi+448] ; IpMask.String
  invoke inet_addr,eax
  and edi,eax
  bswap eax
  xor ecx,ecx
.mask:
  test eax,eax
  jz .maskdone
  shl eax,1
  jnc .freeFail
  inc ecx
  jmp .mask
.maskdone:
  mov [prefix],ecx
  bswap edi
  stdcall FormatIP,edi,addr ipbuf
  cinvoke wsprintf,cidrBuf,fmtCIDR,addr ipbuf,[prefix]
  invoke SetWindowText,[hCIDR],cidrBuf
  invoke HeapFree,[hHeap],0,[buffer]
  ret
.freeFail:
  invoke HeapFree,[hHeap],0,[buffer]
.fail:
  invoke SetWindowText,[hStatus],detectFail
  ret
endp

proc FreeResults uses ebx esi
  cmp [rows],0
  je .done
  xor ebx,ebx
  mov esi,[rows]
.loop:
  cmp ebx,[total]
  jae .free
  mov eax,[esi+R_DETAIL]
  test eax,eax
  jz @f
  invoke HeapFree,[hHeap],0,eax
@@:
  mov eax,[esi+R_PEER]
  test eax,eax
  jz @f
  invoke HeapFree,[hHeap],0,eax
@@:
  add esi,R_SIZE
  inc ebx
  jmp .loop
.free:
  invoke HeapFree,[hHeap],0,[rows]
  mov [rows],0
.done:
  ret
endp

proc BeginScan uses ebx esi
  ; Validate into scratch globals only after retaining previous result extent.
  local previousTotal:DWORD
  mov eax,[total]
  mov [previousTotal],eax
  invoke GetWindowText,[hCIDR],cidrBuf,256
  invoke GetWindowText,[hTimeout],numberBuf,32
  stdcall ParseTarget
  test eax,eax
  jz .invalid
  mov esi,[total]
  mov eax,[previousTotal]
  mov [total],eax
  invoke SendMessage,[hList],LVM_DELETEALLITEMS,0,0
  invoke SetWindowText,[hDetail],detailEmpty
  stdcall FreeResults
  mov eax,[parsedMode]
  mov [scanMode],eax
  invoke lstrcpy,scanName,cidrBuf
  mov [total],esi
  mov eax,esi
  shl eax,6
  invoke HeapAlloc,[hHeap],HEAP_ZERO_MEMORY,eax
  test eax,eax
  jz .mem
  mov [rows],eax
  mov [completed],0
  mov [webCount],0
  mov [phpCount],0
  mov [nextJob],-1
  mov [stopFlag],0
  mov [workersReady],0
  mov [createFailed],0
  mov [liveWorkers],0
  mov eax,[strictTLS]
  mov [scanTLS],eax
  invoke GetTickCount
  mov [scanStart],eax
  mov [running],1
  invoke EnableWindow,[hScan],FALSE
  invoke EnableWindow,[hDetect],FALSE
  invoke EnableWindow,[hCIDR],FALSE
  invoke EnableWindow,[hTimeout],FALSE
  invoke EnableWindow,[hExport],FALSE
  invoke EnableWindow,[hTLS],FALSE
  invoke EnableWindow,[hStop],TRUE
  mov ebx,WORKERS
  cmp ebx,[total]
  jbe .create
  mov ebx,[total]
.create:
  lock inc [liveWorkers]
  invoke CreateThread,0,131072,Worker,0,0,0
  test eax,eax
  jz .threadFail
  invoke CloseHandle,eax
  dec ebx
  jnz .create
  jmp .ready
.threadFail:
  lock dec [liveWorkers]
  mov [createFailed],1
.ready:
  mov [workersReady],1
  cmp [liveWorkers],0
  jne .done
  mov [stopFlag],1
  invoke PostMessage,[hWnd],WM_FINISHED,0,0
  jmp .mem
.invalid:
  mov eax,[previousTotal]
  mov [total],eax
  invoke MessageBox,[hWnd],invalidText,appTitle,MB_OK or MB_ICONINFORMATION
  ret
.mem:
  invoke MessageBox,[hWnd],memFail,appTitle,MB_OK or MB_ICONERROR
.done:
  ret
endp

; Only callback signals events. The owning worker performs all request operations.
; Context remains alive until HANDLE_CLOSING, including cancellation paths.
proc HttpCallback uses ebx esi,handle,context,status,info,length
  local bytes:DWORD,extended:DWORD
  mov ebx,[context]
  test ebx,ebx
  jz .done
  mov eax,[status]
  cmp eax,800h ; HANDLE_CLOSING
  je .closed
  cmp eax,200000h ; REQUEST_ERROR
  je .error
  mov esi,[ebx+20]
  cmp eax,1 ; RESOLVING_NAME
  je .resolving
  cmp eax,2 ; NAME_RESOLVED
  je .connecting
  cmp eax,4 ; CONNECTING_TO_SERVER
  je .address
  cmp eax,8 ; CONNECTED_TO_SERVER
  je .connected
  cmp eax,10h ; SENDING_REQUEST: TLS completed for HTTPS
  je .http
  cmp eax,400000h ; SENDREQUEST_COMPLETE
  je .sent
  cmp eax,20000h ; HEADERS_AVAILABLE
  jne .done
  mov dword [esi+R_STAGE],4
  jmp .signal
.sent:
  mov dword [esi+R_STAGE],3
.signal:
  mov [ebx+8],eax
  invoke SetEvent,dword [ebx]
  jmp .done
.error:
  mov eax,[info]
  mov eax,[eax+4]
  mov [ebx+12],eax
  ; Extended Winsock errors are thread-local: capture them HERE, not in the worker.
  mov [extended],0
  mov [bytes],4
  invoke WinHttpQueryOption,0,24,addr extended,addr bytes
  test eax,eax
  jz .errorSignal
  mov eax,[extended]
  cmp eax,10000
  jb .errorSignal
  cmp eax,11999
  ja .errorSignal
  mov esi,[ebx+20]
  mov [esi+R_WSA],eax
.errorSignal:
  mov dword [ebx+8],200000h
  invoke SetEvent,dword [ebx]
  jmp .done
.resolving:
  mov dword [esi+R_STAGE],0
  jmp .done
.connecting:
  mov dword [esi+R_STAGE],1
  jmp .done
.address:
  mov dword [esi+R_STAGE],1
  cmp [scanMode],0
  je .done
  cmp dword [esi+R_PEER],0
  jne @f
  invoke HeapAlloc,[hHeap],HEAP_ZERO_MEMORY,80
  mov [esi+R_PEER],eax
  test eax,eax
  jz .done
@@:
  invoke WideCharToMultiByte,0,0,[info],-1,dword [esi+R_PEER],80,0,0
  mov edx,[esi+R_PEER]
  cmp byte [edx],'['
  jne .done
  lea eax,[edx+1]
.unbracket:
  mov cl,[eax]
  test cl,cl
  jz .peerEnd
  cmp cl,']'
  je .peerEnd
  mov [edx],cl
  inc edx
  inc eax
  jmp .unbracket
.peerEnd:
  mov byte [edx],0
  jmp .done
.connected:
  mov dword [esi+R_STAGE],2
  jmp .done
.http:
  mov dword [esi+R_STAGE],3
  jmp .done
.closed:
  invoke SetEvent,dword [ebx+4]
.done:
  ret
endp

; Total elapsed-time budget includes connection, TLS handshake and HTTP headers.
proc Await uses ebx,ctx,started
.loop:
  cmp [stopFlag],0
  jne .stopped
  invoke GetTickCount
  sub eax,[started]
  cmp eax,[timeoutMs]
  jae .timeout
  mov ebx,[timeoutMs]
  sub ebx,eax
  cmp ebx,50
  jbe @f
  mov ebx,50
@@:
  mov eax,[ctx]
  invoke WaitForSingleObject,dword [eax],ebx
  cmp eax,WAIT_TIMEOUT
  je .loop
  cmp eax,WAIT_OBJECT_0
  jne .failed
  mov eax,[ctx]
  mov eax,[eax+12]
  ret
.timeout:
  mov eax,12002
  ret
.stopped:
  mov eax,995
  ret
.failed:
  invoke GetLastError
  ret
endp

proc QueryField uses ebx,request,header,dest,capacity
  local bytes:DWORD,wide[2048]:WORD
  mov [bytes],4096
  invoke WinHttpQueryHeaders,[request],65535,[header],addr wide,addr bytes,0
  test eax,eax
  jz .done
  invoke WideCharToMultiByte,0,0,addr wide,-1,[dest],[capacity],0,0
.done:
  ret
endp

; Cookie headers may occur more than once; inspect each value rather than just the first.
proc QueryCookies uses ebx,request,dest
  local bytes:DWORD,index:DWORD,wide[2048]:WORD
  mov [index],0
.loop:
  mov [bytes],4096
  invoke WinHttpQueryHeaders,[request],65535,headerCookie,addr wide,addr bytes,addr index
  test eax,eax
  jz .done
  invoke WideCharToMultiByte,0,0,addr wide,-1,[dest],1024,0,0
  invoke StrStrIA,[dest],needleSession
  test eax,eax
  jnz .done
  cmp [index],64
  jb .loop
.done:
  ret
endp

; WinHTTP can lose the native error on its HTTPS path. Verify only missing
; pre-connect failures with a bounded nonblocking TCP connection to the SAME peer.
; Only WSAEACCES is retained; a second timeout/refusal never proves a local block.
proc VerifyLocalDenial uses ebx esi edi,row,started
  local wsa[512]:BYTE,ip[80]:BYTE,sa[28]:BYTE,saLen:DWORD,nonblocking:DWORD
  local writable[2]:DWORD,exceptional[2]:DWORD,tv[2]:DWORD,bytes:DWORD,error:DWORD
  mov esi,[row]
  cmp [stopFlag],0
  jne .done
  invoke GetTickCount
  sub eax,[started]
  cmp eax,[timeoutMs]
  jae .done
  stdcall PeerText,esi,addr ip
  cmp byte [ip],0
  je .done
  invoke WSAStartup,202h,addr wsa
  test eax,eax
  jnz .done
  lea edi,[sa]
  xor eax,eax
  mov ecx,7
  rep stosd
  lea edi,[sa]
  lea eax,[edi+4]
  invoke InetPtonA,2,addr ip,eax
  cmp eax,1
  jne .ipv6
  mov word [edi],2
  mov [saLen],16
  jmp .socket
.ipv6:
  lea eax,[edi+8]
  invoke InetPtonA,23,addr ip,eax
  cmp eax,1
  jne .cleanupWSA
  mov word [edi],23
  mov [saLen],28
.socket:
  mov eax,[esi+R_PORT]
  xchg al,ah
  mov [edi+2],ax
  movzx eax,word [edi]
  invoke socket,eax,1,6
  cmp eax,-1
  je .cleanupWSA
  mov ebx,eax
  mov [nonblocking],1
  invoke ioctlsocket,ebx,8004667Eh,addr nonblocking
  test eax,eax
  jnz .close
  invoke SockConnect,ebx,edi,[saLen]
  test eax,eax
  jz .close
  invoke WSAGetLastError
  cmp eax,10013
  je .denied
  cmp eax,10035
  jne .close
  invoke GetTickCount
  sub eax,[started]
  mov ecx,[timeoutMs]
  sub ecx,eax
  jbe .close
  cmp ecx,200
  jbe @f
  mov ecx,200
@@:
  imul ecx,1000
  mov [tv],0
  mov [tv+4],ecx
  mov [writable],1
  mov [writable+4],ebx
  mov [exceptional],1
  mov [exceptional+4],ebx
  invoke SockSelect,0,0,addr writable,addr exceptional,addr tv
  test eax,eax
  jle .close
  mov [bytes],4
  mov [error],0
  invoke getsockopt,ebx,0FFFFh,1007h,addr error,addr bytes
  test eax,eax
  jnz .close
  cmp [error],10013
  jne .close
.denied:
  mov dword [esi+R_WSA],10013
.close:
  invoke closesocket,ebx
.cleanupWSA:
  invoke WSACleanup
.done:
  ret
endp

proc Worker uses ebx esi edi,param
  local ctx[6]:DWORD, session:DWORD,connection:DWORD,request:DWORD,started:DWORD
  local callbackInstalled:DWORD,job:DWORD,result:DWORD,flags:DWORD,bytes:DWORD,err:DWORD,ipbuf[256]:BYTE,wideIP[256]:WORD,raw[32768]:WORD
  mov [session],0
  mov [connection],0
  mov [request],0
  lea edi,[ctx]
  mov dword [edi+8],0
  mov dword [edi+12],0
  invoke CreateEvent,0,FALSE,FALSE,0
  mov [edi],eax
  invoke CreateEvent,0,FALSE,FALSE,0
  mov [edi+4],eax
  cmp dword [edi],0
  je .exit
  test eax,eax
  jz .exit
  invoke WinHttpOpen,agent,1,0,0,10000000h ; NO_PROXY, ASYNC
  mov [session],eax
  test eax,eax
  jz .exit
  mov [flags],1
  invoke WinHttpSetOption,[session],140,addr flags,4 ; IPv6 fast fallback to IPv4, Windows 10 1903+
  invoke WinHttpSetTimeouts,[session],[timeoutMs],[timeoutMs],[timeoutMs],[timeoutMs]
.job:
  cmp [workersReady],0
  jne @f
  invoke Sleep,1
  jmp .job
@@:
  cmp [stopFlag],0
  jne .exit
  mov eax,1
  lock xadd [nextJob],eax
  inc eax
  cmp eax,[total]
  jae .exit
  mov [callbackInstalled],0
  mov [job],eax
  mov ecx,eax
  shl ecx,6
  add ecx,[rows]
  mov [result],ecx
  mov esi,ecx
  xor edx,edx
  mov ecx,PORT_COUNT
  div ecx
  mov ecx,[ports+edx*4]
  mov [esi+R_PORT],ecx
  add eax,[hostStart]
  mov [esi+R_IP],eax
  stdcall TargetText,esi,addr ipbuf
  cmp [scanMode],2
  jne @f
  cinvoke wsprintf,addr ipbuf,fmtLiteral6,scanName
@@:
  invoke MultiByteToWideChar,0,0,addr ipbuf,-1,addr wideIP,256
  mov [edi+20],esi
  mov dword [edi+8],0
  mov dword [edi+12],0
  invoke ResetEvent,dword [edi]
  invoke ResetEvent,dword [edi+4]
  invoke GetTickCount
  mov [started],eax
  invoke WinHttpConnect,[session],addr wideIP,dword [esi+R_PORT],0
  mov [connection],eax
  test eax,eax
  jz .lastError
  xor eax,eax
  mov ecx,[esi+R_PORT]
  cmp ecx,443
  je .secure
  cmp ecx,8443
  jne .open
.secure:
  mov eax,800000h
.open:
  invoke WinHttpOpenRequest,[connection],verb,rootPath,0,0,0,eax
  mov [request],eax
  test eax,eax
  jz .lastError
  mov [flags],7 ; disable cookies, redirects, and authentication
  invoke WinHttpSetOption,[request],63,addr flags,4
  test eax,eax
  jz .lastError
  mov [flags],0 ; WINHTTP_AUTOLOGON_SECURITY_LEVEL_HIGH
  mov [flags],2
  invoke WinHttpSetOption,[request],77,addr flags,4
  mov [flags],32768 ; bound response headers to 32 KiB
  invoke WinHttpSetOption,[request],91,addr flags,4
  ; Inventory must never offer a client certificate, including automatic selection.
  invoke WinHttpSetOption,[request],47,0,0
  cmp [scanTLS],0
  jne .callback
  mov [flags],3300h ; ignore local CA, name, date and usage errors for inventory
  invoke WinHttpSetOption,[request],31,addr flags,4
.callback:
  ; Install context before callback, so HANDLE_CLOSING also has a valid context.
  mov [flags],edi
  invoke WinHttpSetOption,[request],45,addr flags,4
  test eax,eax
  jz .lastError
  invoke WinHttpSetStatusCallback,[request],HttpCallback,62083Fh,0
  cmp eax,-1
  je .lastError
  mov [callbackInstalled],1
  invoke WinHttpSendRequest,[request],0,0,0,0,0,edi
  test eax,eax
  jz .lastError
  stdcall Await,edi,[started]
  test eax,eax
  jnz .error
  invoke ResetEvent,dword [edi]
  invoke WinHttpReceiveResponse,[request],0
  test eax,eax
  jz .lastError
  stdcall Await,edi,[started]
  test eax,eax
  jnz .error
  mov [bytes],4
  lea eax,[esi+R_HTTP]
  invoke WinHttpQueryHeaders,[request],20000013h,0,eax,addr bytes,0
  test eax,eax
  jz .lastError
  invoke HeapAlloc,[hHeap],HEAP_ZERO_MEMORY,D_SIZE
  mov [esi+R_DETAIL],eax
  test eax,eax
  jz .outOfMemory
  mov ebx,eax
  stdcall QueryField,[request],headerServer,ebx,256
  lea eax,[ebx+D_POWER]
  stdcall QueryField,[request],headerPower,eax,512
  lea eax,[ebx+D_COOKIE]
  stdcall QueryCookies,[request],eax
  lea eax,[ebx+D_LOCATION]
  stdcall QueryField,[request],headerLocation,eax,1024
  mov [bytes],65536
  invoke WinHttpQueryHeaders,[request],22,0,addr raw,addr bytes,0
  test eax,eax
  jz .classify
  lea eax,[ebx+D_RAW]
  invoke WideCharToMultiByte,0,0,addr raw,-1,eax,65536,0,0
.classify:
  lea eax,[ebx+D_POWER]
  invoke StrStrIA,eax,needlePHP
  test eax,eax
  jnz .php
  invoke StrStrIA,ebx,needlePHP
  test eax,eax
  jnz .php
  lea eax,[ebx+D_COOKIE]
  invoke StrStrIA,eax,needleSession
  test eax,eax
  jz .good
  mov dword [esi+R_PHP],2
  jmp .good
.php:
  mov dword [esi+R_PHP],1
.good:
  xor eax,eax
  jmp .error
.outOfMemory:
  mov eax,8
  jmp .error
.lastError:
  invoke GetLastError
  mov [err],eax
  mov [flags],0
  mov [bytes],4
  invoke WinHttpQueryOption,0,24,addr flags,addr bytes
  test eax,eax
  jz @f
  mov eax,[flags]
  cmp eax,10000
  jb @f
  cmp eax,11999
  ja @f
  mov [esi+R_WSA],eax
@@:
  mov eax,[err]
.error:
  mov [esi+R_ERROR],eax
  cmp eax,12029
  jne @f
  cmp dword [esi+R_WSA],0
  jne @f
  cmp dword [esi+R_STAGE],2
  jae @f
  stdcall VerifyLocalDenial,esi,[started]
@@:
  invoke GetTickCount
  sub eax,[started]
  mov [esi+R_MS],eax
  cmp [request],0
  je .closeConnection
  invoke WinHttpCloseHandle,[request]
  ; No context reuse until the final notification. Callback does no work after SetEvent.
  cmp [callbackInstalled],0
  je .requestClosed
  invoke WaitForSingleObject,dword [edi+4],0FFFFFFFFh
.requestClosed:
  mov [request],0
.closeConnection:
  cmp [connection],0
  je .publish
  invoke WinHttpCloseHandle,[connection]
  mov [connection],0
.publish:
  mov dword [esi+R_DONE],1
  lock inc [completed]
  cmp dword [esi+R_HTTP],0
  je @f
  lock inc [webCount]
@@:
  cmp dword [esi+R_PHP],0
  je @f
  lock inc [phpCount]
@@:
  invoke PostMessage,[hWnd],WM_RESULT,0,esi
  jmp .job
.exit:
  cmp [session],0
  je @f
  invoke WinHttpCloseHandle,[session]
@@:
  cmp dword [edi],0
  je @f
  invoke CloseHandle,dword [edi]
@@:
  cmp dword [edi+4],0
  je @f
  invoke CloseHandle,dword [edi+4]
@@:
.waitReady:
  cmp [workersReady],0
  jne .workerDone
  invoke Sleep,1
  jmp .waitReady
.workerDone:
  lock dec [liveWorkers]
  jnz .done
  invoke PostMessage,[hWnd],WM_FINISHED,0,0
.done:
  xor eax,eax
  ret
endp

; EAX=PHP label, EDX=evidence string, ECX=outcome string.
proc Labels uses ebx,row
  mov ebx,[row]
  mov eax,phpUnknown
  mov edx,evidenceNone
  cmp dword [ebx+R_PHP],1
  jne @f
  mov eax,phpHeader
  mov edx,evidenceHeader
@@:
  cmp dword [ebx+R_PHP],2
  jne @f
  mov eax,phpCookie
  mov edx,evidenceCookie
@@:
  mov ecx,resultOK
  cmp dword [ebx+R_HTTP],0
  jne .done
  cmp dword [ebx+R_ERROR],12007
  je .dns
  cmp dword [ebx+R_WSA],11001
  je .dns
  cmp dword [ebx+R_WSA],11002
  je .dns
  cmp dword [ebx+R_WSA],10013
  je .denied
  cmp dword [ebx+R_ERROR],5
  je .denied
  cmp dword [ebx+R_WSA],10061
  je .refused
  cmp dword [ebx+R_WSA],10051
  je .unreachable
  cmp dword [ebx+R_WSA],10065
  je .unreachable
  mov ecx,resultError
  cmp dword [ebx+R_ERROR],12002
  jne @f
  mov ecx,resultTimeout
  cmp dword [ebx+R_STAGE],2
  jae @f
  mov ecx,resultTCPTimeout
  cmp [scanMode],1
  jne @f
  cmp dword [ebx+R_STAGE],0
  jne @f
  mov ecx,resultDNSTimeout
@@:
  cmp dword [ebx+R_ERROR],995
  jne @f
  mov ecx,resultStopped
@@:
  cmp dword [ebx+R_ERROR],12029
  jne .done
  mov ecx,resultRefused
.done:
  ret
.denied:
  mov ecx,resultDenied
  ret
.dns:
  mov ecx,resultDNS
  ret
.refused:
  mov ecx,resultTCPRefused
  ret
.unreachable:
  mov ecx,resultUnreachable
  ret
endp

proc Diagnostic row
  mov edx,[row]
  mov eax,diagOK
  cmp dword [edx+R_HTTP],0
  jne .done
  cmp dword [edx+R_ERROR],995
  je .done
  mov eax,diagDenied
  cmp dword [edx+R_WSA],10013
  je .done
  cmp dword [edx+R_ERROR],5
  je .done
  mov eax,diagDNS
  cmp dword [edx+R_ERROR],12007
  je .done
  cmp dword [edx+R_WSA],11001
  je .done
  cmp [scanMode],1
  jne @f
  cmp dword [edx+R_STAGE],0
  je .done
@@:
  mov eax,diagRefused
  cmp dword [edx+R_WSA],10061
  je .done
  mov eax,diagTCP
  cmp dword [edx+R_STAGE],2
  jb .done
  mov eax,diagAfterConnect
.done:
  ret
endp

proc AddRow uses ebx esi edi,row
  local lv:LV_ITEM,buf[256]:BYTE,index:DWORD,labelPHP:DWORD,evidence:DWORD,outcome:DWORD
  mov esi,[row]
  cmp dword [esi+R_DONE],0
  je .done
  test dword [esi+R_DONE],2
  jnz .done
  cmp [filterMode],2
  jne @f
  cmp dword [esi+R_ERROR],0
  je .done
  jmp .add
@@:
  cmp [filterMode],1
  jne @f
  cmp dword [esi+R_PHP],0
  je .done
@@:
.add:
  stdcall Labels,esi
  mov [labelPHP],eax
  mov [evidence],edx
  mov [outcome],ecx
  mov [lv.mask],LVIF_TEXT or LVIF_PARAM
  mov [lv.iItem],7FFFFFFFh
  mov [lv.iSubItem],0
  mov [lv.lParam],esi
  lea eax,[buf]
  mov [lv.pszText],eax
  stdcall TargetText,esi,eax
  invoke SendMessage,[hList],LVM_INSERTITEM,0,addr lv
  cmp eax,-1
  je .done
  or dword [esi+R_DONE],2
  mov [index],eax
  mov [lv.iItem],eax
  mov [lv.mask],LVIF_TEXT
  mov [lv.iSubItem],1
  cinvoke wsprintf,addr buf,fmtUInt,dword [esi+R_PORT]
  invoke SendMessage,[hList],LVM_SETITEM,0,addr lv
  mov [lv.iSubItem],2
  mov byte [buf],0
  cmp dword [esi+R_HTTP],0
  je @f
  cinvoke wsprintf,addr buf,fmtUInt,dword [esi+R_HTTP]
@@:
  invoke SendMessage,[hList],LVM_SETITEM,0,addr lv
  mov [lv.iSubItem],3
  mov eax,[labelPHP]
  mov [lv.pszText],eax
  invoke SendMessage,[hList],LVM_SETITEM,0,addr lv
  mov [lv.iSubItem],4
  mov eax,[evidence]
  mov [lv.pszText],eax
  invoke SendMessage,[hList],LVM_SETITEM,0,addr lv
  mov [lv.iSubItem],5
  mov eax,empty
  cmp dword [esi+R_DETAIL],0
  je @f
  mov eax,[esi+R_DETAIL]
@@:
  mov [lv.pszText],eax
  invoke SendMessage,[hList],LVM_SETITEM,0,addr lv
  mov [lv.iSubItem],6
  lea eax,[buf]
  mov [lv.pszText],eax
  cinvoke wsprintf,addr buf,fmtUInt,dword [esi+R_MS]
  invoke SendMessage,[hList],LVM_SETITEM,0,addr lv
  mov [lv.iSubItem],7
  mov eax,[outcome]
  mov [lv.pszText],eax
  invoke SendMessage,[hList],LVM_SETITEM,0,addr lv
.done:
  ret
endp

proc RebuildList uses ebx esi
  invoke SendMessage,[hList],WM_SETREDRAW,FALSE,0
  invoke SendMessage,[hList],LVM_DELETEALLITEMS,0,0
  mov esi,[rows]
  test esi,esi
  jz .done
  xor ebx,ebx
.loop:
  cmp ebx,[total]
  jae .done
  and dword [esi+R_DONE],0FFFFFFFDh
  stdcall AddRow,esi
  add esi,R_SIZE
  inc ebx
  jmp .loop
.done:
  invoke SendMessage,[hList],WM_SETREDRAW,TRUE,0
  invoke InvalidateRect,[hList],0,TRUE
  ret
endp

proc URL uses ebx,row,buf
  local ip[256]:BYTE,formatString:DWORD
  mov ebx,[row]
  stdcall TargetText,ebx,addr ip
  mov [formatString],fmtURL
  cmp [scanMode],2
  jne @f
  mov [formatString],fmtURL6
@@:
  mov eax,schemeHTTP
  cmp dword [ebx+R_PORT],443
  je .tls
  cmp dword [ebx+R_PORT],8443
  jne .format
.tls:
  mov eax,schemeHTTPS
.format:
  cinvoke wsprintf,[buf],[formatString],eax,addr ip,dword [ebx+R_PORT]
  ret
endp

proc TLSLabel row
  mov edx,[row]
  mov eax,tlsNA
  cmp dword [edx+R_PORT],443
  je .tls
  cmp dword [edx+R_PORT],8443
  jne .done
.tls:
  mov eax,tlsUnchecked
  cmp [scanTLS],0
  je .done
  mov eax,tlsChecked
.done:
  ret
endp

proc ShowDetails uses ebx esi,row
  local url[384]:BYTE,peer[80]:BYTE,php:DWORD,evidence:DWORD,outcome:DWORD,tls:DWORD,diag:DWORD,stage:DWORD
  mov esi,[row]
  stdcall URL,esi,addr url
  stdcall Labels,esi
  mov [php],eax
  mov [evidence],edx
  mov [outcome],ecx
  stdcall TLSLabel,esi
  mov [tls],eax
  stdcall PeerText,esi,addr peer
  stdcall Diagnostic,esi
  mov [diag],eax
  mov eax,[esi+R_STAGE]
  mov eax,[stageNames+eax*4]
  mov [stage],eax
  mov eax,empty
  cmp dword [esi+R_DETAIL],0
  je @f
  mov eax,[esi+R_DETAIL]
  add eax,D_RAW
@@:
  ; wsprintf has a 1024-byte ceiling. Use bounded header copy after a short preamble.
  push eax
  cinvoke wsprintf,detailBuf,fmtDetails,addr url,[outcome],dword [esi+R_HTTP],dword [esi+R_MS],dword [esi+R_ERROR],dword [esi+R_WSA],addr peer,[stage],[diag],[php],[evidence],[tls]
  invoke lstrlen,detailBuf
  add eax,detailBuf
  pop edx
  invoke lstrcpyn,eax,edx,65536
  invoke SetWindowText,[hDetail],detailBuf
  ret
endp

proc Progress uses ebx
  mov ebx,progressRunning
  invoke GetTickCount
  sub eax,[scanStart]
  cmp [running],0
  jne .format
  mov eax,[scanElapsed]
  mov ebx,progressDone
  cmp [stopFlag],0
  je .format
  mov ebx,progressStopped
.format:
  xor edx,edx
  mov ecx,1000
  div ecx
  cinvoke wsprintf,statusBuf,fmtProgress,ebx,[completed],[total],[webCount],[phpCount],eax
  invoke SetWindowText,[hStatus],statusBuf
  ret
endp

; RFC4180 quoting, Excel formula neutralization, then ACP -> UTF-8.
proc CSVCell uses esi edi ebx,str
  mov esi,[str]
  mov edi,csvField
  mov byte [edi],'"'
  inc edi
  mov al,[esi]
  cmp al,'='
  je .guard
  cmp al,'+'
  je .guard
  cmp al,'-'
  je .guard
  cmp al,'@'
  je .guard
  cmp al,9
  je .guard
  cmp al,13
  je .guard
  cmp al,10
  jne .copy
.guard:
  mov byte [edi],27h
  inc edi
.copy:
  lodsb
  test al,al
  jz .cellEnd
  cmp edi,csvField+131090
  jae .cellEnd
  stosb
  cmp al,'"'
  jne .copy
  stosb
  jmp .copy
.cellEnd:
  mov byte [edi],'"'
  inc edi
  mov byte [edi],0
  invoke MultiByteToWideChar,0,0,csvField,-1,csvWide,131100
  test eax,eax
  jz .bad
  invoke WideCharToMultiByte,65001,0,csvWide,-1,csvUTF8,393300,0,0
  test eax,eax
  jz .bad
  dec eax
  stdcall WriteCSV,csvUTF8,eax
  ret
.bad:
  mov [csvOkay],0
  ret
endp

proc WriteCSV uses ebx,buf,len
  cmp [csvOkay],0
  je .done
  invoke WriteFile,[csvFile],[buf],[len],written,0
  test eax,eax
  jz .bad
  mov eax,[len]
  cmp eax,[written]
  je .done
.bad:
  mov [csvOkay],0
.done:
  ret
endp

proc CSVNext str
  stdcall WriteCSV,comma,1
  stdcall CSVCell,[str]
  ret
endp

proc CSVNumber val
  cinvoke wsprintf,numberBuf,fmtUInt,[val]
  stdcall CSVNext,numberBuf
  ret
endp

proc ExportCSV uses ebx esi edi
  local php:DWORD,evidence:DWORD,outcome:DWORD,tls:DWORD,buf[384]:BYTE
  cmp [rows],0
  je .done
  mov edi,ofn
  xor eax,eax
  mov ecx,sizeof.OPENFILENAME
  rep stosb
  mov [ofn.lStructSize],sizeof.OPENFILENAME
  mov eax,[hWnd]
  mov [ofn.hwndOwner],eax
  mov [ofn.lpstrFilter],csvFilter
  mov [ofn.lpstrFile],fileName
  mov [ofn.nMaxFile],1024
  mov [ofn.lpstrDefExt],csvExt
  mov [ofn.Flags],OFN_EXPLORER or OFN_OVERWRITEPROMPT or OFN_PATHMUSTEXIST or OFN_NOCHANGEDIR
  invoke lstrcpy,fileName,csvName
  invoke GetSaveFileName,ofn
  test eax,eax
  jz .done
  invoke CreateFile,fileName,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
  cmp eax,INVALID_HANDLE_VALUE
  je .fail
  mov [csvFile],eax
  mov [csvOkay],1
  invoke lstrlen,csvHeader
  stdcall WriteCSV,csvHeader,eax
  mov esi,[rows]
  xor ebx,ebx
.loop:
  cmp ebx,[total]
  jae .close
  cmp dword [esi+R_DONE],0
  je .next
  stdcall Labels,esi
  mov [php],eax
  mov [evidence],edx
  mov [outcome],ecx
  stdcall TLSLabel,esi
  mov [tls],eax
  stdcall TargetText,esi,addr buf
  stdcall CSVCell,addr buf
  stdcall PeerText,esi,addr buf
  stdcall CSVNext,addr buf
  stdcall CSVNumber,dword [esi+R_PORT]
  stdcall URL,esi,addr buf
  stdcall CSVNext,addr buf
  stdcall CSVNumber,dword [esi+R_HTTP]
  stdcall CSVNext,[php]
  stdcall CSVNext,[evidence]
  mov edi,[esi+R_DETAIL]
  test edi,edi
  jnz .detail
  stdcall CSVNext,empty
  stdcall CSVNext,empty
  stdcall CSVNext,empty
  jmp .tail
.detail:
  stdcall CSVNext,edi
  lea eax,[edi+D_POWER]
  stdcall CSVNext,eax
  lea eax,[edi+D_LOCATION]
  stdcall CSVNext,eax
.tail:
  stdcall CSVNumber,dword [esi+R_MS]
  stdcall CSVNext,[outcome]
  stdcall CSVNumber,dword [esi+R_ERROR]
  stdcall CSVNext,[tls]
  mov eax,empty
  test edi,edi
  jz @f
  lea eax,[edi+D_RAW]
@@:
  stdcall CSVNext,eax
  stdcall CSVNumber,dword [esi+R_WSA]
  mov eax,[esi+R_STAGE]
  stdcall CSVNext,dword [stageNames+eax*4]
  stdcall Diagnostic,esi
  stdcall CSVNext,eax
  stdcall WriteCSV,newline,2
.next:
  add esi,R_SIZE
  inc ebx
  jmp .loop
.close:
  invoke FlushFileBuffers,[csvFile]
  test eax,eax
  jnz @f
  mov [csvOkay],0
@@:
  invoke CloseHandle,[csvFile]
  cmp [csvOkay],0
  je .fail
  invoke SetWindowText,[hStatus],exported
  jmp .done
.fail:
  invoke MessageBox,[hWnd],saveFail,appTitle,MB_OK or MB_ICONERROR
.done:
  ret
endp

section '.idata' import data readable writeable
  library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL',comctl32,'COMCTL32.DLL',comdlg32,'COMDLG32.DLL',iphlpapi,'IPHLPAPI.DLL',ws2,'WS2_32.DLL',winhttp,'WINHTTP.DLL',dwmapi,'DWMAPI.DLL',uxtheme,'UXTHEME.DLL',shlwapi,'SHLWAPI.DLL'
  include 'api/kernel32.inc'
  include 'api/user32.inc'
  include 'api/gdi32.inc'
  include 'api/comctl32.inc'
  include 'api/comdlg32.inc'
  import iphlpapi,GetAdaptersInfo,'GetAdaptersInfo',GetBestInterface,'GetBestInterface'
  import ws2,inet_addr,'inet_addr',InetPtonA,'inet_pton',WSAStartup,'WSAStartup',WSACleanup,'WSACleanup',socket,'socket',ioctlsocket,'ioctlsocket',SockConnect,'connect',WSAGetLastError,'WSAGetLastError',SockSelect,'select',getsockopt,'getsockopt',closesocket,'closesocket'
  import shlwapi,StrStrIA,'StrStrIA'
  import dwmapi,DwmSetWindowAttribute,'DwmSetWindowAttribute'
  import uxtheme,SetWindowTheme,'SetWindowTheme'
  import winhttp,WinHttpOpen,'WinHttpOpen',WinHttpConnect,'WinHttpConnect',WinHttpOpenRequest,'WinHttpOpenRequest',WinHttpSetOption,'WinHttpSetOption',WinHttpQueryOption,'WinHttpQueryOption',WinHttpSetTimeouts,'WinHttpSetTimeouts',WinHttpSetStatusCallback,'WinHttpSetStatusCallback',WinHttpSendRequest,'WinHttpSendRequest',WinHttpReceiveResponse,'WinHttpReceiveResponse',WinHttpQueryHeaders,'WinHttpQueryHeaders',WinHttpCloseHandle,'WinHttpCloseHandle'

section '.rsrc' resource data readable
  directory RT_MANIFEST,manifest,RT_ICON,icons,RT_GROUP_ICON,groupicons
  resource manifest,1,LANG_NEUTRAL,appManifest
  resource icons,1,LANG_NEUTRAL,iconData
  resource groupicons,1,LANG_NEUTRAL,mainIcon
  resdata appManifest
    file 'app.manifest'
  endres
  icon mainIcon,iconData,'scout.ico'
