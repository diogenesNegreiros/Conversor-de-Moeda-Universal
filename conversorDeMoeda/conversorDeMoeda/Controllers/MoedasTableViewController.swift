//
//  MoedasTableViewController.swift
//  conversorDeMoeda
//
//  Created by Diogenes de Souza on 08/01/21.
//

import UIKit
import CoreData

protocol MoedasTableViewControllerDelegate {
    func moedaSelected(moedaSelecionada: Currency)
}

class MoedasTableViewController: UITableViewController {
    
    var fetchedResultsController : NSFetchedResultsController<Currency>!
    var delegado: MoedasTableViewControllerDelegate?
    var arrayCurrenciesSearch:[Currency] = []
    var arrayCurrenciesInApi:[Currency] = []
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCoreDataCurrencies()
        
        //MARK Consumir lista da API
        if arrayCurrenciesSearch.isEmpty {
            carregarLista()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK Pega a lista de moedas no Core Data
    func getCoreDataCurrencies(){
        let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
        let sortDescritor = NSSortDescriptor(key: "nome", ascending: true)
        fetchRequest.sortDescriptors = [sortDescritor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            arrayCurrenciesInApi = fetchedResultsController.fetchedObjects ?? []
            arrayCurrenciesSearch = arrayCurrenciesInApi
            print("RECUPEROU ARRAY DO BANCO -  getCoreDataCurrencies()")
            
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Retorna para a view anterior, botão no final da lista
    @IBAction func returViewAfter(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Carrega a lista de moedas do servidor na View
    func carregarLista(){
        
        Rest.loadCurrencys(endPoint: "list"){(nomesSiglas, siglasValues) in
            self.arrayCurrenciesInApi = nomesSiglas as! [Currency]
            self.arrayCurrenciesSearch = self.arrayCurrenciesInApi
            
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        } onError: { (cambioError) in
            print("Erro de internet")
            self.showAlert(title: "Atenção!", message: "Sem internet, ou sem resposta do servidor!")
        }
        print("EXECUTOU METODO CARREGAR LISTA")
    }
    
    //MARK Cria um alerta simples
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: Filtra a lista de moedas
    func buscarMoeda(textoBusca: String){
        
        if textoBusca == "" {
            self.arrayCurrenciesSearch = self.arrayCurrenciesInApi
            myTableView.reloadData()
        }else{
            let text = textoBusca.lowercased()
            self.arrayCurrenciesSearch = self.arrayCurrenciesInApi
            self.arrayCurrenciesSearch = self.arrayCurrenciesSearch.filter { $0.nome!.lowercased().contains(text)}
            
            print("Array filtrado: \(arrayCurrenciesSearch)")
        }
        
        print("EXECUTOU METODO BUSCAR MOEDA!!!!")
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("EXECUTOU  numberOfRowsInSection ")
        return arrayCurrenciesSearch.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let moeda = arrayCurrenciesSearch[indexPath.row]
        cell.textLabel?.text = String(moeda.nome!)
        cell.detailTextLabel?.text = String(moeda.sigla!)
        return cell
    }
    // MARK:  a method from UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let moeda: Currency = arrayCurrenciesSearch[indexPath.row]
        delegado?.moedaSelected(moedaSelecionada: moeda)
        navigationController?.popViewController(animated: true)
    }
}
extension MoedasTableViewController:  UISearchBarDelegate, NSFetchedResultsControllerDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.arrayCurrenciesSearch = self.arrayCurrenciesInApi
        myTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.mySearchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("DIGITOU NA SEACH BAR:   \(searchBar.text!)")
        buscarMoeda(textoBusca: searchBar.text!)
        myTableView.reloadData()
        
        
    }
    
    //MARK Observa mudanças nos dados no Core Data Stack
    //    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    //
    //        switch type {
    //        case .delete:
    //            break
    //        default:
    //            print("EXECUTOU  NSFetchedResultsController<NSFetchRequestResult>, didChange anObject ")
    //
    //
    //        }
    //    }
    
    
}
