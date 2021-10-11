program QuickReboot;

uses
  SysUtils,
  Windows;

const
  SE_SHUTDOWN_NAME='SeShutdownPrivilege'; // Borland forgot this declaration
var
  hToken: THandle;
  tkp: TTokenPrivileges;
  tkpo: TTokenPrivileges;
  zero: DWORD;
  OSName: string;

function myGetVersion: String;
var
 VersionInfo: TOSVersionInfo;
begin
 // set the size of the record
 VersionInfo.dwOSVersionInfoSize:=SizeOf(TOSVersionInfo);
 if Windows.GetVersionEx(VersionInfo)
 then
  begin
   with VersionInfo do
    begin
     case dwPlatformId of
         VER_PLATFORM_WIN32s	     : OSName:='Win32s';
         VER_PLATFORM_WIN32_WINDOWS: OSName:='Windows 95';
         VER_PLATFORM_WIN32_NT     : OSName:='Windows NT';
     end;
     Result:=OSName+' Version '+IntToStr(dwMajorVersion)+'.'+IntToStr(dwMinorVersion)+
                #13#10' (Build '+IntToStr(dwBuildNumber)+': '+szCSDVersion+')';
    end;
  end
 else Result:='';
end;

begin
  if Pos('Windows NT', MyGetVersion)=1
  then // we've got to do a whole buch of things
   begin
    zero:=0;
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)
    then
     begin
      Exit;
     end; // if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)
    then
     begin
      Exit;
     end; // if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)
    // SE_SHUTDOWN_NAME
    if not LookupPrivilegeValue(nil, 'SeShutdownPrivilege' , tkp.Privileges[ 0 ].Luid)
    then
     begin
      Exit;
     end; // if not LookupPrivilegeValue(nil, 'SeShutdownPrivilege' , tkp.Privileges[0].Luid )
    tkp.PrivilegeCount:=1;
    tkp.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, False, tkp, SizeOf(TTokenPrivileges ), tkpo, zero);
    if Boolean(GetLastError())
    then
     begin
      Exit;
     end // if Boolean(GetLastError())
    else
     begin
      ExitWindowsEx(EWX_Force or EWX_REBOOT, 0);
     end;
   end // if OSVersion = 'Windows NT'
  else
   begin // just shut the machine down
    ExitWindowsEx(EWX_Force or EWX_REBOOT, 0);
   end;
end.
