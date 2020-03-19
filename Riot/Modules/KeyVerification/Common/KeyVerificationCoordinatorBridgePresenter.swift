// File created from FlowTemplate
// $ createRootCoordinator.sh DeviceVerification DeviceVerification DeviceVerificationStart
/*
 Copyright 2019 New Vector Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

@objc protocol KeyVerificationCoordinatorBridgePresenterDelegate {
    func keyVerificationCoordinatorBridgePresenterDelegateDidComplete(_ coordinatorBridgePresenter: KeyVerificationCoordinatorBridgePresenter, otherUserId: String, otherDeviceId: String)
}

/// KeyVerificationCoordinatorBridgePresenter enables to start KeyVerificationCoordinator from a view controller.
/// This bridge is used while waiting for global usage of coordinator pattern.
@objcMembers
final class KeyVerificationCoordinatorBridgePresenter: NSObject {
    
    // MARK: - Properties
    
    // MARK: Private
    
    private let session: MXSession
    private var coordinator: KeyVerificationCoordinator?
    
    // MARK: Public
    
    weak var delegate: KeyVerificationCoordinatorBridgePresenterDelegate?
    
    // MARK: - Setup
    
    init(session: MXSession) {
        self.session = session
        super.init()
    }
    
    // MARK: - Public
    
    // NOTE: Default value feature is not compatible with Objective-C.
    // func present(from viewController: UIViewController, animated: Bool) {
    //     self.present(from: viewController, animated: animated)
    // }
    
    func present(from viewController: UIViewController, otherUserId: String, otherDeviceId: String, animated: Bool) {
        
        NSLog("[KeyVerificationCoordinatorBridgePresenter] Present from \(viewController)")
        
        let keyVerificationCoordinator = KeyVerificationCoordinator(session: self.session, otherUserId: otherUserId, otherDeviceId: otherDeviceId)
        keyVerificationCoordinator.delegate = self
        viewController.present(keyVerificationCoordinator.toPresentable(), animated: animated, completion: nil)
        keyVerificationCoordinator.start()
        
        self.coordinator = keyVerificationCoordinator
    }
    
    func present(from viewController: UIViewController, roomMember: MXRoomMember, animated: Bool) {
        
        NSLog("[KeyVerificationCoordinatorBridgePresenter] Present from \(viewController)")
        
        let keyVerificationCoordinator = KeyVerificationCoordinator(session: self.session, roomMember: roomMember)
        keyVerificationCoordinator.delegate = self
        viewController.present(keyVerificationCoordinator.toPresentable(), animated: animated, completion: nil)
        keyVerificationCoordinator.start()
        
        self.coordinator = keyVerificationCoordinator
    }

    func present(from viewController: UIViewController, incomingTransaction: MXIncomingSASTransaction, animated: Bool) {
        
        NSLog("[KeyVerificationCoordinatorBridgePresenter] Present incoming verification from \(viewController)")
        
        let keyVerificationCoordinator = KeyVerificationCoordinator(session: self.session, incomingTransaction: incomingTransaction)
        keyVerificationCoordinator.delegate = self
        viewController.present(keyVerificationCoordinator.toPresentable(), animated: animated, completion: nil)
        keyVerificationCoordinator.start()

        self.coordinator = keyVerificationCoordinator
    }    
    
    func present(from viewController: UIViewController, incomingKeyVerificationRequest: MXKeyVerificationRequest, animated: Bool) {
        
        NSLog("[KeyVerificationCoordinatorBridgePresenter] Present incoming key verification request from \(viewController)")
        
        let keyVerificationCoordinator = KeyVerificationCoordinator(session: self.session, incomingKeyVerificationRequest: incomingKeyVerificationRequest)
        keyVerificationCoordinator.delegate = self
        viewController.present(keyVerificationCoordinator.toPresentable(), animated: animated, completion: nil)
        keyVerificationCoordinator.start()

        self.coordinator = keyVerificationCoordinator
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        guard let coordinator = self.coordinator else {
            return
        }
        
        NSLog("[KeyVerificationCoordinatorBridgePresenter] Dismiss")
        
        coordinator.toPresentable().dismiss(animated: animated) {
            self.coordinator = nil

            if let completion = completion {
                completion()
            }
        }
    }
}

// MARK: - KeyVerificationCoordinatorDelegate
extension KeyVerificationCoordinatorBridgePresenter: KeyVerificationCoordinatorDelegate {
    func keyVerificationCoordinatorDidComplete(_ coordinator: KeyVerificationCoordinatorType, otherUserId: String, otherDeviceId: String) {
        self.delegate?.keyVerificationCoordinatorBridgePresenterDelegateDidComplete(self, otherUserId: otherUserId, otherDeviceId: otherDeviceId)
    }
}