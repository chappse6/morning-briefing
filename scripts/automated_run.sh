#!/usr/bin/env bash
# 매일 아침 스케줄러가 실행하는 자동화 스크립트
# 핵심: 마운트된 사용자 디스크는 FUSE 제약(unlink 불가)이 있어
# 모든 git 쓰기 작업은 /tmp의 임시 클론에서 진행하고,
# 사용자 디스크는 1) PAT 보관 2) 결과 동기화 용도로만 사용한다.
set -euo pipefail
MOUNT="/sessions/$(ls /sessions | grep -v lost+found | head -1)/mnt/morning-briefing"
WORK="/tmp/mb-run-$$"
PAT_URL=$(awk '/url = / {print $3; exit}' "$MOUNT/.git/config")
git clone --quiet "$PAT_URL" "$WORK"
cp "$WORK/template.html" "$MOUNT/template.html.cache" 2>/dev/null || true
# ...여기서 Claude가 index.html을 새로 만들어서 $WORK/index.html로 저장...
cd "$WORK"
git -c user.email=chappse6@gmail.com -c user.name=chappse6 add index.html
git -c user.email=chappse6@gmail.com -c user.name=chappse6 commit -m "Daily briefing $(TZ=Asia/Seoul date +%F)"
git push origin master
# 사용자 디스크의 index.html도 같은 내용으로 덮어쓰기 (FUSE는 overwrite는 허용)
cp "$WORK/index.html" "$MOUNT/index.html"
rm -rf "$WORK"
