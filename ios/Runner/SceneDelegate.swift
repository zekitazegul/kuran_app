import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    // Prevent automatic screen locking while the app is active for reading.
    UIApplication.shared.isIdleTimerDisabled = true
  }

  override func sceneWillResignActive(_ scene: UIScene) {
    UIApplication.shared.isIdleTimerDisabled = false
    super.sceneWillResignActive(scene)
  }
}
