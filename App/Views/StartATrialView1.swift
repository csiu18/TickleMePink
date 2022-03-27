//
//  StartATrial.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import UIKit
import PencilKit
import SwiftUI

struct StartATrialView: View {
    var body: some View {
        let canvasView = PKCanvasView(frame: self.bounds)
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput  // uncomment to test on anyput, comment for apple pencil
        canvasView.becomeFirstResponder()
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
        canvasView.delegate = self
        canvasView.drawingPolicy = .anyInput  // uncomment to test on anyput, comment for apple pencil
        canvasView.becomeFirstResponder()
        view.addSubview(canvasView)
    }
}

extension ViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        let drawing = canvasView.drawing
        if (!drawing.strokes.isEmpty) {
            let stroke = drawing.strokes[0]
            let path = stroke.path
            let dData = DrawingData(context: self.viewContext)
            dData.strokes = stroke as NSObject?
            do {
                try self.viewContext.save()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            for point in path{
                print(point.location)
            }
        }
    }
}
