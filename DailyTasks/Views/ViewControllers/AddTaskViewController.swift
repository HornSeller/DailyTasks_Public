//
//  AddTaskViewController.swift
//  DailyTasks
//
//  Created by Mac on 11/04/2024.
//

import UIKit
import Firebase

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var priorityTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!
    
    private let pickerView1 = UIPickerView()
    private let pickerView2 = UIPickerView()
    private let categories = ["None", "Work", "Personal", "Family"]
    private let priorities = ["Low", "Medium", "High"]
    private let addTaskViewModel = AddTaskViewModel()
    private let dateFormatter = DateFormatter()
    private let userUid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.layer.cornerRadius = 20
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:ss"
        
        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView2.delegate = self
        pickerView2.dataSource = self
        
        categoryTextField.inputView = pickerView1
        priorityTextField.inputView = pickerView2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTfButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        categoryTextField.inputAccessoryView = toolbar
        priorityTextField.inputAccessoryView = toolbar
        
        startTimeDatePicker.date = .now
        endTimeDatePicker.date = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
        
        startTimeDatePicker.maximumDate = endTimeDatePicker.date
        endTimeDatePicker.minimumDate = startTimeDatePicker.date
        
        startTimeDatePicker.addTarget(self, action: #selector(startTimeDatePickerValueChanged), for: .valueChanged)
        endTimeDatePicker.addTarget(self, action: #selector(endTimeDatePickerValueChanged), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        NotificationCenter.default.post(name: Notification.Name("TaskDidAdd"), object: nil)
    }
    
    @IBAction func addTaskButtonTouchUpInside() {
        if nameTextField.text!.isEmpty ||
           categoryTextField.text!.isEmpty ||
           priorityTextField.text!.isEmpty {
            let alert = UIAlertController(title: "Textfield must not empty", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        addTaskViewModel.title = nameTextField.text ?? ""
        addTaskViewModel.category = categoryTextField.text ?? ""
        addTaskViewModel.priority = priorityTextField.text ?? ""
        addTaskViewModel.startTime = dateFormatter.string(from: startTimeDatePicker.date)
        addTaskViewModel.endTime = dateFormatter.string(from: endTimeDatePicker.date)
        addTaskViewModel.description = descriptionTextView.text
        
        addTaskViewModel.createTask(uid: userUid!)
    }
    
    @objc func startTimeDatePickerValueChanged() {
        let selectedDate = startTimeDatePicker.date
        endTimeDatePicker.minimumDate = selectedDate
    }
    
    @objc func endTimeDatePickerValueChanged() {
        let selectedDate = endTimeDatePicker.date
        startTimeDatePicker.maximumDate = selectedDate
    }
    
    @objc func doneTfButtonTapped() {
        categoryTextField.resignFirstResponder()
        priorityTextField.resignFirstResponder()
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        categoryTextField.resignFirstResponder()
        priorityTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    static func makeSelf() -> AddTaskViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let rootViewController = storyboard.instantiateViewController(identifier: "AddTaskViewController") as AddTaskViewController
        
        return rootViewController
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension AddTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerView1 {
            return categories.count
        } else {
            return priorities.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerView1 {
            return categories[row]
        } else {
            return priorities[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerView1 {
            categoryTextField.text = categories[row]
        } else {
            priorityTextField.text = priorities[row]
        }
    }
}
