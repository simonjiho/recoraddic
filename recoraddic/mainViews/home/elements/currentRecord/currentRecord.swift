//
//  currentRecord.swift
//  recoraddiction
//
//  Created by 김지호 on 2023/06/13.
//


//import "shadingfunc.metal"
import Foundation
import SwiftUI


//struct GaugeProgressStyle: ProgressViewStyle {
//    var strokeColor = Color.blue
//    var strokeWidth = 25.0
//
//    func makeBody(configuration: Configuration) -> some View {
//        let fractionCompleted = configuration.fractionCompleted ?? 0
//
//        return ZStack {
//            Circle()
//                .stroke(lineWidth: 5)
//                .opacity(0.3)
//                .foregroundColor(strokeColor)
//
//            Circle()
//                .trim(from: 0, to: CGFloat(fractionCompleted))
//                .stroke(style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round, lineJoin: .round))
//                .foregroundColor(strokeColor)
//                .rotationEffect(Angle(degrees: 270.0))
//        }
//    }
//}




// 뷰를 가다듬어라~~~~

struct CurrentRecord: View {
    var currentRecord: Record
//    var currentRecordModel = recordModel_Basic<recordName_Basic>()
//    var figures: RecordModelFig = currentRecordModel.figures
//    var positions: RecordModelPos = currentRecordModel.positions
//    // chosen by currentRecordData.adjustedModel later on
//
//
//    var items: [Group]
//
    

    var body: some View {
        CurrentRecordView(currentRecord)
    }
    
}



struct CurrentRecordView: View {
    
    var model: String
    var data: Record
    
    init(_ data: Record) {
        self.data = data
        self.model = data.adjustedModel
    }
    
    var body: some View {
        if model == "default" {
            RecordModel_default(data)
        }
    }
    
}








//#if os(iOS)
//import UIKit
//class BoxView: UIView {
//    let nameLabel = UILabel()
//    let gaugeBar = UIProgressView(progressViewStyle: .default)
//    let lockButton = UIButton(type: .system)
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupViews()
//    }
//
//    func setupViews() {
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        gaugeBar.translatesAutoresizingMaskIntoConstraints = false
//        lockButton.translatesAutoresizingMaskIntoConstraints = false
//
//        addSubview(nameLabel)
//        addSubview(gaugeBar)
//        addSubview(lockButton)
//
//        NSLayoutConstraint.activate([
//            nameLabel.topAnchor.constraint(equalTo: topAnchor),
//            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//
//            gaugeBar.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
//            gaugeBar.leadingAnchor.constraint(equalTo: leadingAnchor),
//            gaugeBar.trailingAnchor.constraint(equalTo: trailingAnchor),
//
//            lockButton.topAnchor.constraint(equalTo: gaugeBar.bottomAnchor, constant: 8),
//            lockButton.centerXAnchor.constraint(equalTo: centerXAnchor)
//        ])
//
//        lockButton.setTitle("Lock", for: .normal)
//        lockButton.addTarget(self, action: #selector(lockButtonTapped), for: .touchUpInside)
//    }
//
//    @objc func lockButtonTapped() {
//        if lockButton.currentTitle == "Lock" {
//            lockButton.setTitle("Unlock", for: .normal)
//        } else {
//            lockButton.setTitle("Lock", for: .normal)
//        }
//    }
//}
//
//#endif
//
//
//#if(macOS)
//import Cocoa
//
//class BoxView: NSView {
//    let nameLabel = NSTextField(labelWithString: "")
//    let gaugeBar = NSProgressIndicator()
//    let lockButton = NSButton(title: "Lock", target: self, action: #selector(lockButtonTapped))
//
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        setupViews()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupViews()
//    }
//
//    func setupViews() {
//        gaugeBar.style = .bar
//        gaugeBar.isIndeterminate = false
//        gaugeBar.minValue = 0
//        gaugeBar.maxValue = 1
//
//        addSubview(nameLabel)
//        addSubview(gaugeBar)
//        addSubview(lockButton)
//
//        NSLayoutConstraint.activate([
//            nameLabel.topAnchor.constraint(equalTo: topAnchor),
//            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//
//            gaugeBar.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
//            gaugeBar.leadingAnchor.constraint(equalTo: leadingAnchor),
//            gaugeBar.trailingAnchor.constraint(equalTo: trailingAnchor),
//
//            lockButton.topAnchor.constraint(equalTo: gaugeBar.bottomAnchor, constant: 8),
//            lockButton.centerXAnchor.constraint(equalTo: centerXAnchor)
//        ])
//    }
//
//    @objc func lockButtonTapped() {
//        if lockButton.title == "Lock" {
//            lockButton.title = "Unlock"
//        } else {
//            lockButton.title = "Lock"
//        }
//    }
//}
//#endif
