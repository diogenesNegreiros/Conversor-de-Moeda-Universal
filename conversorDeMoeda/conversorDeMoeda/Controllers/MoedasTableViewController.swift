//
//  MoedasTableViewController.swift
//  conversorDeMoeda
//
//  Created by Diogenes de Souza on 08/01/21.
//

import UIKit

class MoedasTableViewController: UITableViewController {
    
    var moedasServerList:[Moeda] = []
    var moedasList:[Moeda] = []
    var buttonSelect:Int?
    
//    @IBOutlet var searchController : UISearchController!
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        myTableView.delegate = self
        
        carregarLista()
    }
    
    // MARK: Retorna para a view anterior, botão no final da lista
    @IBAction func returViewAfter(_ sender: Any) {
        fecharView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: pega no UserDefault o id do botão acionado na tela anterior
        buttonSelect =  UserDefaults.standard.integer(forKey: "buttonSelect")
        
    }
    // MARK: Carrega a lista de moedas na View
    func carregarLista(){
        Rest.loadCurrencys(endPoint: "list"){(nomesSiglas, siglasValues) in
            self.moedasServerList = nomesSiglas as! [Moeda]
            
            self.moedasList = self.moedasServerList
                    
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        } onError: { (cambioError) in
            print(cambioError)
        }
        
        print("carregou do servidor da api AGORA!")
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
    
    
    func fecharView(){
        navigationController?.popViewController(animated: true)
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
//        print(sigla)
        
        if self.buttonSelect == 1 {
            UserDefaults.standard.set("\(sigla)-\(nome)" , forKey: "nomeOrig")
            UserDefaults.standard.set(sigla , forKey: "siglaOrig")
        }else{
            UserDefaults.standard.set("\(sigla)-\(nome)"  , forKey: "nomeDest")
            UserDefaults.standard.set(sigla , forKey: "siglaDest")
        }
        fecharView()
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
