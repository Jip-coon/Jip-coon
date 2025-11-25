//
//  ProfileEditViewController.swift
//  Feature
//
//  Created by 예슬 on 11/25/25.
//

import UIKit

class ProfileEditViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        navigationItem.title = "프로필 수정"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}
