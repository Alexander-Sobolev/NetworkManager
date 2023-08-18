//
//  ContentView.swift
//  NetworkManager
//
//  Created by Alexander Sobolev on 18.8.23..
//

import SwiftUI

import SwiftUI

class SomeViewModel: ObservableObject {
    @Published var date: String? = ""
    @Published var seconds: Int? = 0
    @Published var time: String? = ""
    
    func getData() {
        Task {
            do {
                let responsedData = try await SomeModuleApi.getSomeImportantData()
                DispatchQueue.main.async {
                    self.date = responsedData?.date
                    self.seconds = responsedData?.milliseconds_since_epoch
                    self.time = responsedData?.time
                }
            } catch {
                validateError(error: error)
            }
        }
    }
}


extension SomeViewModel {
    func validateError(error: Error) {
        if let error = error.asCommonError {
            // Весь нижний код должен находиться в отдельном методе потом доделать
            switch error {
            case .unauthenticated:
                break
            case .conflict:
                break
                // custom error from backend
            case .validationException(let error):
                print(error.message)
                    // Варианты обработки
//                        let errorKeys = error.errors.keys
//                        for key in errorKeys {
//                            let foundedField = fields.first(where: {$0.entityName == key})
//                            if let errorMessage = error.errors[key]?.last {
//                                foundedField?.showEmptyFieldError(error: errorMessage)
//                            }
//                        }
            }
        }
    }
}

struct ContentView: View {
    @StateObject var vm = SomeViewModel()
    
    var body: some View {
        VStack {
            Text(vm.date ?? "")
            Text("\(vm.seconds ?? 0)")
            Text(vm.time ?? "")
            Button(action: {
                vm.getData()
            }, label: {
                Text("Make req")
            })
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
