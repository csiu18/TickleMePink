//
//  StartATrial.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import UIKit
import PencilKit
import SwiftUI
import AVFoundation
import AVKit

private var cView: PKCanvasView?
private var startTime: NSDate?
private var strokeStamps: [[TimeInterval]] = []
private var strokeStart: [TimeInterval] = []
private var currentMediaURL: String?
private var currentMediaBool: Bool?
private var currentImage: Data?
private var currentViewC: ViewController? = nil
private var currentViewStatic: ViewControllerNP? = nil
private var currentImgView: UIImageView?
private var currentVidLayer: AVPlayerLayer?
//private var currentImage:

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
                            if self.screens[index].type == 0 {
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .foregroundColor(Color.white)
                                    .frame(width: 250, height: 185)
                                    .overlay(Text("Instructions").foregroundColor(.black))
                            } else {
                                Image(uiImage: UIImage(data: self.screens[index].media!.data!)!)
                                    .resizable()
                                    .frame(width: 250, height: 185)
                                    .border(Color.black, width: 2)
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
    @State var screenNames: [String] = []
    
    var body: some View {
        if screenIndex < screenLength {
            let currType = screens[screenIndex].type
            //let currThing:String = screens[screenIndex].instructions!
            let mediaURL = screens[screenIndex].media?.url
            let mediaBool = screens[screenIndex].media?.isImage
            let mediaImage = screens[screenIndex].media?.data
            
            //[CHANGE CONDITIONS]**************************************
            //CURRENTLY HARD-CODED
            //When an instruction says "Testing2" it loads an image
            //When an instruction says "Testing5" it loads a video
            if currType == 0 {
                // [INSTRUCTIONS]
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
            } else if currType == 1 {
                // [IMAGE] (but empty)
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
                StartATrialViewNoPencil(mediaURL: mediaURL!, mediaBool: mediaBool!, mediaImage: mediaImage!).refreshing()
            } else if currType == 2 /*|| mediaBool == true */{
                // [IMAGE]
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
                StartATrialView1(mediaURL: mediaURL!, mediaBool: mediaBool!, mediaImage: mediaImage!).refreshing()
            } /*else if mediaBool == false {
                // [VIDEO]
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
                StartATrialView1(mediaURL: mediaURL!, mediaBool: mediaBool!, mediaImage: mediaImage!).refreshing()
            }*/ else {
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
                    Text("-----------------------------------------------------")
                    Text("Screen,x,y,time(sec)")
                    ForEach(0 ..< trialStrokes.count, id: \.self) { currentStrokes in
                        Text("\(self.screenNames[currentStrokes])")
                        List {
                            ForEach(0 ..< trialStrokes[currentStrokes].count, id: \.self) { i in
                                let strokes = trialStrokes[currentStrokes]
                                let path = strokes[i].path
                                ForEach(0 ..< path.count, id: \.self) { j in
                                    let currPoint = path[j].location
                                    Text("\(self.screenNames[currentStrokes]),\(currPoint.x),\(currPoint.y),\(path[j].timeOffset + strokeStamps[currentStrokes][i])" as String)
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
        dData.screenNames = self.screenNames as NSObject?
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
        if !strokeStart.isEmpty {
            strokeStamps.append(strokeStart)
            strokeStart = []
            //screenNames.append("Screen\(self.screenIndex)")
            let currMedia = self.screens[screenIndex - 1].media!
            let name:String = currMedia.name!
            let start = name.startIndex
            let end = name.index(before: name.lastIndex(of: ".") ?? name.endIndex)
            let printedName = String(name[start...end])
            screenNames.append("\(printedName)")
        }
        self.screenIndex += 1
        self.presentingTrial = true
    }
}

struct StartATrialView1: UIViewControllerRepresentable {
    public var mediaURL: String
    public var mediaBool: Bool
    public var mediaImage: Data
    @State public var refresh: Bool = false
    func makeUIViewController(context: Context) -> UIViewController {
        currentMediaURL = mediaURL
        currentMediaBool = mediaBool
        currentImage = mediaImage
        if (currentViewC != nil) {
            currentViewC?.backgroundView()
            startTime = NSDate()
        } else {
            currentViewC = ViewController()
            currentViewC?.setupPencilKit()
        }
        return currentViewC!
       // return ViewController()
    }
    func refreshing() -> StartATrialView1 {
        currentMediaURL = mediaURL
        currentMediaBool = mediaBool
        currentImage = mediaImage
        if (currentViewC != nil) {
            currentViewC?.backgroundView()
            startTime = NSDate()
        } else {
            currentViewC = ViewController()
            currentViewC?.setupPencilKit()
        }
        return self
        
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    
    }
}
/*
struct VideoView: View {
    let player = AVPlayer(url: Bundle.main.url(forResource: "idiotsincars", withExtension: "mp4")!)
    init() {
        player.isMuted = true
    }
    var body: some View {
        VideoPlayer(player: player)
    }
}*/

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
        canvasView.isOpaque = false
        canvasView.becomeFirstResponder()
        //view.addSubview(canvasView)
        backgroundView()
    }
    
    func backgroundView(){
        if currentImgView != nil {
            currentImgView?.removeFromSuperview()
        }
        if currentVidLayer != nil {
            currentVidLayer?.removeFromSuperlayer()
        }
        if currentMediaBool! {
            // [IMAGE]
            print("LOOK HERE")
            view.addSubview(cView!)
            //let url:URL = URL(string:currentMediaURL!)!
            //let data = NSData(contentsOf: url)
            //let imgView = UIImageView(image: UIImage(data: data! as Data))
            
            let nsImage = UIImage(data: currentImage!)!
            let imgView = UIImageView(image: nsImage)
            let subView = cView!.subviews[0]
            imgView.frame = CGRect(x: 0, y: 0, width: subView.bounds.width  , height:  subView.bounds.height)
            imgView.contentMode = .scaleAspectFit
            imgView.clipsToBounds = true
            currentImgView = imgView
            subView.addSubview(imgView)
            subView.sendSubviewToBack(imgView)
        } else if !currentMediaBool! {
            // [VIDEO]
            print("CURRENTMEDIAURL")
            print(currentMediaURL)
            let player = AVPlayer(url: URL(string:currentMediaURL!)!)
            let vidLayer = AVPlayerLayer(player: player)
            currentVidLayer = vidLayer
            //vidLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            vidLayer.frame = self.view.frame
            self.view.layer.addSublayer(vidLayer)
            player.play()
            view.addSubview(cView!)
        }
    }
}


extension ViewController: PKCanvasViewDelegate {
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        strokeStart.append(-startTime!.timeIntervalSinceNow)
    }
}

struct StartATrialViewNoPencil: UIViewControllerRepresentable {
    public var mediaURL: String
    public var mediaBool: Bool
    public var mediaImage: Data
    @State public var refresh: Bool = false
    func makeUIViewController(context: Context) -> UIViewController {
        currentMediaURL = mediaURL
        currentMediaBool = mediaBool
        currentImage = mediaImage
        if (currentViewStatic == nil) {
            currentViewStatic = ViewControllerNP()
        }
        currentViewStatic!.backgroundView()
        return currentViewStatic!
       // return ViewController()
    }
    func refreshing() -> StartATrialViewNoPencil {
        currentMediaURL = mediaURL
        currentMediaBool = mediaBool
        currentImage = mediaImage
        if currentViewStatic == nil {
            currentViewStatic = ViewControllerNP()
        }
        currentViewStatic!.backgroundView()
        return self
        
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    
    }
}

class ViewControllerNP: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backgroundView()
    }
    
    func backgroundView(){
        if currentImgView != nil {
            currentImgView?.removeFromSuperview()
        }
        if currentVidLayer != nil {
            currentVidLayer?.removeFromSuperlayer()
        }
        if currentMediaBool! {
            // [IMAGE]
            print("LOOK HERE")
            //let url:URL = URL(string:currentMediaURL!)!
            //let data = NSData(contentsOf: url)
            //let imgView = UIImageView(image: UIImage(data: data! as Data))
            
            let nsImage = UIImage(data: currentImage!)!
            let imgView = UIImageView(image: nsImage)
            imgView.frame = CGRect(x: 0, y: 0, width: view.bounds.width  , height:  view.bounds.height)
            imgView.contentMode = .scaleAspectFit
            imgView.clipsToBounds = true
            currentImgView = imgView
            view.addSubview(imgView)
            view.sendSubviewToBack(imgView)
        } else if !currentMediaBool! {
            // [VIDEO]
            print("CURRENTMEDIAURL")
            print(currentMediaURL)
            let player = AVPlayer(url: URL(string:currentMediaURL!)!)
            let vidLayer = AVPlayerLayer(player: player)
            currentVidLayer = vidLayer
            //vidLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            vidLayer.frame = self.view.frame
            self.view.layer.addSublayer(vidLayer)
            player.play()
        }
    }
}
