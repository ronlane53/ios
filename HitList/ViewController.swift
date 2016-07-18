
import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var people = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\"The List\""
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let personsFetch = NSFetchRequest(entityName: "Person")
        
        do {
            let fetchedPersons = try managedContext.executeFetchRequest(personsFetch) as! [NSManagedObject]
            people = fetchedPersons
        } catch {
            fatalError("Failed to fetch persons: \(error)")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addName(sender: AnyObject) {
        let alert = UIAlertController(
                     title: "New name",
                   message: "Add a new name",
            preferredStyle: .Alert
        )
        
        let saveAction = UIAlertAction(
            title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0] as UITextField
                self.saveName(textField.text!)
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(
            alert,
            animated: true,
            completion: nil
        )
        
    }
    
    func saveName(name: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName(
            "Person",
            inManagedObjectContext: managedContext
        )
        
        let person = NSManagedObject(
            entity: entity!,
            insertIntoManagedObjectContext: managedContext
        )
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
        }
            catch {
                print("Could not save")
            }
        
        people.append(person)
    }
    
    // MARK: TableView Delegation Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let person = people[indexPath.row]
        cell.textLabel!.text = person.valueForKey("name") as! String?
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let moc = appDelegate.managedObjectContext
            moc.deleteObject(people[indexPath.row])
            appDelegate.saveContext()
            people.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

}

