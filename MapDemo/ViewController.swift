//
//  ViewController.swift
//  MapDemo
//
//  Created by jiang hong on 2023/12/1.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
    }


    @IBAction func enterMapVCAction() {
        let vc = GMMainViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

