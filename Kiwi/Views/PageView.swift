//
//  PageView.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 13.12.2022.
//

import SwiftUI


struct PageView: View {
    var flight: CDFlight
    private var flightImage = UIImage()
    private var destination: String {
        "\(flight.cityTo), \(flight.countryTo)"
    }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    init(flight: CDFlight){
        self.flight = flight
        if let data = flight.image, let image = UIImage(data: data) {
            flightImage = image
        } else if let placeholder = UIImage(named: "placeholder") {
            flightImage = placeholder
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: flightImage)
                .resizable()
                .aspectRatio(1/1, contentMode: .fit)
            
            HStack {
                Text("Destination:")
                    .fontWeight(.bold)
                Text(destination)
            }
            .alignmentGuide(.leading) { _ in -10 }
            
            HStack {
                Text("Departure date:")
                    .fontWeight(.bold)
                Text(flight.dTime, formatter: dateFormatter)
            }
            .alignmentGuide(.leading) { _ in -10 }
            
            HStack {
                Text("Dsitance, km:")
                    .fontWeight(.bold)
                Text(String(format: "%.0f", flight.distance))
            }
            .alignmentGuide(.leading) { _ in -10 }
            
            HStack {
                Text("Price, EUR:")
                    .fontWeight(.bold)
                Text(String(flight.price))
            }
            .alignmentGuide(.leading) { _ in -10 }
        }
        
    }
        
}

