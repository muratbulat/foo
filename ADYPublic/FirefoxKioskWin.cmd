@echo off
title UBS Kiosk Starter
set ffdir="C:\Program Files\Mozilla Firefox\firefox.exe"
set ubsurl=https://foo.com
taskkill /f /im explorer.exe
start "" %ffdir% --kiosk --private-window %ubsurl%
