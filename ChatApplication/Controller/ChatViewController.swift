//
//  ChatViewController.swift
//  ChatApplication
//
//  Created by Anupam on 19/03/25.
//

import UIKit
import MessageKit
import InputBarAccessoryView


struct Message: MessageType {
	public var sender: SenderType
	public var messageId: String
	public var sentDate: Date
	public var kind: MessageKind
}

extension MessageKind {
	var messageKindString: String {
		switch self {
		case .text(_):
			return "text"
		case .attributedText(_):
			return "attributed_text"
		case .photo(_):
			return "photo"
		case .video(_):
			return "video"
		case .location(_):
			return "location"
		case .emoji(_):
			return "emoji"
		case .audio(_):
			return "audio"
		case .contact(_):
			return "contact"
		case .custom(_):
			return "customc"
		case .linkPreview(_):
			return "link"
		}
	}
}

struct Sender: SenderType {
	public var photoURL: String
	public var senderId: String
	public var displayName: String

}

class ChatViewController: MessagesViewController {
	
	//MARK: - Properties
	public static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .long
		formatter.locale = .current
		return formatter
	}()
	
	public let otherUserEmail: String
	
	private let conversationId: String?
	
	public var isNewConversation = false
	
	private var messages = [Message]()
	
	private var selfSender: Sender? = {
		guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
			return nil
		}
		
		let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
		
		return Sender(photoURL: "",
			   senderId: safeEmail,
			   displayName: "Me")
	}()
	
	init(with email: String, id: String?) {
		self.conversationId = id 
		self.otherUserEmail = email
		super.init(nibName: nil, bundle: nil)
		if let conversationId = conversationId{
			listenForMessages(id: conversationId)
		}
	}

	required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .red
		
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messageInputBar.delegate = self
        
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		messageInputBar.inputTextView.becomeFirstResponder()
	}
	
	private func listenForMessages(id: String) {
		DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
			switch result {
			case .success(let messages):
				guard !messages.isEmpty else {
					return
				}
				self?.messages = messages
				
				DispatchQueue.main.async {
					self?.messagesCollectionView.reloadDataAndKeepOffset()
				}
			case .failure(let error):
				print("failed to get messages: \(error)")
			}
		})
	}
}

extension ChatViewController: InputBarAccessoryViewDelegate {
	func inputBar(_ inputBar: InputBarAccessoryView,didPressSendButtonWith text: String) {
		guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
			  let selfSender = self.selfSender,
			  let messageId = createMessageId() else {
			return
		}
		print("Sending \(text)")
		
		//Send Message
		if isNewConversation {
			// create conversation in database
			let mmessage = Message(sender: selfSender,
								  messageId: messageId,
								  sentDate: Date(),
								  kind: .text(text))
			DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User" , firstMessage: mmessage, completion: { success in
				if success {
					print("message sent")
				}
				else {
					print("message failed")
				}
			})
			
		} else {
			// append to existing conversation data
		}
	}
	
	private func createMessageId() -> String? {
		// Date, otheruserEmail, senderEmail, randomInt
		guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
		
		let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
		
		let dateString = Self.dateFormatter.string(from: Date())
		
		let newIdentifier = "\(otherUserEmail) \(safeCurrentEmail) \(dateString)"
		
		print("Created message id: \(newIdentifier)")
		
		return newIdentifier
	}
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
	func currentSender() -> SenderType {
		if let sender = selfSender {
			return sender
		}
		fatalError("Self Sender is nil, email should be cached")
		
	}

	func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageType {
		return messages[indexPath.section]
	}

	func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
		return messages.count
	}

}

