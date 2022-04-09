//
//  ExportData.swift
//  App
//
//  Created by Cindy Siu on 2/28/22.
//

import SwiftUI
import PencilKit

// Trial name, participant id, timestamp
// remember to fix the text issue with filename

struct ExportDataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showPop = false
    @State private var listItem = "";
    @State private var prevItem: InventoryItem?
    @FetchRequest(entity: DrawingData.entity(), sortDescriptors: [])
        var coordData: FetchedResults<DrawingData>
    var body: some View {
        VStack(alignment: .leading) {
            Text("ApplePencil Recorded Datasets").foregroundColor(Color.gray).font(.system(size: 20.0))
            List {
                Section {
                    ForEach(coordData, id: \.self) { x in
                        Text(x.identifier!).onTapGesture {
                            prevItem = InventoryItem(id: x.identifier!, dData: x)
                            showPop = true
                        }.foregroundColor(Color.blue)
                    }.onDelete(perform: deleteStrokes(at:))
                }
            }.overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
                .toolbar {
                    EditButton()
                }
                .sheet(item: $prevItem) { item in
                    popoverView(x: item.id, dData: item.dData)
                }
        }.navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .padding(40).padding(.top, 0)
        Spacer()
    }
    
    func deleteStrokes(at offsets: IndexSet) {
        for index in offsets {
            let strokes = coordData[index]
            viewContext.delete(strokes)
        }
        try? viewContext.save()
    }
}

struct ExportData_Previews: PreviewProvider {
    static var previews: some View {
        ExportDataView()
    }
}

struct popoverView: View {
    var x: String
    @State private var exportName = ""
    @Environment(\.presentationMode) var presentationMode
    var dData: DrawingData
    var trialStrokes: [[[CGFloat]]]
    var timeStamps: [[TimeInterval]]
    init(x: String, dData: DrawingData) {
        self.x = x
        self.dData = dData
        self.trialStrokes = dData.strokes as! [[[CGFloat]]]
        self.timeStamps = dData.pointTimes as! [[TimeInterval]]
        self.exportName = x
    }
    var body: some View {
        VStack{
            TextField(text: $exportName, prompt: Text("Name Your File..")) {
                Text("File Name")
            }.multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, -35)
            List {
                Text("Participant Number: \(dData.identifier!)")
                Text("Participant Condition: \(dData.partCond!)")
                Text("Date Recorded: \(dData.trialDate!)")
                Text("-------------------------------------------------------------------")
                Text("x,y,time(sec)")
                ForEach(0 ..< trialStrokes.count, id: \.self) { currentIndex in
                    let currentStroke = trialStrokes[currentIndex]
                    let currentTimes = timeStamps[currentIndex]
                    ForEach(0 ..< currentStroke.count, id: \.self) { i in
                        let point = currentStroke[i]
                        let currentTime = currentTimes[i]
                        Text("\(point[0]),\(point[1]),\(currentTime)" as String)
                    }
                    Text("-------------------------------------------------------------------")
                }
            }.padding(15).padding(.top, 0)
            Button(action: {exportButton(strokeSet: trialStrokes, timeSet: timeStamps, fileName: exportName, defaultName: dData.identifier! + "_" + dData.trialDate!)}) {
                Label("Export", systemImage: "folder")
            }.padding(.bottom, 20)
        }.background(Color(white: 0.95))
    }
    
    /*
    func exportButton(points: [[CGFloat]], fileName: String, defaultName: String) {
        presentationMode.wrappedValue.dismiss()
        var tester = ""
        for point in points {
            tester = tester + "(" + (point[0].description) + ")" + ", "
        }
        tester.removeLast()
        tester.removeLast()
        var name = fileName
        if (name == "") {
            name = defaultName
        }
        let directory = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name + ".txt")
        do {
            try tester.write(to: directory!, atomically: true, encoding: .utf8)
        } catch {
            print("Error in export: \(error.localizedDescription)")
        }
        var filesToShare = [Any]()
        filesToShare.append(directory!)
        /* Delaying the new popup because before the popup was showing before
         * the other popup finished dismissing.
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let actView = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            actView.popoverPresentationController?.sourceView = UIView()
            let conScenes = UIApplication.shared.connectedScenes.first
            let windowSc = conScenes as? UIWindowScene
            windowSc?.keyWindow?.rootViewController?.present(actView, animated: true, completion: nil)
        }
    }
     */
    func exportButton(strokeSet: [[[CGFloat]]], timeSet: [[TimeInterval]], fileName: String, defaultName: String) {
        presentationMode.wrappedValue.dismiss()
        var name = fileName
        if (name == "") {
            name = defaultName
        }
        let directory = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name + ".txt")
        /*var fileHandle = FileHandle()
        do {
            fileHandle = try FileHandle(forUpdating: directory!)
        } catch {
            print("[exportButton] error: \(error.localizedDescription)")
        }*/
        var writtenString = "Participant Number: \(dData.identifier!)\nParticipant Condition: \(dData.partCond!)\nDate Recorded:\(dData.trialDate!)\n-----------------------------------------------------------\nx,y,time(sec)\n"
        for i in 0..<strokeSet.count {
            let currStroke = strokeSet[i]
            let currTimes = timeSet[i]
            for j in 0..<currStroke.count {
                let point = currStroke[j]
                let time = currTimes[j]
                writtenString = writtenString + "\(point[0]),\(point[1]),\(time)\n"
                //fileHandle.seekToEndOfFile()
                //fileHandle.write(writtenString.data(using: .utf8)!)
            }
            writtenString = writtenString + "-----------------------------------------------------------\n"
        }
        do {
            try writtenString.write(to: directory!, atomically: true, encoding: .utf8)
        } catch {
            print("Error in export: \(error.localizedDescription)")
        }
        var filesToShare = [Any]()
        filesToShare.append(directory!)
        /* Delaying the new popup because before the popup was showing before
         * the other popup finished dismissing.
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let actView = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            actView.popoverPresentationController?.sourceView = UIView()
            let conScenes = UIApplication.shared.connectedScenes.first
            let windowSc = conScenes as? UIWindowScene
            windowSc?.keyWindow?.rootViewController?.present(actView, animated: true, completion: nil)
            //fileHandle.closeFile()
        }
    }
}

struct InventoryItem: Identifiable {
    var id: String
    var dData: DrawingData
}
