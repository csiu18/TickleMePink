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

struct StartATrialView: View {
    @Environment(\.managedObjectContext) var viewContext
    let datForm = DateFormatter()
    
    init() {
        datForm.timeZone = TimeZone.current
        datForm.dateFormat = "MMM-dd-yyyy hh:mm a"
    }
    
    var body: some View {
        VStack {
            StartATrialView1()
            Button(action: {saving(name: datForm.string(from: Date()))}) {
                Label("Save", systemImage: "folder")
            }
            Spacer()
        }
    }
    
    func saving(name: String) {
        let drawing = cView?.drawing
        if (!(drawing?.strokes.isEmpty ?? false)) {
            let dData = DrawingData(context: self.viewContext)
            var points: [[CGFloat]] = []
            dData.identifier = name
            for stroke in drawing!.strokes {
                for point in stroke.path{
                    points.append([point.location.x, point.location.y, point.timeOffset])
                    print(point.location)
                }
            }
            dData.strokes = points as NSObject?
            do {
                try self.viewContext.save()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
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
    /*func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let drawing = canvasView.drawing
        if (!drawing.strokes.isEmpty) {
            let stroke = drawing.strokes[0]
            let path = stroke.path
            let dData = DrawingData(context: self.viewContext)
            dData.strokes = stroke as NSObject?
            do {
                //try self.viewContext.save()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            for point in path{
                print(point.location)
            }
        }
    }*/
}

