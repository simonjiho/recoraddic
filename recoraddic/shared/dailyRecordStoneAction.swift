////
////  DailyRecordStoneAction.swift
////  recoraddic
////
////  Created by 김지호 on 11/15/23.
////
//
//import Foundation
//import SwiftUI
//
//
//struct dailyRecordStoneAction: ViewModifier {
//    
//    var shellWidth: CGFloat
//    var shellHeight: CGFloat
//    
//    var actionVariables: ActionVariableInsets
//    
//    // shape에 따라 살짝 달라질 수 있으니
//    var shapeNum: Int
//    
//    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
////    @State private var timer = Timer.publish(every: 2, on: .main, in: .common).connect()
//
//    @Binding var trigger: Bool
//    
//    
//    
//    // x,y좌표는 중심을 기준으로 함.
//    // y좌표는 반대방향이므로 반대로 바꿔줘야함!!!
//    // modifier들 순서 바꿈에 따라 애니메이션이 바뀜. (ex: rotationEffect은 앞에 오면 제자리운동, 뒤에 가면 원점 중심으로 회전) (scale도 먼저 와야함.
//    func body(content: Content) -> some View {
//        
//            content
//                .keyframeAnimator(initialValue: DailyStoneAnimationValues(), trigger: trigger) { content, value in
//                    content
//                        .rotationEffect(value.angle)
//                        .scaleEffect(value.scale)
//                        .scaleEffect(x: value.horizontalStretch, y: value.verticalStretch)
//                        .offset(x: value.xOffset, y: value.yOffset)
//                        .opacity(value.opacity)
////                        .onAppear() {print(shellWidth, shellHeight)}
//
//
//                } keyframes: { _ in
//                    
//                    KeyframeTrack(\.angle) {
//                        for point in actionVariables.rotationPoints {
//                            switch point.curveStyle {
//                            case "linear":
//                                LinearKeyframe(.degrees(point.value), duration: point.duration)
//                            case "cubic":
//                                CubicKeyframe(.degrees(point.value), duration: point.duration)
//                            case "spring":
//                                if point.duration == 0.0 {
//                                    SpringKeyframe(.degrees(point.value))
//                                } else {
//                                    SpringKeyframe(.degrees(point.value), duration: point.duration)
//                                }
//                            default:
//                                LinearKeyframe(.degrees(point.value), duration: point.duration)
//                            }
//                        }
//
//                    }
//
//                    
//                    KeyframeTrack(\.xOffset) {
//                        for point in actionVariables.xOffsetPoints {
//                            switch point.curveStyle {
//                            case "linear":
//                                LinearKeyframe(point.value*shellWidth/2, duration: point.duration)
//                            case "cubic":
//                                CubicKeyframe(point.value*shellWidth/2, duration: point.duration)
//                            case "spring":
//                                if point.duration == 0.0 {
//                                    SpringKeyframe(point.value*shellWidth/2)
//                                } else {
//                                    SpringKeyframe(point.value*shellWidth/2, duration: point.duration)
//                                }
//                            default:
//                                LinearKeyframe(point.value*shellWidth/2, duration: point.duration)
//                            }
//                        }
//                    }
//                    
//                    KeyframeTrack(\.yOffset) {
//                        for point in actionVariables.yOffsetPoints {
//                            switch point.curveStyle {
//                            case "linear":
//                                LinearKeyframe(-point.value*shellHeight/2, duration: point.duration)
//                            case "cubic":
//                                CubicKeyframe(-point.value*shellHeight/2, duration: point.duration)
//                            case "spring":
//                                if point.duration == 0.0 {
//                                    SpringKeyframe(-point.value*shellHeight/2)
//                                } else {
//                                    SpringKeyframe(-point.value*shellHeight/2, duration: point.duration)
//                                }
//                            default:
//                                LinearKeyframe(-point.value*shellHeight/2, duration: point.duration)
//                            }
//                        }
//                    }
//                    KeyframeTrack(\.scale) {
//                        for point in actionVariables.scalePoints {
//                            switch point.curveStyle {
//                            case "linear":
//                                LinearKeyframe(point.value, duration: point.duration)
//                            case "cubic":
//                                CubicKeyframe(point.value, duration: point.duration)
//                            case "spring":
//                                if point.duration == 0.0 {
//                                    SpringKeyframe(point.value)
//                                } else {
//                                    SpringKeyframe(point.value, duration: point.duration)
//                                }
//                            default:
//                                LinearKeyframe(point.value, duration: point.duration)
//                            }
//                        }
//                    }
//                    KeyframeTrack(\.horizontalStretch) {
//                        for point in actionVariables.xStretchePoints {
//                            switch point.curveStyle {
//                            case "linear":
//                                LinearKeyframe(point.value, duration: point.duration)
//                            case "cubic":
//                                CubicKeyframe(point.value, duration: point.duration)
//                            case "spring":
//                                if point.duration == 0.0 {
//                                    SpringKeyframe(point.value)
//                                } else {
//                                    SpringKeyframe(point.value, duration: point.duration)
//                                }
//                            default:
//                                LinearKeyframe(point.value, duration: point.duration)
//                            }
//                        }
//                    }
//                    KeyframeTrack(\.verticalStretch) {
//                        for point in actionVariables.yStretchePoints {
//                            switch point.curveStyle {
//                            case "linear":
//                                LinearKeyframe(point.value, duration: point.duration)
//                            case "cubic":
//                                CubicKeyframe(point.value, duration: point.duration)
//                            case "spring":
//                                if point.duration == 0.0 {
//                                    SpringKeyframe(point.value)
//                                } else {
//                                    SpringKeyframe(point.value, duration: point.duration)
//                                }
//                            default:
//                                LinearKeyframe(point.value, duration: point.duration)
//                            }
//                        }
//                    }
//                    
//                    
//                    KeyframeTrack(\.opacity) {
//                        for point in actionVariables.opacityPoints {
//                            switch point.curveStyle {
//                            case "linear":
//                                LinearKeyframe(point.value, duration: point.duration)
//                            case "cubic":
//                                CubicKeyframe(point.value, duration: point.duration)
//                            case "spring":
//                                if point.duration == 0.0 {
//                                    SpringKeyframe(point.value)
//                                } else {
//                                    SpringKeyframe(point.value, duration: point.duration)
//                                }
//                            default:
//                                LinearKeyframe(point.value, duration: point.duration)
//                            }
//                        }
//                    }
//                    
//                }
//
//        }
//        
//
//    }
//
//struct DailyStoneAnimationValues {
//    
//    var angle:Angle = Angle.zero
//    var xOffset:CGFloat = 0.0
//    var yOffset:CGFloat = 0.0
//    var scale:CGFloat = 1.0
//    var horizontalStretch:CGFloat = 1.0
//    var verticalStretch:CGFloat = 1.0
//    var opacity:CGFloat = 1.0
//    var animationTime: CGFloat = 3.0
//}
//
//extension View {
//    func dailyRecordStoneAction(
//        shellWidth:CGFloat,
//        shellHeight:CGFloat,
//        actionVariables:ActionVariableInsets,
//        shapeNum: Int,
//        trigger:Binding<Bool>) -> some View {
//        self.modifier(recoraddic.dailyRecordStoneAction(shellWidth: shellWidth, shellHeight: shellHeight, actionVariables: actionVariables, shapeNum: shapeNum, trigger: trigger))
//    }
////    func dailyStoneAction(action:Int, shape:Int) -> some View {
////        self.modifier(recoraddic.dailyStoneAction(actionNum:action, shapeNum:shape))
////    }
//}
//
//
//// 0.0 means the end of animation(in SpringKeyframe) -> duration: nil(no input)
//
//
//
//
//
//
//// below code is failed (gpt solutions)
//
//
////func keyframe<T: KeyframeTrackContent>(of point: TimeCurvePoint) -> T where T.Value == CGFloat {
////    switch point.curveStyle {
////    case "linear":
////        return LinearKeyframe(point.value, duration: point.duration) as! T
////    case "cubic":
////        return CubicKeyframe(point.value, duration: point.duration) as! T
////    case "spring":
////        if point.duration == 0.0 {
////            return SpringKeyframe(point.value) as! T
////        } else {
////            return SpringKeyframe(point.value, duration: point.duration) as! T
////        }
////    default:
////        return LinearKeyframe(point.value, duration: point.duration) as! T
////    }
////}
//
//
//
//
//
//
////
////protocol MyKeyframeTrackContent: KeyframeTrackContent where Value == CGFloat {}
////
////extension LinearKeyframe: MyKeyframeTrackContent {}
////extension CubicKeyframe: MyKeyframeTrackContent {}
////extension SpringKeyframe: MyKeyframeTrackContent {}
////
////func keyframe(of point: TimeCurvePoint) -> some MyKeyframeTrackContent {
////    switch point.curveStyle {
////    case "linear":
////        return LinearKeyframe(point.value, duration: point.duration)
////    case "cubic":
////        return CubicKeyframe(point.value, duration: point.duration)
////    case "spring":
////        if point.duration == 0.0 {
////            return SpringKeyframe(point.value)
////        } else {
////            return SpringKeyframe(point.value, duration: point.duration)
////        }
////    default:
////        return LinearKeyframe(point.value, duration: point.duration)
////    }
////}
//
//
//
////func createKeyframeTrack<Root>(for points: [TimeCurvePoint], keyPath: WritableKeyPath<Root, CGFloat>) -> KeyframeTrack<Root, CGFloat, some KeyframeTrackContent> {
////    return KeyframeTrack(keyPath) {
////        for point in points {
////            switch point.curveStyle {
////            case "linear":
////                LinearKeyframe(point.value, duration: point.duration)
////            case "cubic":
////                CubicKeyframe(point.value, duration: point.duration)
////            case "spring":
////                if point.duration == 0.0 {
////                    SpringKeyframe(point.value)
////                } else {
////                    SpringKeyframe(point.value, duration: point.duration)
////                }
////            default:
////                LinearKeyframe(point.value, duration: point.duration)
////            }
////        }
////    }
////}
//
////struct MyKeyframe: KeyframeTrackContent {
////    var value: CGFloat
////    var duration: TimeInterval
////    var curveStyle: String
////
////    var body: some KeyframeTrackContent {
////        switch curveStyle {
////        case "linear":
////            return LinearKeyframe(value, duration: duration)
////        case "cubic":
////            return CubicKeyframe(value, duration: duration)
////        case "spring":
////            if duration == 0.0 {
////                return SpringKeyframe(value)
////            } else {
////                return SpringKeyframe(value, duration: duration)
////            }
////        default:
////            return LinearKeyframe(value, duration: duration)
////        }
////    }
////}
////
////
////func createKeyframeTrack<Root>(for points: [TimeCurvePoint], keyPath: WritableKeyPath<Root, CGFloat>) -> KeyframeTrack<Root, CGFloat, MyKeyframe> {
////    return KeyframeTrack(keyPath) {
////        for point in points {
////            MyKeyframe(value: point.value, duration: point.duration, curveStyle: point.curveStyle)
////        }
////    }
////}
//
