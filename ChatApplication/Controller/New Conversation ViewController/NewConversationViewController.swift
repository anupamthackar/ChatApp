//
//  NewConversationViewController.swift
//  ChatApplication
//
//  Created by Anupam on 19/03/25.
//
import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
	
	public var completion: (([String: String]) -> (Void))?
	
	private let spinner = JGProgressHUD(style: .dark)
	
	private var users = [[String: String]]()
	private var results = [[String: String]]()
	private var hasFetched = false
	
	private let searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.placeholder = "Search for users..."
		return searchBar
	}()
	
	private let tableView: UITableView = {
		let table = UITableView()
		table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		return table
	}()
	
	private let noResultsLabel: UILabel = {
		let label = UILabel()
		label.isHidden = true
		label.text = "No Results"
		label.textAlignment = .center
		label.textColor = .gray
		label.font = .systemFont(ofSize: 21, weight: .medium)
		return label
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		addSubviewView()
		
		delegateCall()
		
		view.backgroundColor = .white
		navigationController?.navigationBar.topItem?.titleView = searchBar
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: "Cancel",
			style: .done,
			target: self,
			action: #selector(didTapCancel)
		)
		
		searchBar.becomeFirstResponder()
	}
	
	@objc private func didTapCancel() {
		dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viewLayoutSubview()
	}
}

// MARK: - Table View Delegate

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return results.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = results[indexPath.row]["name"]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Start Conversation
		let targetUserData = results[indexPath.row]
		dismiss(animated: true, completion: { [weak self] in
			self?.completion?(targetUserData)
		})
	}
}

// MARK: - Search Bar Delegate

extension NewConversationViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		print("Search button clicked")
		guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
			return
		}
		
		searchBar.resignFirstResponder()
		
		results.removeAll()
		
		spinner.show(in: view)
		
		self.searchUsers(query: text)
	}
	
	func searchUsers(query: String) {
		if hasFetched {
			filterUsers(with: query)
		} else {
			DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
				switch result {
				case .success(let usersCollection):
					self?.hasFetched = true
					self?.users = usersCollection
					self?.filterUsers(with: query)
				case .failure(let error):
					print("Failed to get users: \(error)")
				}
			})
		}
	}
	
	func filterUsers(with term: String) {
		guard hasFetched else {
			return
		}
		
		self.spinner.dismiss()
		
		let results: [[String: String]] = self.users.filter({
			guard let name = $0["name"]?.lowercased() else {
				return false
			}
			return name.hasPrefix(term.lowercased())
		})
		self.results = results
		updateUI()
	}
	
	func updateUI() {
		if results.isEmpty {
			self.noResultsLabel.isHidden = false
			self.tableView.isHidden = true
		} else {
			self.noResultsLabel.isHidden = true
			self.tableView.isHidden = false
			self.tableView.reloadData()
		}
	}
}

// MARK: - Utility

extension NewConversationViewController {
	private func delegateCall() {
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	private func addSubviewView() {
		view.addSubview(noResultsLabel)
		view.addSubview(tableView)
	}
	
	private func viewLayoutSubview() {
		tableView.frame = view.bounds
		noResultsLabel.frame = CGRect(
			x: view.width/4,
			y: (view.height-200)/2,
			width: CGFloat(Int(view.width)/2),
			height: 100
		)
	}
}
