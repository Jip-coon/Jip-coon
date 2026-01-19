//
//  AllQuestViewController.swift
//  Feature
//
//  Created by 예슬 on 1/18/26.
//

import UI
import UIKit

public class AllQuestViewController: UIViewController {
    private let segmentControl = UnderlineSegmentControl(
        titles: ["오늘", "예정", "지난"]
    )
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundWhite
        navigationItem.title = "퀘스트"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupConstraints() {
        self.view.addSubview(segmentControl)
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            segmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            segmentControl.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
}
