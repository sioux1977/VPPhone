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

import SwiftUI
import Contacts
import ContactsUI

struct ContactInnerFragment: View {
	
	@ObservedObject private var sharedMainViewModel = SharedMainViewModel()
	
	@ObservedObject var magicSearch = MagicSearchSingleton.shared
	
	@ObservedObject var contactViewModel: ContactViewModel
	@ObservedObject var editContactViewModel: EditContactViewModel
	
	@State private var orientation = UIDevice.current.orientation
	
	@State private var presentingEditContact = false
	@State var cnContact: CNContact?
	
	@Binding var isShowDeletePopup: Bool
	@Binding var showingSheet: Bool
	@Binding var showShareSheet: Bool
	@Binding var isShowDismissPopup: Bool
	
	var body: some View {
		NavigationView {
			VStack(spacing: 1) {
				Rectangle()
					.foregroundColor(Color.orangeMain500)
					.edgesIgnoringSafeArea(.top)
					.frame(height: 0)
				
				HStack {
					if !(orientation == .landscapeLeft || orientation == .landscapeRight
						 || UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height) {
						Image("caret-left")
							.renderingMode(.template)
							.resizable()
							.foregroundStyle(Color.orangeMain500)
							.frame(width: 25, height: 25, alignment: .leading)
							.padding(.top, 2)
							.onTapGesture {
								withAnimation {
									contactViewModel.indexDisplayedFriend = nil
								}
							}
					}
					
					Spacer()
					if contactViewModel.indexDisplayedFriend != nil && contactViewModel.indexDisplayedFriend! < magicSearch.lastSearch.count
						&& magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend != nil
						&& magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend!.nativeUri != nil
						&& !magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend!.nativeUri!.isEmpty {
						Button(action: {
							editNativeContact()
						}, label: {
							Image("pencil-simple")
								.renderingMode(.template)
								.resizable()
								.foregroundStyle(Color.orangeMain500)
								.frame(width: 25, height: 25, alignment: .leading)
								.padding(.top, 2)
						})
					} else {
						NavigationLink(destination: EditContactFragment(
							editContactViewModel: editContactViewModel,
							isShowEditContactFragment: .constant(false),
							isShowDismissPopup: $isShowDismissPopup)) {
							Image("pencil-simple")
								.renderingMode(.template)
								.resizable()
								.foregroundStyle(Color.orangeMain500)
								.frame(width: 25, height: 25, alignment: .leading)
								.padding(.top, 2)
						}
						.simultaneousGesture(
							TapGesture().onEnded {
								editContactViewModel.selectedEditFriend = magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend
								editContactViewModel.resetValues()
							}
						)
					}
				}
				.frame(maxWidth: .infinity)
				.frame(height: 50)
				.padding(.horizontal)
				.padding(.bottom, 4)
				.background(.white)
				
				ScrollView {
					VStack(spacing: 0) {
						VStack(spacing: 0) {
							VStack(spacing: 0) {
								if contactViewModel.indexDisplayedFriend != nil && contactViewModel.indexDisplayedFriend! < magicSearch.lastSearch.count
									&& magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend != nil
									&& magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend!.photo != nil
									&& !magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend!.photo!.isEmpty {
									AsyncImage(
										url: ContactsManager.shared.getImagePath(
										friendPhotoPath: magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend!.photo!)) { image in
										switch image {
										case .empty:
											ProgressView()
												.frame(width: 100, height: 100)
										case .success(let image):
											image
												.resizable()
												.aspectRatio(contentMode: .fill)
												.frame(width: 100, height: 100)
												.clipShape(Circle())
										case .failure:
											Image("profil-picture-default")
												.resizable()
												.frame(width: 100, height: 100)
												.clipShape(Circle())
										@unknown default:
											EmptyView()
										}
									}
								} else if contactViewModel.indexDisplayedFriend != nil && magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend != nil {
									Image("profil-picture-default")
										.resizable()
										.frame(width: 100, height: 100)
										.clipShape(Circle())
								}
								if contactViewModel.indexDisplayedFriend != nil
									&& magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend != nil
									&& magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend?.name != nil {
									Text((magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend?.name)!)
										.foregroundStyle(Color.grayMain2c700)
										.multilineTextAlignment(.center)
										.default_text_style(styleSize: 14)
										.frame(maxWidth: .infinity)
										.padding(.top, 10)
									
									Text("En ligne")
										.foregroundStyle(Color.greenSuccess500)
										.multilineTextAlignment(.center)
										.default_text_style_300(styleSize: 12)
										.frame(maxWidth: .infinity)
								}
								
							}
							.frame(minHeight: 150)
							.frame(maxWidth: .infinity)
							.padding(.top, 10)
							.background(Color.gray100)
							
							HStack {
								Spacer()
								
								Button(action: {
								}, label: {
									VStack {
										HStack(alignment: .center) {
											Image("phone")
												.renderingMode(.template)
												.resizable()
												.foregroundStyle(Color.grayMain2c600)
												.frame(width: 25, height: 25)
												.onTapGesture {
													withAnimation {
														
													}
												}
										}
										.padding(16)
										.background(Color.grayMain2c200)
										.cornerRadius(40)
										
										Text("Appel")
											.default_text_style(styleSize: 14)
									}
								})
								
								Spacer()
								
								Button(action: {
									
								}, label: {
									VStack {
										HStack(alignment: .center) {
											Image("chat-teardrop-text")
												.renderingMode(.template)
												.resizable()
												.foregroundStyle(Color.grayMain2c600)
												.frame(width: 25, height: 25)
												.onTapGesture {
													withAnimation {
														
													}
												}
										}
										.padding(16)
										.background(Color.grayMain2c200)
										.cornerRadius(40)
										
										Text("Message")
											.default_text_style(styleSize: 14)
									}
								})
								
								Spacer()
								
								Button(action: {
									
								}, label: {
									VStack {
										HStack(alignment: .center) {
											Image("video-camera")
												.renderingMode(.template)
												.resizable()
												.foregroundStyle(Color.grayMain2c600)
												.frame(width: 25, height: 25)
												.onTapGesture {
													withAnimation {
														
													}
												}
										}
										.padding(16)
										.background(Color.grayMain2c200)
										.cornerRadius(40)
										
										Text("Video Call")
											.default_text_style(styleSize: 14)
									}
								})
								
								Spacer()
							}
							.padding(.top, 20)
							.frame(maxWidth: .infinity)
							.background(Color.gray100)

							ContactInnerActionsFragment(
								contactViewModel: contactViewModel,
								editContactViewModel: editContactViewModel,
								showingSheet: $showingSheet,
								showShareSheet: $showShareSheet,
								isShowDeletePopup: $isShowDeletePopup,
								isShowDismissPopup: $isShowDismissPopup,
								actionEditButton: editNativeContact
							)
						}
						.frame(maxWidth: sharedMainViewModel.maxWidth)
					}
					.frame(maxWidth: .infinity)
				}
				.background(Color.gray100)
			}
			.background(.white)
			.navigationBarHidden(true)
			.onRotate { newOrientation in
				orientation = newOrientation
			}
			.fullScreenCover(isPresented: $presentingEditContact) {
				NavigationView {
					EditContactView(contact: $cnContact)
						.navigationBarTitle("Edit Contact")
						.navigationBarTitleDisplayMode(.inline)
						.edgesIgnoringSafeArea(.vertical)
				}
			}
		}
		.navigationViewStyle(.stack)
	}
	
	func editNativeContact() {
		do {
			let store = CNContactStore()
			let descriptor = CNContactViewController.descriptorForRequiredKeys()
			cnContact = try store.unifiedContact(
				withIdentifier: magicSearch.lastSearch[contactViewModel.indexDisplayedFriend!].friend!.nativeUri!,
				keysToFetch: [descriptor]
			)
			
			if cnContact != nil {
				presentingEditContact.toggle()
			}
		} catch {
			print(error)
		}
	}
}

#Preview {
	ContactInnerFragment(
		contactViewModel: ContactViewModel(),
		editContactViewModel: EditContactViewModel(),
		isShowDeletePopup: .constant(false),
		showingSheet: .constant(false),
		showShareSheet: .constant(false),
		isShowDismissPopup: .constant(false)
	)
}
