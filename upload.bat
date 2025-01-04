@echo off
SET /P COMMIT_MSG="Enter commit message: "
git add .
git commit -m "%COMMIT_MSG%"
git push origin main