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
            .subscribe(onNext: { [weak self] in
                self?.tableView.tableFooterView?.isHidden = !$0
            })
            .disposed(by: bag)
        
        tableView.rx.contentOffset
            .skip(while: { _ in
                    viewModel.isLocked })
            .map { [weak self] in
                guard let self = self else { return false }
                return $0.y >= self.tableView.contentSize.height - self.tableView.frame.height - 150 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.loadNewPost.accept($0)
            })
            .disposed(by: bag)
        
    }
    
    private func createUpdateViews() {
        spinner.color = .darkGray
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        tableView.tableFooterView = spinner
        tableView.tableFooterView?.isHidden = false
        
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
        DispatchQueue.global().async { [weak self] in
            self?.viewModel?.pullToRefresh() {
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
}

