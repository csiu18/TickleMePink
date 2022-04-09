//
//  StartATrial.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import UIKit
import PencilKit
import SwiftUI

private var cView: PKCanvasView?
private var startTime: NSDate?
private var strokeStamps: [[TimeInterval]] = []
private var strokeStart: [TimeInterval] = []

struct StartATrialView: View {
    @State private var presentingTrial = false
    @State private var partCondIndex = -1
    @State private var screens:[Screen] = []
    @State private var screenLength = -1
    @State private var screenIndex = 0
    @State private var partNumber = ""
    @FocusState private var tfFocus: Bool
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(entity: TrialSettings.entity(), sortDescriptors: [])
        var trialSettings:FetchedResults<TrialSettings>
    
    private var gridLayout = [GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(25)),
                              GridItem(.adaptive(minimum: 250)), GridItem(.fixed(50))]
    
    let datForm = DateFormatter()
    
    init() {
        datForm.timeZone = TimeZone.current
        datForm.dateFormat = "MMM-dd-yyyy hh:mm a"
    }
    
    var body: some View {
        Text("Start Trial").font(.title)
        VStack(spacing: 20){
            VStack(alignment: .leading) {
                Text("Participant Number")
                TextField("", text: $partNumber).textFieldStyle(.roundedBorder).focused($tfFocus)
                Text("Participant Condition")
                Picker("", selection: $partCondIndex) {
                    Text("Select Participant Condition...").tag(-1)
                    
                    ForEach(self.trialSettings.indices, id:\.self) { index in
                        Text(self.trialSettings[index].partCondition ?? "").tag(index)
                    }.onChange(of: self.partCondIndex) { newTrialSetting in
                        if partCondIndex != -1 {
                            self.screens = self.trialSettings[self.partCondIndex].screenToTrialSettings?.array as! [Screen]
                        } else {
                            self.screens = []
                        }
                        self.screenLength = screens.count
                    }
                }.padding(.bottom, 50)
            
                Text("Trial Sequence")
                ScrollView() {
                    LazyVGrid(columns:gridLayout) {
                        ForEach(self.screens.indices, id: \.self) { index in
                            switch self.screens[index].type{
                                case 0:
                                    label: do {
                                        Rectangle()
                                            .stroke(Color.black, lineWidth: 2)
                                            .foregroundColor(Color.white)
                                            .frame(width: 250, height: 185)
                                            .overlay(Text("Instructions").foregroundColor(.black))
                                    }
                                default:
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 2)
                                        .foregroundColor(Color.white)
                                        .frame(width: 250, height: 185)
                                        .overlay(Text("No Type").foregroundColor(.white))
                            
                            }
                            Spacer()
                        }
                    }
                }
            }
            HStack {
                Spacer().frame(maxWidth: .infinity)
                Button(action: {
                    tfFocus = false
                    startTrial()
                }, label: {
                    Text("Start Trial")
                        .padding(8)
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .cornerRadius(8)
                })
            }.padding(10)
            /*
            Button(action: {saving(name: datForm.string(from: Date()))}) {
                Label("Save", systemImage: "folder")
            }
            Button("Testing View") {
                self.presentingInstr = true
            }*/
            Spacer()
        }.padding(20)
        .fullScreenCover(isPresented: $presentingTrial) {
            TrialView(presentingTrial: self.$presentingTrial, screenIndex: self.screenIndex, screenLength: self.screenLength, screens: self.screens, partNum: self.partNumber, partCond: self.trialSettings[partCondIndex].partCondition!)
        }
    }
    
    func resetIndex() {
        self.screenIndex = 0
    }
    
    func startTrial() {
        if screenIndex < screenLength {
            self.presentingTrial = true
        } else {
            print("[startTrial]: screenLength invalid for trial start")
        }
    }
}

struct TrialView: View {
    @Binding var presentingTrial: Bool
    @State var screenIndex: Int
    @State var screenLength: Int
    @State var screens: [Screen]
    @State var partNum: String
    @Environment(\.managedObjectContext) var viewContext
    @State var trialStrokes: [[PKStroke]] = []
    @State var partCond: String
    
    var body: some View {
        if screenIndex < screenLength {
            let currType = screens[screenIndex].type
            let currThing:String = screens[screenIndex].instructions!
            if currType == 0 && currThing != "Testing2" {
                VStack {
                    HStack {
                        Spacer().frame(maxWidth: .infinity)
                        Button(action: incrAndRefresh, label: {
                            Text("Next")
                                .padding(8)
                                .foregroundColor(Color.white)
                                .background(Color.red)
                                .cornerRadius(8)
                        })
                        Spacer()
                    }.padding(10)
                    Spacer()
                    Text(screens[screenIndex].instructions!)
                    Spacer()
                }
            } else if currType == 1 || currThing == "Testing2" {
                //static
                HStack {
                    Spacer().frame(maxWidth: .infinity)
                    Button(action: incrAndRefresh, label: {
                        Text("Next")
                            .padding(8)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .cornerRadius(8)
                    })
                    Spacer()
                }.padding(10)
                StartATrialView1()
            } else if currType == 2 {
                //interactive
                HStack {
                    Spacer().frame(maxWidth: .infinity)
                    Button(action: incrAndRefresh, label: {
                        Text("Next")
                            .padding(10)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                            .cornerRadius(4)
                    })
                    Spacer()
                }.padding(10)
                StartATrialView1()
            } else {
                Text("[currType]: Screen Type Error")
                Button("Close") {
                    strokeStamps = []
                    strokeStart = []
                    self.presentingTrial = false
                }
            }
        } else {
            // save screen
            Spacer()
            Text("Confirm Trial Details and Data")
            Spacer()
            VStack(alignment: .leading) {
                List {
                    Text("Participant Number: \(self.partNum)")
                    Text("Participant Condition: \(self.partCond)")
                    ForEach(0 ..< trialStrokes.count, id: \.self) { currentStrokes in
                        List {
                            ForEach(0 ..< trialStrokes[currentStrokes].count, id: \.self) { i in
                                let strokes = trialStrokes[currentStrokes]
                                let path = strokes[i].path
                                ForEach(0 ..< path.count, id: \.self) { j in
                                    Text("\(path[j].location) and \(path[j].timeOffset + strokeStamps[currentStrokes][i])" as String)
                                }
                            }
                        }.overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .listStyle(.plain)
                        .frame(height: 300)
                    }
                }.overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            strokeStart = []
                            saving()
                            strokeStamps = []
                            self.presentingTrial = false
                        }, label: {
                            Text("Save Data")
                                .padding(10)
                                .foregroundColor(Color.white)
                                .background(Color.blue)
                                .cornerRadius(6)
                        })
                        Button("Close") {
                            strokeStart = []
                            strokeStamps = []
                            self.presentingTrial = false
                        }
                    }
                    Spacer()
                }
            }
            .padding(40).padding(.top, 0)
        }
    }
    
    func saving() {
        let datForm = DateFormatter()
        datForm.timeZone = TimeZone.current
        datForm.dateFormat = "MMM-dd-yyyy hh:mm a"
        let date = datForm.string(from: Date())
        var particNum = partNum
        if particNum == "" {
            particNum = date
        }
        let dData = DrawingData(context: self.viewContext)
        var points: [[[CGFloat]]] = []
        var currentPoints: [[CGFloat]] = []
        var timeStamps: [[TimeInterval]] = []
        var currentTimes: [TimeInterval] = []
        for trialIndex in 0..<trialStrokes.count {
            let trialStroke = trialStrokes[trialIndex]
            for currentIndex in 0..<trialStroke.count {
                let currentStroke = trialStroke[currentIndex]
                for point in currentStroke.path {
                    currentPoints.append([point.location.x, point.location.y])
                    currentTimes.append(point.timeOffset + strokeStamps[trialIndex][currentIndex])
                }
            }
            points.append(currentPoints)
            timeStamps.append(currentTimes)
            currentPoints = []
            currentTimes = []
        }
        dData.strokes = points as NSObject?
        dData.identifier = particNum
        dData.trialDate = date
        dData.pointTimes = timeStamps as NSObject?
        dData.partCond = self.partCond
        do {
            try self.viewContext.save()
        } catch {
            print("[saving] error: \(error.localizedDescription)")
        }
    }
    
    func incrAndRefresh() {
        let drawing = cView?.drawing
        if (!(drawing?.strokes.isEmpty ?? true)) {
            trialStrokes.append(drawing!.strokes)
        }
        cView?.drawing = PKDrawing()
        self.presentingTrial = false
        self.screenIndex += 1
        self.presentingTrial = true
        if !strokeStart.isEmpty {
            strokeStamps.append(strokeStart)
            strokeStart = []
        }
    }
}

struct MediaView: View {
    @Binding var presentingMedia: Bool
    var body: some View {
        VStack{
            StartATrialView1()
            
        }
    }
}

struct StartATrialView1: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    
    }
}

class ViewController: UIViewController {
    @Environment(\.managedObjectContext) var viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupPencilKit()
        startTime = NSDate()
    }
    
    func setupPencilKit() {
        let canvasView = PKCanvasView(frame: self.view.bounds)
        cView = canvasView
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput  // uncomment to test on anyput, comment for apple pencil
        canvasView.becomeFirstResponder()
        view.addSubview(canvasView)
    }
}


extension ViewController: PKCanvasViewDelegate {
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        strokeStart.append(-startTime!.timeIntervalSinceNow)
    }
}

