//
//  viewController+CoreData.swift
//  conversorDeMoeda
//
//  Created by Diogenes de Souza on 06/02/21.
//


import UIKit
import CoreData

extension UIViewController{
    
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
}


