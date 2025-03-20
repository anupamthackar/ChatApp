//
//  ChatViewController.swift
//  ChatApplication
//
//  Created by Anupam on 19/03/25.
//

import UIKit
import MessageKit
import InputBarAccessoryView

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

	}

	required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
	
	//MARK: - Life Cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Delegate Call
		delegateCall()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		messageInputBar.inputTextView.becomeFirstResponder()
		
		if let conversationId = conversationId{
			listenForMessages(id: conversationId, shouldScrollTobottom: true)
		}
	}
	
	private func listenForMessages(id: String, shouldScrollTobottom: Bool) {
		DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
			switch result {
			case .success(let messages):
				print("success in getting messages \(messages)")
				guard !messages.isEmpty else {
					print("messages are empty")
					return
				}
				self?.messages = messages
				
				DispatchQueue.main.async {
					self?.messagesCollectionView.reloadDataAndKeepOffset()
					
					if shouldScrollTobottom {
						self?.messagesCollectionView.scrollToLastItem()
					}
				}
			case .failure(let error):
				print("failed to get messages: \(error)")
			}
		})
	}
}

// MARK: - Input Bar Delegate

extension ChatViewController: InputBarAccessoryViewDelegate {
	func inputBar(_ inputBar: InputBarAccessoryView,didPressSendButtonWith text: String) {
		guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
			  let selfSender = self.selfSender,
			  let messageId = createMessageId() else {
			return
		}
		print("Sending \(text)")
		
		let mmessage = Message(sender: selfSender,
							   messageId: messageId,
							   sentDate: Date(),
							   kind: .text(text))
		
		//Send Message
		if isNewConversation {
			// create conversation in database
			DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User" , firstMessage: mmessage, completion: { [weak self] success in
				if success {
					print("message sent")
					self?.isNewConversation = false
				}
				else {
					print("message failed")
				}
			})
			
		} else {
			// append to existing conversation data
			guard let conversationId = conversationId, let name = self.title else {
				return
			}
			// append to existing conversation data
			DatabaseManager.shared.sendMessage(to: conversationId,
											   otherUserEmail: otherUserEmail,
											   name: name,
											   newMessage: mmessage,
											   completion: { success in
				if success {
					print("message sent")
				}
				else {
					print("failed to send")
				}
				
			})
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

//MARK: - MessageKit Delegate

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

// MARK: - Utility

extension ChatViewController {
	private func delegateCall() {
		messagesCollectionView.messagesDataSource = self
		messagesCollectionView.messagesLayoutDelegate = self
		messagesCollectionView.messagesDisplayDelegate = self
		messageInputBar.delegate = self
	}
}
