# idea&plan&simpleNote

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

### Section header

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->


// dailyStone은 사각형 grid 안에 있으며, 각각의 grid를 꾸밀 수 있음, 클릭 시 액션 발동(상시 액션 발동도 가능-> 저전력 모드에서는 클릭 시에만 액션 발동)
// 클릭 시 액션 발동하는 설정으로 되어있으면 클릭 안하고 있으면 표정
// 클릭 시 해당 grid 확대 됨
// recordStone은 더 큰 grid로 표현되며, 클릭하면 해당 기간의 dailyStone들만 있는 grid 볼 수 있음
// dailyStone action&effects


// 기본 액션(표정도 결합되어 있음)
// 1. 신난 표정으로 jump slightly(확 점프해서 천천히 떨어지기)
// 2. jump and 세로로 서기
// 3. 양쪽 끝으로 기울여서 튕기는거 3-5회 반복
// 4. 통 튕겨서 거꾸로 뒤집혔다가 다시 통 튕겨서 원래대로 돌아오기
// 5. 벽에 한번씩 튕겨서 떨어지기...?
// 6. 점프해서 천장에 붙었다가 떨어지기
// 7. 사방의 벽을 타고 미끄러지듯이 한바퀴 돌기
// 8. 랜덤한 위치로 순간이동 후 떨어지기
// 9. 마리오 2,3단 점프
// 10. 핑글핑글 돌고 어지러운 표정
// 11. 갸웃하며 기울이기
// 12. 방 안을 물속처럼 유영하기
// 13. 방 옆쪽 끝으로 가서 반정도 바깥에 나가있으면, 나간 쪽이 반대편에서 나타남. 그 상태로 좀 있다가 더 가서 다시 돌아오기


// 100% 전용
// 1. 물풍선 위에서 눌렀다가 뗀것 마냥 보잉보잉보잉보잉보잉
// 2. 양옆으로 흔들기
// 3. 화르르 불타기
// 4. 한바퀴 바닥에서 돌기
// 5. 스무스하게


// dailyStone 특수 액션
// 1. 팔근육 자랑(운동)
// 2. 노트북 하기(IT)
// 3. 필기 하기
// 4. 이상한 나라의 앨리스 고양이처럼 표정만 남기고 사라졌다가 나타나기
// 5. 녹아내렸다가 뭉치기(?) -> 구현 어려움
// 6. 슬릭백!
// 7. 맨발 걷기!
// 트렌드 반영해서 잘 출시하기



데이터 저장 효율성을 위해 나중에 Int8(-128~127)이나 Int16(-32768~32767) 사용하기. float 최대한 사용하지 말기


purpose 없애고 quest를 record 바로 아래에 두기,


.transition 써서 뷰마다 appear, disappear 때 effect 쓰기


dailyRecord에 additional checklist 데이터


1.purpose의 개수 2.purpose의 종류에 따라 record가 가지고 있는 quest데이터 UI의 정렬


