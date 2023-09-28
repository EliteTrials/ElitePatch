@echo off

for %%* in (.) do set project_name=%%~n*

title %project_name%
color 0F

echo.
echo Deleting compiled files %project_name%
echo.
cd..
cd system
del %project_name%.u

ucc.exe MakeCommandletUtils.EditPackagesCommandlet 1 %project_name%
ucc.exe editor.MakeCommandlet -EXPORTCACHE -SHOWDEP
ucc.exe MakeCommandletUtils.EditPackagesCommandlet 0 %project_name%

xcopy "%project_name%.u" "..\%project_name%\System\%project_name%.u" /i /y /s /e /q /b /f

cd..
cd %project_name%