//
//  ContentView.swift
//  BetterRest
//
//  Created by Ping Yun on 9/27/20.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime //stores when user wants to wake up, defaults to 7 AM
    @State private var sleepAmount = 8.0 //stores how much sleep user likes
    @State private var coffeeAmount = 1 //stores how many coffees user drinks
    @State private var alertTitle = "" //stores title of alert
    @State private var alertMessage = "" //stores alert's message
    @State private var showingAlert = false //stores whether or not alert is showing
    
    var body: some View {
        NavigationView{
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    //picker for time user wants to wake up
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute) //picker only shows hour and minute
                        .labelsHidden() //no second label for picker
                        .datePickerStyle(WheelDatePickerStyle()) //makes DatePicker wheel picker
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    //stepper for sleep amount with range of 4-12 and step of 0.25
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours") //%g gets rid of trailing zeroes
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    //Stepper for # of coffees with range of 1-20
                    Stepper(value: $coffeeAmount, in: 1...20) {
                        if coffeeAmount == 1 {
                            Text("1 cup") //if coffeeAmount is 1 shows "cup" singular
                        } else {
                            Text("\(coffeeAmount) cups") //if coffeeAmount>1 shows "cups" plural
                        }
                    }
                }
            }
            
            .navigationBarTitle("BetterRest")
            //runs calculateBedtime when button is pressed
            .navigationBarItems(trailing:
                Button(action: calculateBedtime) {
                    Text("Calculate")
                }
            )
            
            //alert() modifier that shows when showingAlert is true
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    //static variable that contains Date() referencing 7 AM of current day
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    //calculates best time user should go to sleep
    func calculateBedtime() {
        let model = SleepCalculator() //creates instance of SleepCalculator class
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp) //requests hour and minute components from wakeUp Date
        let hour = (components.hour ?? 0) * 60 * 60 //calculates seconds from hour component
        let minute = (components.minute ?? 0) * 60 //calculates seconds from minute component
        
        //if core ML hits some sort of problem this might fail -> needs do/catch block
        do {
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount)) //sends hour+minute, sleepAmount, coffeeAmount as Double values to prediction() method
            let sleepTime = wakeUp - prediction.actualSleep //converts sleep needed found by core ML to time to go to bed by subtracting it from wakeUp time
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime) //formats sleepTime Date into a time string
            alertTitle = "Your ideal bedtime is..."
        } catch {
            //if reading a prediction throws in error, alert will contain error messgae
            alertTitle = "Error"
            alertMessage = "There was a problem calculating your bedtime."
        }
        showingAlert = true //shows alert
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11")
    }
}
