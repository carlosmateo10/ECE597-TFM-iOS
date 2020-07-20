//
//  ReportsViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 14/07/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import Charts
import Firebase

class ReportsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate {
    
    @IBAction func dateText(_ sender: Any) {
    }
    
    var db:Firestore! = Firestore.firestore()
    var userID:String = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var chartsView: UIView!
    
    @IBOutlet weak var area: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var report: UITextField!
    
    var areas = [String]()
    var areaPickerView = UIPickerView()
    
    var reportTypes = ["Cameras", "Time", "People-Cameras", "People-Time", "Map"]
    var reportPickerView = UIPickerView()
    
    let datePicker = UIDatePicker()
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    
    var chart1 = BarChartView()
    var chart2 = BarChartView()
    var bubbleChart = BubbleChartView()
    
    @IBAction func reloadReport(_ sender: Any) {
        var reportN = 1
        if(reportTypes.firstIndex(of: report.text!)! as Int == 0) {
            reportN = 1
        } else if(reportTypes.firstIndex(of: report.text!)! as Int == 1) {
            reportN = 2
        } else if(reportTypes.firstIndex(of: report.text!)! as Int == 4) {
            reportN = 1
        } else {
            reportN = 3
        }
        if(area.text == "ALL") {
            db.collection("data/reports/"+date.text!).document("report\(reportN)").getDocument { (document, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else {
                    if(self.reportTypes.firstIndex(of: self.report.text!)! as Int == 4){
                        self.report3(document: document!)
                    } else {
                        self.report1(document: document!)
                    }
                }
            }
        } else {
            db.collection("data/reports/area/"+area.text!+"/"+date.text!).document("report\(reportN)").getDocument { (document, err) in
                if let err = err {
                        print("Error getting document: \(err)")
                    } else {
                        if(self.reportTypes.firstIndex(of: self.report.text!)! as Int == 4){
                            self.report3(document: document!)
                        } else {
                            self.report1(document: document!)
                        }
                    }
                }
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        area.text = "ALL"
        report.text = "Cameras"
        chart1.delegate = self

        db.collection("users/"+userID+"/blueprints/").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.areas.append("ALL")
                for document in querySnapshot!.documents {
                    print("Blueprint \(document.documentID)")
                    self.areas.append(document.documentID)
                }
            }
        }
        
        areaPickerView.delegate = self
        areaPickerView.dataSource = self
        
        area.inputView = areaPickerView
        
        reportPickerView.delegate = self
        reportPickerView.dataSource = self
        
        report.inputView = reportPickerView
        
        showDatePicker()
        
        dateFormatter.dateFormat = "M-d-yyyy"
        
        date.text = dateFormatter.string(from: currentDate)
        


    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == areaPickerView) {
            return areas.count
        }
        if (pickerView == reportPickerView) {
            return reportTypes.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == areaPickerView) {
            return areas[row]
        }
        if (pickerView == reportPickerView) {
            return reportTypes[row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == areaPickerView) {
            area.text = areas[row]
            area.resignFirstResponder()
        }
        if (pickerView == reportPickerView) {
            report.text = reportTypes[row]
            report.resignFirstResponder()
        }
        
    }
    
    func showDatePicker() {
    //Formate Date
      datePicker.datePickerMode = .date
    
    //ToolBar
      let toolbar = UIToolbar();
      toolbar.sizeToFit()
      let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
      let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
      let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

    toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

     date.inputAccessoryView = toolbar
     date.inputView = datePicker

    }

     @objc func donedatePicker(){

      let formatter = DateFormatter()
      formatter.dateFormat = "M-d-yyyy"
      date.text = formatter.string(from: datePicker.date)
      self.view.endEditing(true)
    }

    @objc func cancelDatePicker(){
       self.view.endEditing(true)
    }
    
    func report1(document: DocumentSnapshot) {
        chart1.frame = CGRect(x:0, y:0, width: self.chartsView.frame.size.width, height: self.chartsView.frame.height/2)
        chart1.center = CGPoint(x: chartsView.center.x, y: 100)
        
        chartsView.addSubview(chart1)
        
        let set = BarChartDataSet()
        
        if let documentData = document.data() {
            for (x, y) in documentData {
                set.append(BarChartDataEntry(x: (x as NSString).doubleValue, y: y as! Double))
            }
        }
        
        set.colors = ChartColorTemplates.joyful()
        
        let data = BarChartData(dataSet: set)
        
        chart1.fitBars = true
        chart1.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart1.leftAxis.axisMinimum = 0
        chart1.rightAxis.axisMinimum = 0
        chart1.legend.enabled = false
        
        chart1.data = data

        chart2.removeFromSuperview()
        bubbleChart.removeFromSuperview()
    }
    
    func report2(document: DocumentSnapshot, id: String) {
        print("ID: \(id)")
        
        let set = BarChartDataSet()
        
        if let documentData = document.data()![id] as? [String: Any]{
            for (x, y) in documentData {
                set.append(BarChartDataEntry(x: (x as NSString).doubleValue, y: y as! Double))
            }
        }
        
        set.colors = ChartColorTemplates.joyful()
        
        let data = BarChartData(dataSet: set)
        
        chart2.frame = CGRect(x:0, y:0, width: self.chartsView.frame.size.width, height: self.chartsView.frame.height/2)
        chart2.center = CGPoint(x: chartsView.center.x, y: 120+self.chartsView.frame.height/2)
        
        chartsView.addSubview(chart2)
        
        
        chart2.fitBars = true
        chart2.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chart2.leftAxis.axisMinimum = 0
        chart2.rightAxis.axisMinimum = 0
        chart2.legend.enabled = false

        chart2.data = data
    }
    
    func report3(document: DocumentSnapshot) {
        chart1.removeFromSuperview()
        chart2.removeFromSuperview()
        
        

        if(area.text != "ALL") {
            if let documentData = document.data() {
                db.collection("users/"+userID+"/blueprints/").document(area.text!).getDocument { (blueprint, err) in
                    if let err = err {
                        print("Error getting document: \(err)")
                    } else {
                        if let blueprintData = blueprint!.data() {
                            let cameras = blueprintData["cameras"] as! [String: Any]
                                                        
                            var vals:[BubbleChartDataEntry] = []

                            for (x, y) in documentData {
                                let coordinates = (cameras[x] as! String).split(separator: "-")
                                print("Camera \(x) at x:\(coordinates[0]) y:\(coordinates[1]), with \(y) detections")
                                
                                vals.append(BubbleChartDataEntry(x: (coordinates[0] as NSString).doubleValue/300, y: 1/(coordinates[1] as NSString).doubleValue+10, size: y as! CGFloat, icon: UIImage(named: "icon")))
                            }
                            vals.sort(by: { $0.x < $1.x})
                            
                            let set1 = BubbleChartDataSet(entries: vals, label: "Detections")
                            set1.drawIconsEnabled = true
                            set1.setColor(ChartColorTemplates.colorful()[0], alpha: 0.5)
                            set1.drawValuesEnabled = true
                            set1.valueFormatter = DefaultValueFormatter(decimals: 0)
                            
                            let data = BubbleChartData(dataSets: [set1])
                            data.setDrawValues(true)
                            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 15)!)
                            data.setHighlightCircleWidth(1.5)
                            data.setValueTextColor(.black)
                            
                            self.bubbleChart.data = data
                            self.bubbleChart.doubleTapToZoomEnabled = false
                            self.bubbleChart.pinchZoomEnabled = false
                            self.bubbleChart.xAxis.enabled = false
                            self.bubbleChart.leftAxis.enabled = true
                            self.bubbleChart.rightAxis.enabled = true
                            self.bubbleChart.leftAxis.axisLineColor = .init(white: 1, alpha: 1)
                            self.bubbleChart.leftAxis.labelTextColor = .init(white: 1, alpha: 1)
                            self.bubbleChart.rightAxis.axisLineColor = .init(white: 1, alpha: 1)
                            self.bubbleChart.rightAxis.labelTextColor = .init(white: 1, alpha: 1)
                            
                            
                            self.bubbleChart.frame = CGRect(x:0, y:0, width: self.chartsView.frame.size.width, height: 4*self.chartsView.frame.height/5)
                            self.bubbleChart.center = CGPoint(x: self.chartsView.center.x, y: 200)
                        }
                    }
                }
            }
        }
                        
        let blueprintImage = UIImageView()
        blueprintImage.frame = CGRect(x:0, y:0, width: self.chartsView.frame.size.width+20, height: 4*self.chartsView.frame.height/5)
        blueprintImage.center = CGPoint(x: chartsView.center.x, y: 200)
        
        let storageRef = Storage.storage().reference()
                    
        let path = userID+"/"+area.text!

        let photoRef = storageRef.child(path)
            
        blueprintImage.sd_setImage(with: photoRef)
        
        chartsView.addSubview(blueprintImage)
        chartsView.addSubview(bubbleChart)
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if(reportTypes.firstIndex(of: report.text!)! as Int != 1) {
            var reportN = 4
            if(reportTypes.firstIndex(of: report.text!)! as Int == 2) {
                reportN = 5
            } else if(reportTypes.firstIndex(of: report.text!)! as Int == 3) {
                reportN = 6
            }
            if(area.text == "ALL"){
                db.collection("data/reports/"+date.text!).document("report\(reportN)").getDocument { (document, err) in
                    if let err = err {
                        print("Error getting document: \(err)")
                    } else {
                        self.report2(document: document!, id: "\(Int(entry.x))")
                    }
                }
            } else {
                db.collection("data/reports/area/"+area.text!+"/"+date.text!).document("report\(reportN)").getDocument { (document, err) in
                    if let err = err {
                        print("Error getting document: \(err)")
                    } else {
                        self.report2(document: document!, id: "\(Int(entry.x))")
                    }
                }
            }
        }
    }
    
    func createBubble(x: Int, y: Int, size: Int) -> BubbleChartDataEntry {
        let val = Double(y)
        let size = CGFloat(size)
        return BubbleChartDataEntry(x: Double(x), y: val, size: size, icon: UIImage(named: "icon"))
    }
    
}
