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
    @State private var placeholder = ["Placeholder1", "Placeholder2", "Placeholder3", "Placeholder4", "Placeholder5"]
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
    init(x: String, dData: DrawingData) {
        self.x = x
        self.dData = dData
        exportName = x
    }
    var body: some View {
        VStack{
            TextField(text: $exportName, prompt: Text("Name Your File..")) {
                Text("File Name")
            }.multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, -35)
            List {
                ForEach(dData.strokes as! [[CGFloat]], id: \.self) { point in
                    VStack {
                        Text("\(point[0]), \(point[1]), \(point[2])")
                    }
                }
            }.padding(15).padding(.top, 0)
            Button(action: {exportButton(points: dData.strokes as! [[CGFloat]], fileName: exportName, defaultName: dData.identifier!)}) {
                Label("Export", systemImage: "folder")
            }.padding(.bottom, 20)
        }.background(Color(white: 0.95))
    }
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
}

struct InventoryItem: Identifiable {
    var id: String
    var dData: DrawingData
}
