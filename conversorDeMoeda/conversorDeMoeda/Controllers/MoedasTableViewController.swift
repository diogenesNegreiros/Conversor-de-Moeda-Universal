//
//  MoedasTableViewController.swift
//  conversorDeMoeda
//
//  Created by Diogenes de Souza on 08/01/21.
//

import UIKit

protocol MoedasTableViewControllerDelegate {
    func moedaSelected(nomeValue: String, siglaValue: String)
}

class MoedasTableViewController: UITableViewController {
    
    var delegado: MoedasTableViewControllerDelegate?
    var moedasServerList:[Moeda] = []
    var moedasList:[Moeda] = []
    var buttonSelect:Int?
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK Recupera lista do UserDefault
        if let myData = UserDefaults.standard.value(forKey: "listaDeMoedas") as? Data {
            self.moedasList = try! PropertyListDecoder().decode(Array<Moeda>.self, from: myData)
            
            self.moedasServerList = self.moedasList
            self.myTableView.reloadData()
            
        }
        
        carregarLista()
        
        
    }
    
    // MARK: Retorna para a view anterior, botão no final da lista
    @IBAction func returViewAfter(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: Carrega a lista de moedas na View
    func carregarLista(){
        
        Rest.loadCurrencys(endPoint: "list"){(nomesSiglas, siglasValues) in
            self.moedasServerList = nomesSiglas as! [Moeda]
            self.moedasList = self.moedasServerList
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.moedasList) , forKey: "listaDeMoedas")
            
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        } onError: { (cambioError) in
            
            print("Erro de internet")
            
        }
    }
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: Filtra a lista de moedas
    func buscarMoeda(textoBusca: String){
        if textoBusca == "" {
            self.moedasList = self.moedasServerList
            myTableView.reloadData()
        }else{
            let text = textoBusca.lowercased()
            self.moedasList = self.moedasServerList
            self.moedasList = self.moedasList.filter { $0.nome!.lowercased().contains(text) }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moedasList.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let moeda = moedasList[indexPath.row]
        cell.textLabel?.text = String(moeda.nome!)
        cell.detailTextLabel?.text = String(moeda.sigla!)
        return cell
    }
    // MARK:  a method from UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sigla:String = moedasList[indexPath.row].sigla ?? ""
        let nome:String = moedasList[indexPath.row].nome ?? ""
        
        delegado?.moedaSelected(nomeValue: nome, siglaValue: sigla)
        
        navigationController?.popViewController(animated: true)
    }
    
}

extension MoedasTableViewController:  UISearchBarDelegate{
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.moedasList = self.moedasServerList
        myTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.mySearchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchText (searchText)")
        buscarMoeda(textoBusca: searchBar.text!)
        myTableView.reloadData()
    }
}
