//
//  ViewModel.swift
//  PaginationTest
//
//  Created by Mikhail Plotnikov on 06.04.2021.
//
import RxCocoa
import RxSwift
import Foundation

class ViewModel {
    let character = BehaviorRelay<[String]>(value: [])
    let api: APIProviderProtocol
    let disposeBag = DisposeBag()
    
    var isLock = false
    var loadNewPost = BehaviorRelay<Bool>(value: false)
    
    func loadNewData() {
        self.isLock = true
        let newPosts = api.getCharacters(limit: 100, offset: character.value.count)
        var newArray = [String]()
        newPosts.subscribe(onNext: {
            guard let res = $0.results else { fatalError() }
            for item in res {
                guard let name = item["name"] as? String else { fatalError() }
                newArray.append(name)
            }
            self.character.accept(self.character.value + newArray)
        })
        .disposed(by: disposeBag)
        print("CALL")
    }
    
    init(APIProvider: APIProviderProtocol) {
        self.api = APIProvider
        loadNewPost
            .filter { $0 == true && !self.isLock }
            .subscribe(onNext: { [weak self] _ in
                self?.loadNewData()
                
            }).disposed(by: disposeBag)
    }
    
}
