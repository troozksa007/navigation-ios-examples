import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

@objc(WaypointArrivalScreen)
class WaypointArrivalScreen: UIViewController, NavigationViewControllerDelegate, WaypointConfirmationViewControllerDelegate {
    
    override func viewDidLoad() {
        let waypointOne = Waypoint(coordinate: CLLocationCoordinate2DMake(37.77440680146262, -122.43539772352648))
        let waypointTwo = Waypoint(coordinate: CLLocationCoordinate2DMake(37.76556957793795, -122.42409811526268))
        let waypointThree = Waypoint(coordinate: CLLocationCoordinate2DMake(37.77440680146262, -122.43539772352648))
        
        let options = NavigationRouteOptions(waypoints: [waypointOne, waypointTwo, waypointThree])
        
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            let navigationController = NavigationViewController(for: route)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    // By default, when the user arrives at a waypoint, the next leg starts immediately.
    // If however you would like to pause and allow the user to provide input, set this delegate method to false.
    // This does however require you to increment the leg count on your own. See the example below in `confirmationControllerDidConfirm()`.
    func navigationViewController(_ navigationViewController: NavigationViewController, shouldIncrementLegWhenArrivingAtWaypoint waypoint: Waypoint) -> Bool {
        return false
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) {
        // When the user arrives, present a view controller that prompts the user to continue to their next destination
        // This typ of screen could show information about a destination, pickup/dropoff confirmation, instructions upon arrival, etc.
        guard let confirmationController = self.storyboard?.instantiateViewController(withIdentifier: "waypointConfirmation") as? WaypointConfirmationViewController else { return }
        confirmationController.delegate = self
        
        navigationViewController.present(confirmationController, animated: true, completion: nil)
    }
    
    func confirmationControllerDidConfirm(_ confirmationController: WaypointConfirmationViewController) {
        confirmationController.dismiss(animated: true, completion: {
            guard let navigationViewController = self.presentedViewController as? NavigationViewController else { return }
            
            guard navigationViewController.routeController.routeProgress.route.legs.count > navigationViewController.routeController.routeProgress.legIndex + 1 else { return }
            navigationViewController.routeController.routeProgress.legIndex += 1
        })
    }
}

protocol WaypointConfirmationViewControllerDelegate: NSObjectProtocol {
    func confirmationControllerDidConfirm(_ controller: WaypointConfirmationViewController)
}

class WaypointConfirmationViewController: UIViewController {
    
    weak var delegate: WaypointConfirmationViewControllerDelegate?
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        delegate?.confirmationControllerDidConfirm(self)
    }
}

