/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation
import linphonesw
import Combine
import SwiftUI

class ConversationViewModel: ObservableObject {
	
	private var coreContext = CoreContext.shared
	
	@Published var displayedConversation: ConversationModel?
	@Published var displayedConversationHistorySize: Int = 0
	
	@Published var messageText: String = ""
	
	private var chatRoomSuscriptions = Set<AnyCancellable?>()
	
	@Published var conversationMessagesList: [LinphoneCustomEventLog] = []
	
	init() {}
	
	func addConversationDelegate() {
		coreContext.doOnCoreQueue { _ in
			if self.displayedConversation != nil {
				self.chatRoomSuscriptions.insert(self.displayedConversation?.chatRoom.publisher?.onChatMessageSent?.postOnCoreQueue { (cbValue: (chatRoom: ChatRoom, eventLog: EventLog)) in
					self.getNewMessages(eventLogs: [cbValue.eventLog])
				})
				
				self.chatRoomSuscriptions.insert(self.displayedConversation?.chatRoom.publisher?.onChatMessagesReceived?.postOnMainQueue { (cbValue: (chatRoom: ChatRoom, eventLogs: [EventLog])) in
					self.getNewMessages(eventLogs: cbValue.eventLogs)
				})
			}
		}
	}
	
	func removeConversationDelegate() {
		self.chatRoomSuscriptions.removeAll()
	}
	
	func getHistorySize() {
		coreContext.doOnCoreQueue { _ in
			if self.displayedConversation != nil {
				let historySize = self.displayedConversation!.chatRoom.historySize
				DispatchQueue.main.async {
					self.displayedConversationHistorySize = historySize
				}
			}
		}
	}
	
	func getMessages() {
		self.getHistorySize()
		coreContext.doOnCoreQueue { _ in
			if self.displayedConversation != nil {
				let historyEvents = self.displayedConversation!.chatRoom.getHistoryRangeEvents(begin: self.conversationMessagesList.count, end: self.conversationMessagesList.count + 30)
				
				//For List
				/*
				historyEvents.reversed().forEach { eventLog in
					DispatchQueue.main.async {
						self.conversationMessagesList.append(LinphoneCustomEventLog(eventLog: eventLog))
					}
				}
				 */
				
				//For ScrollView
				historyEvents.forEach { eventLog in
					DispatchQueue.main.async {
						self.conversationMessagesList.append(LinphoneCustomEventLog(eventLog: eventLog))
					}
				}
			}
		}
	}
	
	func getOldMessages() {
		coreContext.doOnCoreQueue { _ in
			if self.displayedConversation != nil {
				let historyEvents = self.displayedConversation!.chatRoom.getHistoryRangeEvents(begin: self.conversationMessagesList.count, end: self.conversationMessagesList.count + 30)
				
				//For List
				/*
				historyEvents.reversed().forEach { eventLog in
					DispatchQueue.main.async {
						self.conversationMessagesList.append(LinphoneCustomEventLog(eventLog: eventLog))
					}
				}
				 */
				
				//For ScrollView
				var conversationMessagesListTmp: [LinphoneCustomEventLog] = []
				
				historyEvents.reversed().forEach { eventLog in
					conversationMessagesListTmp.insert(LinphoneCustomEventLog(eventLog: eventLog), at: 0)
				}
				
				DispatchQueue.main.async {
					self.conversationMessagesList.insert(contentsOf: conversationMessagesListTmp, at: 0)
				}
			}
		}
	}
	
	func getNewMessages(eventLogs: [EventLog]) {
		eventLogs.forEach { eventLog in
			DispatchQueue.main.async {
				withAnimation {
					//For List
					//self.conversationMessagesList.insert(LinphoneCustomEventLog(eventLog: eventLog), at: 0)
					
					//For ScrollView
					self.conversationMessagesList.append(LinphoneCustomEventLog(eventLog: eventLog))
				}
			}
		}
	}
	
	func resetMessage() {
		conversationMessagesList = []
	}
	
	func sendMessage() {
		coreContext.doOnCoreQueue { _ in
			//val messageToReplyTo = chatMessageToReplyTo
			//val message = if (messageToReplyTo != null) {
			//Log.i("$TAG Sending message as reply to [${messageToReplyTo.messageId}]")
			//chatRoom.createReplyMessage(messageToReplyTo)
			//} else {
			let message = try? self.displayedConversation!.chatRoom.createEmptyMessage()
			//}
			
			let toSend = self.messageText.trimmingCharacters(in: .whitespacesAndNewlines)
			if !toSend.isEmpty {
				if message != nil {
					message!.addUtf8TextContent(text: toSend)
				}
			}
			
			/*
			 if (isVoiceRecording.value == true && voiceMessageRecorder.file != null) {
			 stopVoiceRecorder()
			 val content = voiceMessageRecorder.createContent()
			 if (content != null) {
			 Log.i(
			 "$TAG Voice recording content created, file name is ${content.name} and duration is ${content.fileDuration}"
			 )
			 message.addContent(content)
			 } else {
			 Log.e("$TAG Voice recording content couldn't be created!")
			 }
			 } else {
			 for (attachment in attachments.value.orEmpty()) {
			 val content = Factory.instance().createContent()
			 
			 content.type = when (attachment.mimeType) {
			 FileUtils.MimeType.Image -> "image"
			 FileUtils.MimeType.Audio -> "audio"
			 FileUtils.MimeType.Video -> "video"
			 FileUtils.MimeType.Pdf -> "application"
			 FileUtils.MimeType.PlainText -> "text"
			 else -> "file"
			 }
			 content.subtype = if (attachment.mimeType == FileUtils.MimeType.PlainText) {
			 "plain"
			 } else {
			 FileUtils.getExtensionFromFileName(attachment.fileName)
			 }
			 content.name = attachment.fileName
			 // Let the file body handler take care of the upload
			 content.filePath = attachment.file
			 
			 message.addFileContent(content)
			 }
			 }
			 */
			
			if message != nil && !message!.contents.isEmpty {
				Log.info("[ConversationViewModel] Sending message")
				message!.send()
			}
			
			Log.info("[ConversationViewModel] Message sent, re-setting defaults")
			
			DispatchQueue.main.async {
				self.messageText = ""
			}
			
			/*
			 isReplying.postValue(false)
			 isFileAttachmentsListOpen.postValue(false)
			 isParticipantsListOpen.postValue(false)
			 isEmojiPickerOpen.postValue(false)
			 
			 if (::voiceMessageRecorder.isInitialized) {
			 stopVoiceRecorder()
			 }
			 isVoiceRecording.postValue(false)
			 
			 // Warning: do not delete files
			 val attachmentsList = arrayListOf<FileModel>()
			 attachments.postValue(attachmentsList)
			 
			 chatMessageToReplyTo = null
			 */
		}
	}
	
	func changeDisplayedChatRoom(conversationModel: ConversationModel) {
		self.displayedConversation = conversationModel
	}
}
struct LinphoneCustomEventLog: Hashable {
	var id = UUID()
	var eventLog: EventLog
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension LinphoneCustomEventLog {
	static func ==(lhs: LinphoneCustomEventLog, rhs: LinphoneCustomEventLog) -> Bool {
		return lhs.id == rhs.id
	}
}
