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

class SearchAddLocationViewController: UIViewController{

    //MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    var locations : [Location] = []
    var coreDataStack : CoreDataStack!
    
    //MARK: - SpeechRecognizer Properties
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer : SFSpeechRecognizer? = SFSpeechRecognizer()
    //private let speechRecognizer = SFSpeechRecognizer()
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
        
        setupNavigationBar()
        requestSpeechAuthorization()
        synthesizer.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupSearchBar()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopRecording()
    }
    
    
    //MARK: - Fucntions
    
    private func setupNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Speak", style: .done, target: self, action: #selector(recordEnabled))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.tintColor = .darkGray
    }
    
    /// it setup the searchBar
    fileprivate func setupSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundColor = UIColor.clear
        searchBar.isTranslucent = true
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

    /// Takes a Location as parameter and makes a call getCurrentWeatherAndForecast and saves the results from the API to Core Data
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
                    self.showAlert(title: Errors.ErrorTitles.NetworkError, msg: errorString!)
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
    
    /// Starts the AudioEngine
    fileprivate func startAudioEngine() {
        audioEngine.prepare()
        do{
            try audioEngine.start()
            print("AudioEngine Starts")
        }catch{
            print("Error Start AudioEngine : \(error)")
            return
        }
        
    }
    
    /// Setup a AudioSession.sharedInstance()
    fileprivate func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryRecord, with: .duckOthers)// or optionMixWithOthers
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        }catch{
            print("error Audio session Properties weren't set because of an error")
        }
    }
    
    /// Enables the recording, records and brings the top result of a location that is
    /// speeched recognized.
    @objc private func recordEnabled(){
        speakOut(text: "Recording")
    }
    
    private func recordAndRecognizeSpeech(){

        
        speakButtonPressed = true
        navigationButtonTitle()

        setupNodeAudioEngine()
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        setupAudioSession()
        
        startAudioEngine()
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.showAlert(title: Errors.ErrorTitles.SpeechError, msg: Errors.ErrorMessages.SpeechRecognitionErrorLocale)
            return
        }
        
        if !myRecognizer.isAvailable{
            self.showAlert(title: Errors.ErrorTitles.SpeechError, msg: Errors.ErrorMessages.SpeechRecognizerErrorNotAvailable)
            return
        }
        myRecognizer.delegate = self
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            
            if result != nil {
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                print(bestString)
                
                if self.recognizedLocation == ""{
                    self.recognizedLocation = self.locationEntityRecognition(for: bestString)
                    
                    if self.recognizedLocation != ""{
                    ApixuClient.shared.getSearchLocations(parameterQ: self.recognizedLocation, completionHandlerForGetSearchLocations: { (success, results, errorString) in
                        if success{
                            if let results = results {
                                self.locations = results
                                self.stopRecording()
                                self.speakOut(text: "Do you mean \(self.locations[0].name!). Yes or No")
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    })
                    }
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
    
        
    /// Stops the recording
    @objc func stopRecording(){
        
        speakButtonPressed = false
        navigationButtonTitle()
        
        if self.audioEngine.isRunning{
            self.request.endAudio()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.recognitionTask?.cancel()
            
        }
        
    }
    
    
    ///Speak out the text that gets as input
    private func speakOut(text : String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en_US")
        utterance.rate = 0.51
        synthesizer.speak(utterance)
    }
    
    /// returns "" if no results have found (.placeName) otherwise return the placeName that has found
    private func locationEntityRecognition(for text : String) -> String{
        var locationIdentified : String = ""
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags : [NSLinguisticTag] = [.placeName]
            
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: option) { (tag, tokenRange, stop) in
            if let tag = tag , tags.contains(tag){
                let name = (text as NSString).substring(with: tokenRange)
                print(name)
                locationIdentified = name
            }
        }
        print(locationIdentified)
        return locationIdentified
        
    }
    
    /// Checks the answer of the user if it is Yes/No
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
            self.recognizedLocation = ""
            self.locations = []
            self.tableView.reloadData()
        default:
            print("Entered Default")
            break
            
        }
    }
    
    /// Changes the navigation title related to Recording or StopRecording
    fileprivate func navigationButtonTitle() {
        if speakButtonPressed == false{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Speak", style: .done, target: self, action: #selector(recordEnabled))
            NotificationCenter.default.removeObserver(Notification.Name.appDidEnterBackground)
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .done, target: self, action: #selector(stopRecording))
            NotificationCenter.default.addObserver(self, selector: #selector(stopRecording), name: Notification.Name.appDidEnterBackground, object: nil)
            
        }
    }
    
    /// Checks the authorization Status for the access in the microphone
    private func requestSpeechAuthorization(){
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.navigationItem.rightBarButtonItem?.tintColor = .orange
                case .denied:
                    self.showAlert(title: "The App doesn't have access to your Microphone", msg: "To enable Speech feature, please enable Microphone")
                case .restricted:
                    self.showAlert(title: "The App doesn't have access to your Microphone", msg: "To enable Speech feature, please enable Microphone")
                case .notDetermined:
                    self.showAlert(title: "The App doesn't have access to your Microphone", msg: "To enable Speech feature, please enable Microphone")
                }
            }
        }
    }
}


extension SearchAddLocationViewController: AVSpeechSynthesizerDelegate{
    // When the speakOut() stops the the recording will start again didFinish utterance
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("Start Recording again")
        self.recordAndRecognizeSpeech()
    }
}

extension SearchAddLocationViewController : SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            print("Is available")
        }else{
            print("Not available")
        }
    }
}


