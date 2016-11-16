;=====================================
; dupeGuru Installer Script
; TODO:
; + Do we need to delete "$LOCALAPPDATA\${COMPANYNAME}\${APPNAME}"?
;=====================================
;Include Modern UI
!include "MUI2.nsh"

;--------------------------------
!define APPNAME "dupeGuru"
!define COMPANYNAME "Hardcoded Software"
!define DESCRIPTION "dupeGuru is a tool to find duplicate files on your computer"
;Version numbers will typically be passed in from the command line from the package.py script
!ifndef VERSIONMAJOR
  !define VERSIONMAJOR 0
!endif
!ifndef VERSIONMINOR
  !define VERSIONMINOR 0
!endif
!ifndef VERSIONBUILD
  !define VERSIONBUILD 0
!endif
!define INSTALLSIZE 37260
!define OUTFILE "dupeGuru-${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}-installer.exe"
!define APPFILE "dupeGuru.exe"
!define APPICON "..\images\dgse_logo.ico"
!define APPLICENSE "..\LICENSE"
!define REG_ROOT "HKLM"
!define REG_USERROOT "HKCU"
!define REG_APP_PATH "Software\${COMPANYNAME}\${APPNAME}"
!define REG_UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall"
!define REG_STARTMENU_KEY "Start Menu Folder"
!define DISTDIR "..\dist"

!define HELPURL "http://www.hardcoded.net/support/"  ;"Support Information" link
!define UPDATEURL "http://www.hardcoded.net/dupeguru/"  ;"Product Updates" link
!define ABOUTURL "http://www.hardcoded.net/dupeguru/"  ;"Publisher" link


;General
Name "${APPNAME}"
OutFile "${OUTFILE}"
Icon "${APPICON}"


;Default installation folder
LicenseData "${APPLICENSE}"
InstallDir "$PROGRAMFILES\${COMPANYNAME}\${APPNAME}"

RequestExecutionLevel admin ;Require admin rights on NT6+ (When UAC is turned on)

!define MUI_ABORTWARNING
Var StartMenuFolder

;Pages
!insertmacro MUI_PAGE_LICENSE "${APPLICENSE}"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${REG_USERROOT}" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${REG_APP_PATH}" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${REG_STARTMENU_KEY}"

!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_INIT
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"


!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
        messageBox mb_iconstop "Administrator rights required!"
        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        quit
${EndIf}
!macroend
 
function .OnInit
	setShellVarContext all
	!insertmacro VerifyUserIsAdmin
functionEnd

function un.OnInit
	setShellVarContext all
	!insertmacro VerifyUserIsAdmin
functionEnd


;--------------------------------
;Installer Sections

Section "!Application" AppSec

  SectionIn RO
  SetOutPath "$INSTDIR"
  File /r /x help "..\dist\*.*"
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  ;Create shortcuts
  CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APPNAME}.lnk" "$INSTDIR\${APPFILE}" ""
  CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  !insertmacro MUI_STARTMENU_WRITE_END

  
  ; Registry information for add/remove programs
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$INSTDIR\${APPFILE},0"
  WriteRegDWORD HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
  WriteRegDWORD HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "VersionMinor" ${VERSIONMINOR}
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "Comments" "dupeGuru installer"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "Publisher" "${COMPANYNAME}"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "Contact" "${HELPURL}"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "HelpLink" "${HELPURL}"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "URLUpdateInfo" "${UPDATEURL}"
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "URLInfoAbout" "${ABOUTURL}"
  WriteRegDWORD HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "NoModify" 1
  WriteRegDWORD HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
  WriteRegDWORD HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "EstimatedSize" ${INSTALLSIZE}
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"

  
SectionEnd


Section "Help Files" HelpSec
  SetOutPath "$INSTDIR"
  File /r "${DISTDIR}\help"
SectionEnd

LangString DESC_InstSec ${LANG_ENGLISH} "Main Application"
LangString DESC_HelpSec ${LANG_ENGLISH} "Help files"
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${AppSec} $(DESC_InstSec)
!insertmacro MUI_DESCRIPTION_TEXT ${HelpSec} $(DESC_HelpSec)
!insertmacro MUI_FUNCTION_DESCRIPTION_END


;--------------------------------
; Uninstaller
;--------------------------------
Section Uninstall
;First, uninstall from log file

  RMDir /r "$INSTDIR"
  
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
  Delete "$SMPROGRAMS\$StartMenuFolder\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"

  DeleteRegKey /ifempty "${REG_USERROOT}" "${REG_APP_PATH}"
  DeleteRegKey HKLM "${REG_UNINSTALL_PATH}\${COMPANYNAME} ${APPNAME}"
  
SectionEnd

