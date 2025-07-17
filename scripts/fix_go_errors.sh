#!/bin/bash

# 파일 이름을 첫 번째 인자로 받음
FILE=$1

# 백업 파일 생성
cp "$FILE" "${FILE}.bak"

# "Invalid format for parameter" 문자열을 찾아 "invalid format for parameter"로 변경
sed -i 's/Invalid format for parameter/invalid format for parameter/g' "$FILE"

# "Invalid" 으로 시작하는 에러 메시지들을 "invalid"로 변경
sed -i 's/fmt.Errorf("Invalid /fmt.Errorf("invalid /g' "$FILE"
sed -i 's/errors.New("Invalid /errors.New("invalid /g' "$FILE"
sed -i 's/Query argument /query argument /g' "$FILE"

echo "처리 완료: $FILE"
rm "${FILE}.bak"
