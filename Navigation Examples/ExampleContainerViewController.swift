import Foundation
import UIKit

var simulationIsEnabled = true

class ExampleContainerViewController: UITableViewController {
    
    @IBOutlet weak var beginNavigation: UIButton!
    @IBOutlet weak var simulateNavigation: UISwitch!
    
    var exampleClass: UIViewController.Type?
    var exampleName: String?
    var exampleDescription: String?
    var exampleStoryboard: UIStoryboard?
    var hasEnteredExample = false
    var pushExampleToViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = exampleName
        
        if exampleClass == nil {
            beginNavigation.setTitle("Example Not Found", for: .normal)
            beginNavigation.isEnabled = false
            simulateNavigation.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hasEnteredExample {
            if let last = view.subviews.last {
                last.removeFromSuperview()
                hasEnteredExample = false
            }
        }
    }
    
    @IBAction func didTapBeginNavigation(_ sender: Any) {
        let controller = instantiate(example: exampleClass!, from: exampleStoryboard)
        embed(controller: controller, shouldPush: pushExampleToViewController)
    }
    
    private func instantiate<T: UIViewController>(example: T.Type, from storyboard: UIStoryboard? = nil) -> T {
        if let storyboard = storyboard {
            let viewController: T = storyboard.instantiateInitialViewController() as! T
            return viewController
        } else {
            let viewController: T = example.init()
            return viewController
        }
    }
    
    private func embed(controller: UIViewController, shouldPush: Bool) {
        addChildViewController(controller)
        view.addSubview(controller.view)

        controller.didMove(toParentViewController: self)
        if shouldPush {
            navigationController?.pushViewController(controller, animated: true)
        }
        hasEnteredExample = true
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let exampleDescription = exampleDescription else { return nil }
        return section == tableView.numberOfSections - 1  ? exampleDescription : nil
    }
    
    @IBAction func didToggleSimulateNavigation(_ sender: Any) {
        simulationIsEnabled = simulateNavigation.isOn
    }
}
