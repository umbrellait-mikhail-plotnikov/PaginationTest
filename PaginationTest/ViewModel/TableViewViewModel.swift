//
//  ViewModel.swift
//  PaginationTest
//
//  Created by Mikhail Plotnikov on 06.04.2021.
//
import RxCocoa
import RxSwift
import Foundation

class TableViewViewModel {
    let characters = BehaviorRelay<[String]>(value: [])
    let api: APIProviderProtocol
    let disposeBag = DisposeBag()
    
    var isLocked = false
    var loadNewPost = BehaviorRelay<Bool>(value: false)
    
    func loadNewData() {
        guard !isLocked else { return }
        
        self.isLocked = true
        
        let newPosts = api.getCharacters(limit: 100, offset: characters.value.count)
        var newArray = [String]()
        newPosts.subscribe(onNext: { [weak self] in
            guard let res = $0.results,
                  let self = self else { return }
            for item in res {
                guard let name = item["name"] as? String else { return }
                newArray.append(name)
            }
            self.characters.accept(self.characters.value + newArray)
            self.isLocked = false
        })
        .disposed(by: disposeBag)
        print("CALL")
    }
    
    init(APIProvider: APIProviderProtocol) {
        self.api = APIProvider
        loadNewPost
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.loadNewData()
            }).disposed(by: disposeBag)
    }
    
}
