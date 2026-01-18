//
//  AllQuestViewController.swift
//  Feature
//
//  Created by 예슬 on 1/18/26.
//

import UI
import UIKit

public class AllQuestViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundWhite
        navigationItem.title = "퀘스트"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
