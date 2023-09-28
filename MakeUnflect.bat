@echo off

set patch_dir=%cd%

echo Making Unflect

cd ..\Unflect
cmd /c ".\Make.bat"

cd %patch_dir%

echo Updating local copy of Unflect.u

copy \b \y "..\Unflect\System\Unflect.u" \b \y ".\System\Unflect.u"
