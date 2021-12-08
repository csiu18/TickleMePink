//
//  ViewController.swift
//  PencilKit Test
//
//  Created by Sam Chan on 12/6/21.
//

import UIKit
import PencilKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupPencilKit()
    }

    func setupPencilKit() {
        let CanvasView = PKCanvasView(frame: self.view.bounds)

//        canvasView.drawingPolicy = .anyInput  // uncomment to test on anyput
//        let toolPicker = PKToolPicker.init()
//        toolPicker.setVisible(true, forFirstResponder: canvasView)
        CanvasView.becomeFirstResponder()
        view.addSubview(CanvasView)
        print("tap1")
    }
}

extension ViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print("tap2")
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

