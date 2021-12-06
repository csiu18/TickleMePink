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
        let canvasView = PKCanvasView(frame: self.view.bounds)
        //canvasView.drawingPolicy = .anyInput
        let toolPicker = PKToolPicker.init()
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
        view.addSubview(canvasView)
    }
}

