//
//  ContentView.swift
//  Shared
//
//  Created by may on 11/6/21.
//


import SwiftUI
import CoreML

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeUpTime
    
     static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

    
    
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 2){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                       
                }
                
               
                
                
                VStack(alignment: .leading, spacing: 2){
                    Text("Desired Amount of Sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 0...15, step: 0.25)
    
                }
                
                
                VStack(alignment: .leading, spacing: 2){
                    Text("Daily Coffee Intake")
                        .font(.headline)
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
                
                
                
            }
            
            .navigationTitle("Better Rest")
            .toolbar{
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showAlert){
                Button("Close"){}
            } message: {
                Text(alertMessage)
            }
        }
    } //eof body
    
    func calculateBedTime(){
        do{
            //initialization for the coreML
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            
            let wakeUp_component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            //convert to seconds
            let hour = (wakeUp_component.hour ?? 0 ) * 60 * 60
            let minute = (wakeUp_component.minute ?? 0) * 60
            
            
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is"
            alertMessage =  sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            //for errors in calculation
            alertTitle = "Error"
            alertMessage = "There was a problem in the algorithm"
        }
        
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
