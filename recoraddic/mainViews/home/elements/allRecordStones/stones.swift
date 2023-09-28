//
//  stones.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/07/19.
//


// 몇가지 color variable 조합을 통해 color를 return하기
// 스킨이 있으면 color variable말고 texture 불러오기
// 꾸미기 장식 있으면 위에 덮기

import Foundation

struct VerIn {
    var coordinate: SIMD4<Float>
    var color: SIMD4<Float>
}



class Stone {
    
    var Vertices: [VerIn]
    var center: SIMD4<Float>
    var speedY: Float
    var deltaTime: Float
    let c1,c2,c3: Float
    
    var stoneIsHeld: Bool = false
    
    init(initPosition: SIMD4<Float>, initSpeedY: Float, colorFactors: SIMD3<Float>, interval: Float) {
        
        center = initPosition
        speedY = initSpeedY
        deltaTime = interval
        
        c1 = colorFactors[0]
        c2 = colorFactors[1]
        c3 = colorFactors[2]
        
        Vertices = [
            // 2D positions,    RGBA colors
            VerIn(coordinate: SIMD4<Float>(center.x + 30, center.y + 30, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 40, center.y + 20, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 40, center.y - 10, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 20, center.y - 15, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 20, center.y - 15, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 40, center.y - 10, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 40, center.y + 20, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 30, center.y + 30, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 0, center.y + 35, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 30, center.y + 30, 0, 1), color: SIMD4<Float>(c1,c2,c3,1)),

        ]
    }
    
    func move() {
        
        if stoneIsHeld {return}
        
        
        if (center.y < -100) {
            center.y = -100
            speedY = 5
        }
        else {
            speedY = speedY - deltaTime*4
        }
        
        center.y = center.y + speedY
        
        Vertices = [
            // 2D positions,    RGBA colors
            VerIn(coordinate: SIMD4<Float>(center.x + 30, center.y + 30, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 40, center.y + 20, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 40, center.y - 10, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 20, center.y - 15, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 20, center.y - 15, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 40, center.y - 10, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 40, center.y + 20, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 30, center.y + 30, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 0, center.y + 35, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 30, center.y + 30, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),

        ]// 나중에 반복문으로 바꾸기
    }
    
    func move(point: SIMD2<Float>) {
        
        if !stoneIsHeld {return}
        

        center.x = point.x
        center.y = point.y
        
        Vertices = [
            // 2D positions,    RGBA colors
            VerIn(coordinate: SIMD4<Float>(center.x + 30, center.y + 30, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 40, center.y + 20, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 40, center.y - 10, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 20, center.y - 15, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 20, center.y - 15, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 40, center.y - 10, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 40, center.y + 20, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x - 30, center.y + 30, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 0, center.y + 35, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
            VerIn(coordinate: SIMD4<Float>(center.x + 30, center.y + 30, center.z, 1), color: SIMD4<Float>(c1,c2,c3,1)),
        ]// 나중에 반복문으로 바꾸기
    }
    
    func isInterior(point: SIMD2<Float>) -> Bool {
        // if mousepointer is inside interior, return true, otherwise, false
        // can be complex if the view is real 3d model
                
        var boundary = [CGPoint]()
        for vertex in Vertices {
            let x = CGFloat(vertex.coordinate.x)
            let y = CGFloat(vertex.coordinate.y)
            let point = CGPoint(x: x, y: y)
//            if !boundary.contains(point) { boundary.append(point) }
            boundary.append(point)
        }
        
        let x2 = CGFloat(point.x)
        let y2 = CGFloat(point.y)
        let cgPoint = CGPoint(x: x2, y: y2)
        
        
        let out = windingNumberAlgorithm(coordinates: cgPoint, polygon: boundary)
        
        return out
        // assumed it is 2d...
        
        
    }

}


class DailyStone: Stone {
    
}
