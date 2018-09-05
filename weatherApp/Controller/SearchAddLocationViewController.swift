//
//  SearchAddLocationViewController.swift
//  weatherApp
//
//  Created by PS Shortcut on 22/08/2018.
//  Copyright © 2018 PS Shortcut. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import CoreData

class SearchAddLocationViewController: UIViewController {

    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    var locations : [Location] = []
    var coreDataStack : CoreDataStack!
    
    //MARK: - SpeechRecognizer Properties
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask : SFSpeechRecognitionTask?
    
    //MARK: - NSLinguisticTagger
    
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType,.language,.nameType,.lemma], options: 0)
    let option : NSLinguisticTagger.Options = [.omitPunctuation,.omitWhitespace,.joinNames]
    
    private var recognizedLocation : String = ""
    private var speakButtonPressed = false
    
    let synthesizer = AVSpeechSynthesizer()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.setShowsCancelButton(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Speak", style: .done, target: self, action: #selector(recordAndRecognizeSpeech))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = .darkGray
        
        requestSpeechAuthorization()
        
        
        synthesizer.delegate = self
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSearchBar()
    }
    
    
    
    /// it setup the searchBar
    fileprivate func setupSearchBar() {
        searchBar.becomeFirstResponder()
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        tableView.backgroundColor = UIColor.clear
    }
    
    ///Searches the ViewContext and return true if the location exists or false if it doesn't exist
    private func searchForExistingLocation(at indexPathRow : Int) -> Bool{
        let locationSelected = locations[indexPathRow]
        let fetchRequest = coreDataStack.setupFetchRequest(objectName: "LocationCurrentWeatherObject", sortingKey: "locationID", ascending: true, predicate: "locationID == %i", arg: locationSelected.locationID )
        var results : [Any]!
        do{
            results = try coreDataStack.viewContext.fetch(fetchRequest)
            results = results as! [LocationCurrentWeatherObject]
            
        }catch{
            print("Error fetch TableViewDidSelectRow: \(error) msg: \(error.localizedDescription)")
        }
        
        if results.count != 0 {
            return true
        }else{
            return false
        }
        
    }

    private func saveLocationToCoreData(locationSelected : Location){
        ApixuClient.shared.getCurrentWeatherAndForecast(parameterQ: locationSelected.name, locationID: locationSelected.locationID, days: 1) { (success, errorString) in
            if success{
                print("Success")
            }else{
                print("Error SaveLocationToCoreData : \(errorString!)")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - UISearchBarDelegate

extension SearchAddLocationViewController : UISearchBarDelegate{
    
    // Cancel Button Pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("Started")
    }
    
    
    
    
    //MARK: - SearchBar
    /// Returns a string when text Change in SearchBar and call the getSearchLocations to return the possible locations
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(searchText)
        if searchText == "" {
            return
        }
        ApixuClient.shared.getSearchLocations(parameterQ: searchText) { (success, results, errorString) in
            
            if let results = results{
                self.locations = results
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }else{
                print("Error Search Bar: \(String(describing: errorString)) ")
                DispatchQueue.main.async {
                    self.showAlert(title: ErrorTitles.NetworkError, msg: errorString!)
                }
                
            }
            
        }
    }
    
    
}

//MARK: - UITableViewDataSource
extension SearchAddLocationViewController : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationNameCell", for: indexPath)
        
        cell.textLabel?.text = locations[indexPath.row].name
        
        return cell
        
    }
}

//MARK: - UITableViewDelegate
extension SearchAddLocationViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let locationSelected = locations[indexPath.row]
        
        if searchForExistingLocation(at: indexPath.row){
            print("Location Exists")
            navigationController?.popViewController(animated: true)
        }else{
            
            print("Tapped")
            saveLocationToCoreData(locationSelected: locationSelected)
        }
        
    }
    
    
    
    
    
}

//MARK: - RecordAndRecognize Functions
extension SearchAddLocationViewController {
    
    fileprivate func setupNodeAudioEngine() {
        let node = audioEngine.inputNode
        let recognitionFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recognitionFormat) { (buffer, time) in
            self.request.append(buffer)
        }
    }
    
    fileprivate func startAudioEngine() {
        audioEngine.prepare()
        do{
            try audioEngine.start()
        }catch{
            print("Error Start AudioEngine : \(error)")
            return
        }
        
    }
    
    @objc private func recordAndRecognizeSpeech(){
        
        speakButtonPressed = true
        navigationButtonTitle()

        setupNodeAudioEngine()
        
        startAudioEngine()
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            //present alertController not supported for the current locale
            return
        }
        
        if !myRecognizer.isAvailable{
            //present alertController not available right now
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if result != nil {
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                print(bestString)
                
                if self.recognizedLocation == ""{
                    self.locationEntityRecognition(for: bestString)
                }else{
                    var lastString : String = ""
                    for segment in result.bestTranscription.segments{
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = String(bestString[indexTo...])
                        print(lastString)
                        self.checkUserAnswer(answer: lastString)
                    }
                }
            }else if let error = error{
                print("Error speechRecognizer : \(error) MSG: \(error.localizedDescription)")
            }
                print("Result != nil")
            }
        })
    }
    
    private func pauseAudioEngine(){
        self.audioEngine.pause()
        self.recognitionTask?.finish()
    }
    
    @objc private func stopRecording(){
        speakButtonPressed = false
        navigationButtonTitle()
        
        if self.audioEngine.isRunning{
            self.request.endAudio()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            //self.audioEngine.inputNode.reset()
            //self.audioEngine.stop()
            self.recognitionTask?.cancel()
            
        }
        
    }
    
    
    private func speakOut(text : String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en_US")
        utterance.rate = 0.51
        
        synthesizer.speak(utterance)
        
    }
    
    private func locationEntityRecognition(for text : String){
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags : [NSLinguisticTag] = [.placeName]
            
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: option) { (tag, tokenRange, stop) in
            if let tag = tag , tags.contains(tag){
                let name = (text as NSString).substring(with: tokenRange)
                print(name)
                
            
                ApixuClient.shared.getSearchLocations(parameterQ: name, completionHandlerForGetSearchLocations: { (success, results, errorString) in
                    
                    if success {
                        if let results = results{
                            self.locations = results
                            //self.stopRecording()
                            //self.audioEngine.stop()
                            self.pauseAudioEngine()
                            self.recognizedLocation = self.locations[0].name!
                            self.speakOut(text: "Do you mean : \(self.locations[0].name!). Yes or No?")
                            DispatchQueue.main.async {
                                //Stop Recording
                                
                                self.tableView.reloadData()
                                
                                //start recording
                                //self.recordAndRecognizeSpeech()
                                
                            }
                            
                            
                        }
                        
                    }
                })
            }
        }
        
    }
    
    fileprivate func checkUserAnswer(answer : String){
        switch answer{
        case "Yes","yes":
            print("User said YES")
            if self.searchForExistingLocation(at: 0){
                self.stopRecording()
                navigationController?.popViewController(animated: true)
            }else{
                self.stopRecording()
                let selectedLocation = self.locations[0]
                saveLocationToCoreData(locationSelected: selectedLocation)
            }
        case "No","no":
            print("User said NO")
            //stop AudioEngine
            self.stopRecording()
            //Recognize Location = ""
            self.recognizedLocation = ""
            //tableView.empty
            self.locations = []
            //self.locations = []
            self.tableView.reloadData()
            self.recordAndRecognizeSpeech()
        default:
            print("Entered Default")
            break
            
        }
    }
    
    fileprivate func navigationButtonTitle() {
        if speakButtonPressed == false{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Speak", style: .done, target: self, action: #selector(recordAndRecognizeSpeech))
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .done, target: self, action: #selector(stopRecording))
        }
    }
    
    private func requestSpeechAuthorization(){
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.navigationItem.rightBarButtonItem?.tintColor = .orange
                case .denied:
                    self.showAlert(title: "The App doesn't have access to your Microphone", msg: "To enable Speech feature, please enable speech")
                case .restricted:
                    self.showAlert(title: "The App doesn't have access to your Microphone", msg: "To enable Speech feature, please enable speech")
                case .notDetermined:
                    self.showAlert(title: "The App doesn't have access to your Microphone", msg: "To enable Speech feature, please enable speech")
                }
            }
        }
    }
}

extension SearchAddLocationViewController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            //The speech Recognition is available in this locale Do nothing
        }else{
            //TODO: - Speech recognition is not available in this Location (Locale).Ask in English
        }
    }
}

extension SearchAddLocationViewController: AVSpeechSynthesizerDelegate{
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Start Recording again")
        do{
            try self.audioEngine.start()
        }catch{
            print("Error  : \(error)")
        }
    }
}


