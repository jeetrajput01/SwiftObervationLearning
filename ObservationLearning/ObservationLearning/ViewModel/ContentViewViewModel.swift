//
//  ContentViewVM.swift
//  Observation Framework
//
//  Created by differenz53 on 08/07/24.
//

import Foundation
import Combine
import CoreData

@Observable
class ContentViewViewModel {
    
    var arrBrandData:[brandModel] = []
    var arrUserModel:[userModel] = []
    var arrTodoModel:[toDoModel] = []
    
    @MainActor
    var isShowLoader:Bool = false
    
    var errorMessage:String = ""
    
    @ObservationIgnored
    private var cancellable = Set<AnyCancellable>()
    
    @ObservationIgnored
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = DataController.shared.context) {
        self.context = context
    }
    
}

//MARK: - Combine
extension ContentViewViewModel {
    
    @MainActor
    func getBrandDataWithCombine() {
 
        Task {
            APIManager.makeRequest(url: apiUrl.brand.route, method: .get, parameter: nil, type: [brandModel].self)
                .sink { error in
                    
                    switch error {
                        
                    case .finished:
                        print("API call successful")
                    case .failure(let responseError):
                        
                        if let networkError = responseError as? NetworkError {
                            switch networkError {
                            case .invalidURL:
                                print(networkError.localizedDescription)
                            case .responseError:
                                print(networkError.localizedDescription)
                            case .unknown:
                                print(networkError.localizedDescription)
                            case .authentication:
                                print(networkError.localizedDescription)
                            }
                        }
                        
                    }
                    
                } receiveValue: { data in
                    self.arrBrandData = data
                    dump(self.arrBrandData)
                }
                .store(in: &self.cancellable)
        }

    }
    
    @MainActor
    func getUserListWithCombine() {
        Task {
            APIManager.makeRequest(url: apiUrl.user.route, method: .get, parameter: nil, type: [userModel].self)
                .sink { error in
                    
                    switch error {
                        
                    case .finished:
                        print("API call successful")
                    case .failure(let responseError):
                        
                        if let networkError = responseError as? NetworkError {
                            switch networkError {
                            case .invalidURL:
                                print(networkError.localizedDescription)
                            case .responseError:
                                print(networkError.localizedDescription)
                            case .unknown:
                                print(networkError.localizedDescription)
                            case .authentication:
                                print(networkError.localizedDescription)
                            }
                        }
                        
                    }
                    
                } receiveValue: { data in
                    self.arrUserModel = data
                    dump(data)
                }
                .store(in: &self.cancellable)
        }
    }
    
    @MainActor
    func getTodoDataWithCombine() {
        Task {
            APIManager.makeRequest(url: apiUrl.todos.route, method: .get, parameter: nil, type: [toDoModel].self)
                .sink { error in
                    
                    switch error {
                        
                    case .finished:
                        print("API call successful")
                    case .failure(let responseError):
                        
                        if let networkError = responseError as? NetworkError {
                            switch networkError {
                            case .invalidURL:
                                print(networkError.localizedDescription)
                            case .responseError:
                                print(networkError.localizedDescription)
                            case .unknown:
                                print(networkError.localizedDescription)
                            case .authentication:
                                print(networkError.localizedDescription)
                            }
                        }
                        
                    }
                    
                } receiveValue: { data in
                    self.arrTodoModel = data
                    dump(data)
                }
                .store(in: &self.cancellable)
        }
    }
    
    @MainActor
    func getTodoDataWithCombine2() async {
        
        do {
            
            let data = try await APIManager.makeRequest(url: apiUrl.todos.route, method: .get, parameter: nil, type: [toDoModel].self).value
            self.arrTodoModel = data
            print(data)
        } catch {
            self.handle(error: error)
        }
        
    }
    
    @MainActor
    func getUserListWithCombine2() async {
        
        do {
            
            let data = try await APIManager.makeRequest(url: apiUrl.user.route, method: .get, parameter: nil, type: [userModel].self).value
            self.arrUserModel = data
            print(data)
        } catch {
            self.handle(error: error)
        }
        
    }
    
    func getAllDataUsingCombine() {
        
        Task { @MainActor in // to update variable isShowLoader which is attached with @MainActor alternative make this function as @MainActor
            self.isShowLoader = true
            let _ = await getUserListWithCombine2()
            let _ = await getTodoDataWithCombine2()
            self.isShowLoader = false

        }
        
    }
    
}

//MARK: -  new async/await
extension ContentViewViewModel {
    
    @MainActor
    func getAllData() {
        
        let isDataAvailable = UserDefaults.standard.bool(forKey: "isDataAvailable")
        
        if !isDataAvailable {
            Task {
                
                self.isShowLoader = true
                
                defer {
                    self.isShowLoader = false
                    
                    if self.errorMessage == "" {
                       
                        // store data in coreData
                        self.saveAllData()
                    } else {
                        // show error
                        print(self.errorMessage)
                    }
                   
                    
                }
                
                let userUrl = apiUrl.user.route
                let todoUrl = apiUrl.todos.route
                
                let (userData, todoData) = await (
                    APIManager.makeAsyncRequest(url: userUrl, method: .get, parameter: nil, type: [userModel].self),
                    APIManager.makeAsyncRequest(url: todoUrl, method: .get, parameter: nil, type: [toDoModel].self)
                )
                
                switch userData {
                case .success(let userData):
                    self.arrUserModel = userData
                    print(userData)
                case .failure(let failure):
                    self.handle(error: failure)
                }
                
                switch todoData {
                case .success(let todoData):
                    self.arrTodoModel = todoData
                    print(todoData)
                case .failure(let failure):
                    self.handle(error: failure)
                }
                
            }
        } else {
            // get all data
            let entityData = self.getUserData()
            self.arrUserModel = entityData.compactMap({userModel(id: Int($0.id), name: $0.name ?? "", username: $0.username ?? "", email: $0.email ?? "")})
            dump(self.arrUserModel)
        }
        
        
    }
    
    @MainActor
    func getBrandData() {
        
        Task {
            
            self.isShowLoader = true
            
            defer {
                self.isShowLoader = false
            }
    
            let brandResponse = await APIManager.makeAsyncRequest(url: apiUrl.brand.route, method: .get, parameter: nil, type: [brandModel].self)
            
            switch brandResponse {
            case .success(let success):
                self.arrBrandData = success
                dump(self.arrBrandData)
            case .failure(let failure):
                self.handle(error: failure)
            }
        }
        
    }
    
}

//MARK: - CoreData function
extension ContentViewViewModel {
    
    @MainActor
    private func saveAllData() {
        if !self.arrTodoModel.isEmpty && !self.arrUserModel.isEmpty {
            
            do {
                var arrUserData:[UserEntity] = []
                self.arrUserModel.indices.forEach { index in
                    let data = self.arrUserModel[index]
                    let userContext = UserEntity(context: self.context)
                    userContext.id = Int64(data.id)
                    userContext.email = data.email
                    userContext.name = data.name
                    userContext.username = data.username
                    let arrTodo = self.arrTodoModel.filter({$0.userId == data.id})
                    var arrTodoEntity:[TodoEntity] = []
                    arrTodo.indices.forEach { index in
                        let data = arrTodo[index]
                        let todoEntity = TodoEntity(context: self.context)
                        todoEntity.id = Int64(data.id)
                        todoEntity.userId = Int64(data.userId)
                        todoEntity.title = data.title
                        todoEntity.completed = data.completed
                        todoEntity.owner = userContext
                        arrTodoEntity.append(todoEntity)
                    }
                    userContext.todoLists = NSSet(array: arrTodoEntity)
                    arrUserData.append(userContext)
                }
                
                try self.context.save()
                
                UserDefaults.standard.set(true, forKey: "isDataAvailable")

            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func getUserData() -> [UserEntity] {
        do {
            let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let user = try self.context.fetch(fetchRequest)
            return user
            
        } catch {
            print(error.localizedDescription)
            return []
        }
        
    }
    
}

//MARK: - Error handle
extension ContentViewViewModel {
    
    private func handle(error: Error) {
        if let networkError = error as? NetworkError {
            self.errorMessage = networkError.localizedDescription
            switch networkError {
            case .invalidURL:
                print(networkError.localizedDescription)
            case .responseError:
                print(networkError.localizedDescription)
            case .unknown:
                print(networkError.localizedDescription)
            case .authentication:
                print(networkError.localizedDescription)
            }
        }
    }
    
}
