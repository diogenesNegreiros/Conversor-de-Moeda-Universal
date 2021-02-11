//
//  ViewController.swift
//  conversorDeMoeda
//
//  Created by Diogenes de Souza on 07/01/21.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    var fetchedResultsController : NSFetchedResultsController<Cota>!
    
    let formatter = NumberFormatter()
    private var botaoSelecionado = 0
    private var cambioValorList: Dictionary<String,Double> = [:]
    private var textOrig:String = ""
    private var textDest:String = ""
    private var siglaOrig:String = ""
    private var siglaDest:String = ""
    
    @IBOutlet weak var buttonOrig: UIButton!
    @IBOutlet weak var buttonDest: UIButton!
    @IBOutlet weak var display: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .currency
        formatter.alwaysShowsDecimalSeparator = true
        
        recuperarMoedaDoBanco()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Pega a lista de moedas com suas cotações no servidor
        Rest.loadCurrencys(endPoint: "live") { (nomesSiglas, siglasValues) in
            self.cambioValorList = siglasValues!
            self.addCotaMoedaNoBanco()
            
        } onError: { (cambioError) in
            print(cambioError)
            print("Erro de internet")
            
        }
        // MARK: EXIBE RESULTADO SOMENTE SE O VALOR ESTIVERER PREENCHIDO E AS MOEDAS ESCOLHIDAS
        if !cambioValorList.isEmpty && !siglaOrig.isEmpty && !siglaDest.isEmpty {
            labelResult.text = getValorDolar(textOrig: siglaOrig, textDest: siglaDest, valor: display.text!)
        }
    }
    
    func addCotaMoedaNoBanco(){
        
        for item in cambioValorList {
            let cota: Cota = Cota(context: context)
            cota.key = item.key
            cota.value = item.value
        }
        do {
            try context.save()
        } catch  {
            print(error.localizedDescription)
        }
        
    }
    
    func recuperarMoedaDoBanco(){
        
        let fetchRequest: NSFetchRequest<Cota> = Cota.fetchRequest()
        let sortDescritor = NSSortDescriptor(key: "key", ascending: true)
        fetchRequest.sortDescriptors = [sortDescritor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        //        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            let arrayDeCotas = fetchedResultsController.fetchedObjects ?? []
            
            var dictCotas: Dictionary<String, Double> = [:]
            for item in arrayDeCotas {
                dictCotas[item.key!] = item.value
            }
            
            cambioValorList = dictCotas
            
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: fechar teclado ao tocar na view
    @IBAction func closeKeyboard(_ sender: Any) {
        
        if !cambioValorList.isEmpty && !siglaOrig.isEmpty && !siglaDest.isEmpty {
            labelResult.text = getValorDolar(textOrig: siglaOrig, textDest: siglaDest, valor: display.text!)
        }
        self.view.endEditing(true)
    }
    
    // MARK: ação do primeiro botão
    @IBAction func actionOrig(_ sender: Any) {
        botaoSelecionado = 0
        let controle = storyboard?.instantiateViewController(identifier: "MoedasTableViewController") as! MoedasTableViewController
        controle.delegado = self
        navigationController?.pushViewController(controle, animated: true)
    }
    
    
    // MARK: ação do segundo botão
    @IBAction func actionDest(_ sender: UIButton) {
        botaoSelecionado = 1
        
        let controle = storyboard?.instantiateViewController(identifier: "MoedasTableViewController") as! MoedasTableViewController
        controle.delegado = self
        navigationController?.pushViewController(controle, animated: true)
        
    }
    // MARK: Atualiza o resultado ao digitar no campo de textField
    @IBAction func updateResult(_ sender: Any) {
        
        if !siglaOrig.isEmpty &&  !siglaDest.isEmpty{
            labelResult.text = getValorDolar(textOrig: siglaOrig, textDest: siglaDest, valor: display.text!)
        }
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func applyTextButton(moedaEscolhida: Currency){
        
        let nome = String(moedaEscolhida.nome!)
        let sigla = String(moedaEscolhida.sigla!)
        
        if botaoSelecionado == 0{
            buttonOrig.setTitle("\(nome) - \(sigla)", for: .normal)
            textOrig = nome
            siglaOrig = sigla
        }else{
            buttonDest.setTitle("\(nome) - \(sigla)", for: .normal)
            textDest = nome
            siglaDest = sigla
        }
    }
    
    //MARK: Texto digitado para formato de moeda
    func getValorFormatado(valor: Double, moedaCode: String) -> String{
        
        formatter.currencySymbol = moedaCode
        formatter.currencyCode = moedaCode
        return formatter.string(for: valor) ?? ""
    }
    
    // MARK: faz a conversão da moeda
    func getValorDolar(textOrig:String, textDest:String, valor:String) -> String{
        
        let valorNovo = valor.replacingOccurrences(of: ",", with: ".")
        var resultado:Double = 0
        let cotacao1:Double = cambioValorList["USD" + textOrig] ?? 1
        let cotacao2:Double = cambioValorList["USD" + textDest] ?? 1
        
        print("valor em cotaçao 1:\(cotacao1)")
        print("valor em cotacao 2:\(cotacao2)")
        
        // MARK: fórmula da conversão :  x= (valor digitado / indice1) * ídice2
        if let valordigitado = Double(valorNovo){
            print("Converteu valor digitado:\(valordigitado)")
            
            let valorEmDolar = valordigitado/cotacao1
            print("valor em dolar: \(valorEmDolar)")
            resultado = valorEmDolar * cotacao2
            print("valor em Destino: \(resultado)")
        }
        
        let resultString = getValorFormatado(valor: resultado, moedaCode: textDest)
        return resultString
    }
}

extension ViewController: MoedasTableViewControllerDelegate{
    func moedaSelected(moedaSelecionada: Currency) {
        applyTextButton(moedaEscolhida: moedaSelecionada)
    }
}

