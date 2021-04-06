//
//  ViewController.swift
//  PaginationTest
//
//  Created by Mikhail Plotnikov on 02.04.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxAlamofire
import CryptoKit
import ObjectMapper

class ViewController: UIViewController {
    let bag = DisposeBag()
    var viewModel: ViewModel?
    
    @IBOutlet weak var tableView: UITableView!
    
    private func bindUI() {
        guard let viewModel = viewModel else { fatalError() }
        
        viewModel.character
            .bind(to: tableView.rx.items) { (table, index, model) in
                guard let cell = table.dequeueReusableCell(withIdentifier: "Cell") else { fatalError() }
                cell.textLabel?.text = model
                return cell
        }.disposed(by: bag)
        
        tableView.rx.contentOffset
            .skip(while: { [weak self] _ in
                    self?.viewModel?.isLock ?? false })
            .filter { return $0.y < self.tableView.contentSize.height - self.tableView.frame.height - 100 }
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.isLock = false
            })
            .disposed(by: bag)
        
        tableView.rx.contentOffset
            .skip(while: { [weak self] _ in
                    self?.viewModel?.isLock ?? false })
            .map { return $0.y >= self.tableView.contentSize.height - self.tableView.frame.height - 100 }
            .bind(to: viewModel.loadNewPost)
            .disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel(APIProvider: APIProvider())
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        bindUI()
        
    }
    
}

