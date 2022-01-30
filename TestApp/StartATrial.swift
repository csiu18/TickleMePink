//
//  StartATrial.swift
//  TestApp
//
//  Created by Cindy Siu on 1/30/22.
//

import UIKit
import PencilKit
import SwiftUI

struct StartATrial: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    
    }
}

class ViewController: UIViewController {
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
            for point in path{
                print(point.location)
            }
        }
    }
}
