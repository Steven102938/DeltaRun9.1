//
//  RouteHistory.swift
//  Run
//
//  Created by Steven Li on 8/20/15.
//  Copyright (c) 2015 Steven Li. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Darwin
import CoreData
class RouteHistory: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableViewObject: UITableView!
   
    var number = 1
    var managedObjectContext:NSManagedObjectContext? = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var RunInfoData = [RunInfo]()
    var deleteRouteIndexPath: NSIndexPath? = nil
    var RunInfoSegue = "RunInfo"
    
    struct global {
        static var tempNumber: Int?
    }
    
override func viewDidAppear(animated: Bool) {
        tableViewObject.reloadData()
        tableViewObject.reloadInputViews()
}
    
 func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            var error: NSError?
            let request = NSFetchRequest(entityName: "RunInfo")
            RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
            // remove the deleted item from the model
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            context.deleteObject(RunInfoData[indexPath.row] as NSManagedObject)
            RunInfoData.removeAtIndex(indexPath.row)
            do {
                try context.save()
            } catch _ {
            }
            
            //tableView.reloadData()
            // remove the deleted item from the `UITableView`
            self.tableViewObject.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
         
        default:
            return
            
        }
    }
  
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        let routeCount = RunInfoData.count

        return routeCount
    
    }
   
    
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> mapCell
        {
        let identifier:String = "MapReuse"
        let cell:mapCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! mapCell
        var error: NSError?
        let request = NSFetchRequest(entityName: "RunInfo")
        RunInfoData = (try! managedObjectContext?.executeFetchRequest(request)) as! [RunInfo]
        var routeCount = RunInfoData.count
 
            let RunInfoForTable = RunInfoData[indexPath.row]
            
            cell.routeName.text = RunInfoForTable.name
            cell.mapImage.image = UIImage(data: RunInfoForTable.image)
            cell.DetailSegue.setTitle("Info", forState: .Normal )

       
           cell.DetailSegue.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
 
        return cell
        
    }

func pressed(sender: UIButton!) {
    
    let button = sender as UIButton
    let view = button.superview!
    let cell = view.superview as! mapCell
    let indexPath = tableViewObject.indexPathForCell(cell)
    let row = indexPath?.row
    
    print(row)
    mainInstance.routeNumber = row! + 1
    self.performSegueWithIdentifier(RunInfoSegue, sender: nil)

        print("yourButton was pressed")
    }
 
    
}

class mapCell:UITableViewCell {
    
   
   
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var DetailSegue: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
}
extension RouteDatabase{
    
}
extension UserDatabase{
    
}