# WeatherApp

This is the final project for udacity iOS Nanodegree

Weather app is an application for iPhone devices.
It allow you to predict the weather for today and the following 6 days.
Total 7 days

 - 7 days weather prediction
 - Store locations for fast access to locations
 - Show the maximum and minimum temperature of 7 days

# New Features!
 - You can search your location using your voice. Using SpeechRecognition and NLP the app can recognize a location that has been said to the app.


## Description
WeatherApp is using a get method to get information from a API. WeatherApp uses Apixu API to get all the information needed.

**Technologies**

 - UIKit
 - Core Data
 - Speech
 - AVFoundation
 - SpeechRecognition
 - Natural Language Proccess

**Structure**

It has 3 different view controllers:

- LocationsStoredViewController
- SearchAddLocationsViewController
- WeatherForecastViewController


##### LocationStoredViewController

LocationsStoredViewController has a tableView that has all the stored locations that the user has choose. The locations are saved on Core Data Framework on ViewContext. The user has the ability to Delete a location and automaticaly remove it from Core Data

##### SearchAddLocationsViewController

SearchAddLocationsViewController has a search bar that the user can write the location he want to find out the weather report. By typing the name of the location a tableView is updated from a Autocomplete function of Apixu API and populate the results, always in context with the input.

By clicking the location/the, row at the tableView the location checks if the location exist in Core Data (checking a locationID ) and if not,it stores the location in Core Data.

On SearchAddLocationsViewController the user can search for the location using the voice. On the NavigationBar there is a button with title Speak, that enables the microphone and allow the user to use his voice to search for the location. When a location has found the App speaks and asks if the specific location is the one that the user is looking for. By saying YES it saves the location and by saying NO it allow the user to search again using his voice.

##### WeatherForecastViewController

WeatherForecastViewController has a View for showing the day's forecast and a tableView showing the 6 days forecast.

It shows the day , the icon, the maximum and minimum temperature.

#### Authors

grNorway
 - https://github.com/grNorway



 
