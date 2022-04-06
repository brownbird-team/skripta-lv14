@echo off
@title Rjesenja Ispitne Vjezbe
color 17

set korisnik=%username%

if "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) else (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

if '%errorlevel%' NEQ '0' (
    echo -- Potrebne su mi administratorske privilegije --
    goto UACPrompt
) else ( goto gotAdmin )


:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
    echo -- Imam sve potrebne privilegije --

:: Ispisi upute

echo ************************************
echo       Rjesenja ispitne vjezbe
echo ************************************
echo Made By BrownBird Team
echo.
pause

:: Zatrazi ime prezime i folder
:getfolder
echo %korisnik% je tvoje korisnicko ime
set /p check="Je li C:\Users\%korisnik%\Desktop vas desktop direktorij [y/n] "
if "%check%" EQU "y" (
    set mydf=C:\Users\%korisnik%\Desktop
) else if "%check%" EQU "n" (
    set /p mydf="Upisi punu putanju do svog Desktop direktorija: "
) else (
    goto getfolder
)

set /p ime="Upisi svoje ime: "
set /p prez="Upisi svoje prezime: "

:: Prebaci se u dir
cd %mydf%
mkdir %prez%%ime% > nul 2>&1
cd %prez%%ime%

echo -- Krecem --
:: Zadatak 1.
echo zad1
type nul > Skriveno.txt
attrib +H Skriveno.txt
type nul > PopisAtributa.txt
echo %prez% >> PopisAtributa.txt
attrib Skriveno.txt >> PopisAtributa.txt

:: Zadatak 2.
echo zad2
type nul > FiltriraniSadrzaj.txt
for /f "skip=4 tokens=1,5" %%i in ('dir /a') do (echo %%i %%j >> FiltriraniSadrzaj.txt)
sort /+5 FiltriraniSadrzaj.txt > SortiraniSadrzaj.txt

:: Zadatak 3.
echo zad3
for /l %%i in (1,1,3) do (net user Provjera%%i provjera /add > nul 2>&1)
net localgroup Ispit /add > nul 2>&1
for /l %%i in (1,1,3) do (net localgroup Ispit Provjera%%i /add > nul 2>&1)
net localgroup Ispit > ClanoviGrupeIspit.txt

:: Zadatak 4.
echo zad4
for /l %%i in (1,1,3) do (wmic useraccount where name="Provjera%%i" set disabled=true > nul 2>&1)
wmic useraccount where disabled=true get name,disabled > OnemoguceniKorisnici.txt

:: Zadatak 5.
echo zad5
net share %prez%%ime%=%mydf%\%prez%%ime% /GRANT:Everyone,FULL > nul 2>&1
for /f "tokens=*" %%i in ('hostname') do (set hnm=%%i)
net use Z: \\%hnm%\%prez%%ime% > nul 2>&1
Z:
if exist PopisAtributa.txt (echo Datoteka PopisAtributa.txt postoji & echo Datoteka PopisAtributa.txt postoji > poruka.txt) else (type nul > PopisAtributa.txt)
C:

echo.
set "checkme="
goto obrisime
:obrisime
set /p checkme="os obrisat net share ? [y/n] "
if "%checkme%" EQU "y" (
    net use /delete /y Z: > nul 2>&1
    net share /delete /y %prez%%ime% > nul 2>&1
	echo.
    echo [ OK ] obrisano
) else if "%checkme%" EQU "n" (
	echo.
    echo [ OK ] ne diram ih
) else (
    goto obrisime
)

echo.
set "checkme="
goto obrisiusr
:obrisiusr
set /p checkme="os obrisat kreirane korisnike i grupe ? [y/n] "
if "%checkme%" EQU "y" (
    for /l %%i in (1,1,3) do (net user Provjera%%i /delete > nul 2>&1)
	net localgroup Ispit /delete > nul 2>&1
	echo.
    echo [ OK ] obrisano
) else if "%checkme%" EQU "n" (
	echo.
    echo [ OK ] ne diram ih
) else (
    goto obrisiusr
)

echo.
echo -- Kraj --
pause