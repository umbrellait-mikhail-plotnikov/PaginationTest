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

class ViewController: UIViewController {
    let bag = DisposeBag()
    var viewModel: TableViewViewModel?
    
    let spinner = UIActivityIndicatorView(style: .medium)
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    private func bindUI() {
        guard let viewModel = viewModel else { fatalError() }
        
        viewModel.characters
            .bind(to: tableView.rx.items) { (table, index, model) in
                guard let cell = table.dequeueReusableCell(withIdentifier: "Cell") else { fatalError() }
                cell.textLabel?.text = model
                return cell
        }.disposed(by: bag)
        
        viewModel.loadNewPost
            .distinctUntilChanged()
            .subscribe(onNext: {
                $0 ? self.spinner.startAnimating() : self.spinner.stopAnimating()
            })
            .disposed(by: bag)
        
        tableView.rx.contentOffset
            .skip(while: { _ in
                    viewModel.isLocked })
            .map { return $0.y >= self.tableView.contentSize.height - self.tableView.frame.height - 150 }
            .distinctUntilChanged()
            .bind(to: viewModel.loadNewPost)
            .disposed(by: bag)
        
    }
    
    private func createUpdateViews() {
        spinner.color = .darkGray
        spinner.hidesWhenStopped = true
        tableView.tableFooterView = spinner
        self.tableView.tableFooterView?.isHidden = false
        
        refreshControl.attributedTitle = NSAttributedString(string: "Update...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = TableViewViewModel(APIProvider: APIProvider())
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        bindUI()
        
        createUpdateViews()
        
    }
    
    @objc private func refresh(sender: AnyObject) {
        DispatchQueue.global().async {
            sleep(1)
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
}

