# bat 파일 준비

upload.bat 파일 제작

- 프로그램 실행 후 Commit Message만 입력하면 바로 커밋되도록 설정

```bat
@echo off
SET /P COMMIT_MSG="Enter commit message: "
git add .
git commit -m "%COMMIT_MSG%"
git push origin main
```

---

# bat파일 전 수행사항

1. Git 초기화 및 원격 설정

```powershell
git init
git remote add origin https://github.com/GOODJINC/handa.git
git branch -M main
git pull origin main --allow-unrelated-histories
```

2. 첫 커밋

```powershell
git add .
git commit -m "Initial commit"
git push origin main
```



---

# Git Clone하는 방법

1. 특정 폴더로 프로젝트 클론하기

```powershell
cd ~/Folder
git clone https://github.com/GOODJINC/handa.git
cd handa
```

2. Flutter 의존성 설치

```powershell
flutter pub get
```

