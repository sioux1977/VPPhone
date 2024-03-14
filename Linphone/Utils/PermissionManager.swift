/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
 *
 * This file is part of Linphone
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
import Photos
import Contacts
import UserNotifications
import SwiftUI

class PermissionManager: ObservableObject {
	
	static let shared = PermissionManager()
	
	@Published var pushPermissionGranted = false
	@Published var photoLibraryPermissionGranted = false
	@Published var cameraPermissionGranted = false
	@Published var contactsPermissionGranted = false
	@Published var microphonePermissionGranted = false
	
	private init() {}
	
	func getPermissions() {
		pushNotificationRequestPermission()
		microphoneRequestPermission()
		photoLibraryRequestPermission()
		cameraRequestPermission()
		contactsRequestPermission()
	}
	
	func pushNotificationRequestPermission() {
		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
			if let error = error {
				Log.error("Unexpected error when asking for Push permission : \(error.localizedDescription)")
			}
			DispatchQueue.main.async {
				self.pushPermissionGranted = granted
			}
		}
	}
	
	func microphoneRequestPermission() {
		AVAudioSession.sharedInstance().requestRecordPermission({ granted in
			DispatchQueue.main.async {
				self.microphonePermissionGranted = granted
			}
		})
	}
	
	func photoLibraryRequestPermission() {
		PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: {status in
			DispatchQueue.main.async {
				self.photoLibraryPermissionGranted = (status == .authorized || status == .limited || status == .restricted)
			}
		})
	}
	
	func cameraRequestPermission() {
		AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
			DispatchQueue.main.async {
				self.cameraPermissionGranted = accessGranted
			}
		})
	}
	
	func contactsRequestPermission() {
		let store = CNContactStore()
		store.requestAccess(for: .contacts) { success, _ in
			DispatchQueue.main.async {
				self.contactsPermissionGranted = success
			}
		}
	}
}
