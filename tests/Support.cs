using System;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Net.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
#pragma warning disable SYSLIB0057 // Constructor also works on .NET 8 hosted PowerShell.

public static class ScoutUI {
 [DllImport("user32.dll")] public static extern IntPtr GetDlgItem(IntPtr h,int id);
 [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern IntPtr SendMessage(IntPtr h,uint msg,IntPtr w,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Auto,EntryPoint="SendMessage")] static extern IntPtr SendText(IntPtr h,uint msg,IntPtr w,string l);
 [DllImport("user32.dll",CharSet=CharSet.Auto,EntryPoint="SendMessage")] static extern IntPtr ReadText(IntPtr h,uint msg,IntPtr w,StringBuilder l);
 [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern bool PostMessage(IntPtr h,uint msg,IntPtr w,IntPtr l);
 [DllImport("user32.dll",CharSet=CharSet.Auto)] public static extern bool SetWindowText(IntPtr h,string text);
 [DllImport("user32.dll",CharSet=CharSet.Auto)] static extern int GetWindowText(IntPtr h,StringBuilder s,int n);
 [DllImport("user32.dll",CharSet=CharSet.Auto)] static extern int GetClassName(IntPtr h,StringBuilder s,int n);
 [DllImport("user32.dll")] public static extern bool IsWindowEnabled(IntPtr h);
 [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr h,EnumProc p,IntPtr l);
 [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p,IntPtr l);
 [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h,out uint pid);
 [DllImport("user32.dll")] static extern int GetDlgCtrlID(IntPtr h);
 [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h,out RECT r);
 [DllImport("user32.dll")] static extern bool PrintWindow(IntPtr h,IntPtr dc,uint flags);
 [DllImport("kernel32.dll")] static extern IntPtr OpenProcess(uint access,bool inherit,int pid);
 [DllImport("kernel32.dll")] static extern IntPtr VirtualAllocEx(IntPtr p,IntPtr a,UIntPtr n,uint type,uint protect);
 [DllImport("kernel32.dll")] static extern bool VirtualFreeEx(IntPtr p,IntPtr a,UIntPtr n,uint type);
 [DllImport("kernel32.dll")] static extern bool WriteProcessMemory(IntPtr p,IntPtr a,byte[] b,UIntPtr n,out UIntPtr written);
 [DllImport("kernel32.dll")] static extern bool ReadProcessMemory(IntPtr p,IntPtr a,byte[] b,UIntPtr n,out UIntPtr read);
 [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h,int cmd);
 public delegate bool EnumProc(IntPtr h,IntPtr l);
 public struct RECT { public int L,T,R,B; }
 public static string Text(IntPtr h) { var b=new StringBuilder(30000); ReadText(h,13,(IntPtr)b.Capacity,b); return b.ToString(); }
 public static void SetText(IntPtr h,string text) { SendText(h,12,IntPtr.Zero,text); }
 public static void TypeText(IntPtr h,string text) {SendMessage(h,0xB1,IntPtr.Zero,(IntPtr)(-1));foreach(char c in text)SendMessage(h,0x102,(IntPtr)c,IntPtr.Zero);}
 public static string Class(IntPtr h) { var b=new StringBuilder(256); GetClassName(h,b,256); return b.ToString(); }
 public static string[] Children(IntPtr h) { var a=new List<string>(); EnumChildWindows(h,(x,l)=>{a.Add($"{x} | {GetDlgCtrlID(x)} | {Class(x)} | {Text(x)}");return true;},IntPtr.Zero);return a.ToArray(); }
 public static IntPtr Dialog(int pid) { IntPtr found=IntPtr.Zero; EnumWindows((x,l)=>{uint p;GetWindowThreadProcessId(x,out p); if(p==pid && Class(x)=="#32770") found=x; return true;},IntPtr.Zero);return found; }
 public static IntPtr[] Dialogs(int pid) {var a=new List<IntPtr>();EnumWindows((x,l)=>{uint p;GetWindowThreadProcessId(x,out p);if(p==pid && Class(x)=="#32770")a.Add(x);return true;},IntPtr.Zero);return a.ToArray();}
 public static string[] Windows(int pid) { var a=new List<string>(); EnumWindows((x,l)=>{uint p;GetWindowThreadProcessId(x,out p);if(p==pid)a.Add($"{x} | {Class(x)} | {Text(x)}");return true;},IntPtr.Zero);return a.ToArray(); }
 public static IntPtr Main(int pid) { IntPtr found=IntPtr.Zero;EnumWindows((x,l)=>{uint p;GetWindowThreadProcessId(x,out p);if(p==pid && Class(x)=="PhpSubnetScout.Main")found=x;return true;},IntPtr.Zero);return found; }
 public static void Click(IntPtr h,int id) { PostMessage(h,0x111,(IntPtr)id,GetDlgItem(h,id)); }
 public static IntPtr FindChild(IntPtr h,string cls) {IntPtr found=IntPtr.Zero;EnumChildWindows(h,(x,l)=>{if(Class(x)==cls) {found=x;return false;} return true;},IntPtr.Zero);return found;}
 public static IntPtr FindId(IntPtr h,string cls,int id) {IntPtr found=IntPtr.Zero;EnumChildWindows(h,(x,l)=>{if(Class(x)==cls && GetDlgCtrlID(x)==id) {found=x;return false;} return true;},IntPtr.Zero);return found;}
 public static string[] Row(int pid,IntPtr list,int index,bool select=false) {
  var result=new string[8];var p=OpenProcess(0x38,false,pid);var remote=VirtualAllocEx(p,IntPtr.Zero,(UIntPtr)4096,0x3000,4);
  if(remote==IntPtr.Zero)throw new Exception("VirtualAllocEx");
  try{var item=new byte[64];BitConverter.GetBytes((int)remote+64).CopyTo(item,20);BitConverter.GetBytes(1024).CopyTo(item,24);
   for(int c=0;c<8;c++){BitConverter.GetBytes(c).CopyTo(item,8);WriteProcessMemory(p,remote,item,(UIntPtr)item.Length,out _);SendMessage(list,0x102D,(IntPtr)index,remote);var data=new byte[1024];ReadProcessMemory(p,remote+64,data,(UIntPtr)data.Length,out _);int end=Array.IndexOf(data,(byte)0);result[c]=Encoding.ASCII.GetString(data,0,end<0?data.Length:end);}
   if(select){BitConverter.GetBytes(3).CopyTo(item,12);BitConverter.GetBytes(3).CopyTo(item,16);WriteProcessMemory(p,remote,item,(UIntPtr)item.Length,out _);SendMessage(list,0x102B,(IntPtr)index,remote);}
  }finally{VirtualFreeEx(p,remote,UIntPtr.Zero,0x8000);CloseHandle(p);} return result;
 }
 public static void Shot(IntPtr h,string path) { GetWindowRect(h,out var r); using(var b=new Bitmap(r.R-r.L,r.B-r.T)) using(var g=Graphics.FromImage(b)) {var dc=g.GetHdc();PrintWindow(h,dc,2);g.ReleaseHdc(dc);b.Save(path,ImageFormat.Png);} }
}

public sealed class ScoutFixture : IDisposable {
 readonly List<TcpListener> listeners=new List<TcpListener>();
 readonly X509Certificate2 cert;
 volatile bool disposed;
 public volatile int Delay80=0;
 public volatile int Delay4430=2200;
 public int Requests80,Requests443,Requests8080,Requests4430;
 public string LastError="";
 public ScoutFixture() {
   var rsa=RSA.Create(2048);
   var req=new CertificateRequest("CN=scout-fixture.invalid",rsa,HashAlgorithmName.SHA256,RSASignaturePadding.Pkcs1);
   using(var ephemeral=req.CreateSelfSigned(DateTimeOffset.Now.AddDays(-1),DateTimeOffset.Now.AddDays(1)))
    cert=new X509Certificate2(ephemeral.Export(X509ContentType.Pfx),(string)null,X509KeyStorageFlags.Exportable);
   foreach(int port in new[]{80,443,8080,4430}) {
     var listener=new TcpListener(IPAddress.Parse("127.23.45.67"),port);
     try {listener.Start();} catch(Exception ex) {throw new Exception("Loopback fixture port "+port+": "+ex.Message,ex);} listeners.Add(listener);
     Task.Run(async()=>{while(!disposed) {try{var client=await listener.AcceptTcpClientAsync(); _=Task.Run(()=>Serve(client,port));}catch{if(disposed)break;}}});
   }
 }
 public static string Probe() {try{using(var c=new TcpClient("127.23.45.67",443))using(var s=new SslStream(c.GetStream(),false,(a,b,d,e)=>true)){s.AuthenticateAsClient("scout-fixture.invalid");var request=Encoding.ASCII.GetBytes("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n");s.Write(request,0,request.Length);var b=new byte[4096];int n=s.Read(b,0,b.Length);return Encoding.ASCII.GetString(b,0,n);}}catch(Exception ex){return ex.ToString();}}
 void Serve(TcpClient client,int port) {
   using(client) try {
    System.IO.Stream stream=client.GetStream();
    stream.ReadTimeout=5000;stream.WriteTimeout=5000;
    if(port==443 || port==4430) {var ssl=new SslStream(stream,false);ssl.AuthenticateAsServer(cert,false,System.Security.Authentication.SslProtocols.Tls12,false);stream=ssl;}
    using(stream) {
     var buffer=new byte[4096];var request=stream.Read(buffer,0,buffer.Length);
     if(request==0)return;
     string response;
     switch(port) {
      case 80: Interlocked.Increment(ref Requests80);Thread.Sleep(Delay80);response="HTTP/1.1 200 OK\r\nServer: =SUM(1,2)\r\nX-Powered-By: PHP/8.3.1\r\n";break;
      case 443: Interlocked.Increment(ref Requests443);response="HTTP/1.1 200 OK\r\nServer: fixture\r\nSet-Cookie: theme=light\r\nSet-Cookie: PHPSESSID=abc123; HttpOnly\r\n";break;
      case 8080: Interlocked.Increment(ref Requests8080);response="HTTP/1.1 302 Found\r\nServer: nginx\r\nLocation: http://127.23.45.67:80/outside\r\n";break;
      default: Interlocked.Increment(ref Requests4430);Thread.Sleep(Delay4430);response="HTTP/1.1 403 Forbidden\r\nServer: PHP/8.2 fixture\r\n";break;
     }
     response+="X-Quote: a, \"b\"\r\nContent-Length: 0\r\nConnection: close\r\n\r\n";
     var bytes=Encoding.ASCII.GetBytes(response);stream.Write(bytes,0,bytes.Length);
    }
   } catch (Exception ex) {LastError=ex.ToString();}
 }
 public void Dispose() {disposed=true; foreach(var l in listeners) l.Stop();cert.Dispose();}
}
