//
//  MainViewController.swift
//  Feature
//
//  Created by 예슬 on 8/18/25.
//

import UIKit
import FirebaseFirestore

public class MainViewController: UIViewController {
  let db = Firestore.firestore()

    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "MainView"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        Task {
            await addData()
            await readData()
        }
    }

    func setupView() {
        view.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func addData() async {
        // Add a new document with a generated ID
        do {
          let ref = try await db.collection("users").addDocument(data: [
            "first": "Ada",
            "last": "Lovelace",
            "born": 1815
          ])
          print("Document added with ID: \(ref.documentID)")
        } catch {
          print("Error adding document: \(error)")
        }
    }
    
    func readData() async {
        do {
          let snapshot = try await db.collection("users").getDocuments()
          for document in snapshot.documents {
            print("\(document.documentID) => \(document.data())")
          }
        } catch {
          print("Error getting documents: \(error)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

#Preview {
    MainViewController()
}
