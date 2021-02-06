//
//  ViewController.swift
//  conversorDeMoeda
//
//  Created by Diogenes de Souza on 07/01/21.
//

import UIKit

class ViewController: UIViewController{
    
    let formatter = NumberFormatter()
    var botaoSelecionado = 0
    var cambioValorList: Dictionary<String,Double> = [:]
    var textOrig:String = ""
    var textDest:String = ""
    var siglaOrig:String = ""
    var siglaDest:String = ""
    
    
    @IBOutlet weak var buttonOrig: UIButton!
    @IBOutlet weak var buttonDest: UIButton!
    @IBOutlet weak var display: UITextField!
    @IBOutlet weak var labelResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .currency
        formatter.alwaysShowsDecimalSeparator = true
        
        if let myData = UserDefaults.standard.value(forKey: "listaDeCotacao") as? Data {
            self.cambioValorList = try! PropertyListDecoder().decode(Dictionary<String, Double>.self, from: myData)
            
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Pega a lista de moedas com suas cotações no servidor
        Rest.loadCurrencys(endPoint: "live") { (nomesSiglas, siglasValues) in
            self.cambioValorList = siglasValues!
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.cambioValorList) , forKey: "listaDeCotacao")
            
        } onError: { (cambioError) in
            print(cambioError)
            print("Erro de internet")
        }
        // MARK: EXIBE RESULTADO SOMENTE SE O VALOR ESTIVERER PREENCHIDO E AS MOEDAS ESCOLHIDAS
        if !cambioValorList.isEmpty && !siglaOrig.isEmpty && !siglaDest.isEmpty {
            labelResult.text = getValorDolar(textOrig: siglaOrig, textDest: siglaDest, valor: display.text!)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: fechar teclado ao tocar na view
    @IBAction func closeKeyboard(_ sender: Any) {
        labelResult.text = getValorDolar(textOrig: siglaOrig, textDest: siglaDest, valor: display.text!)
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
    
    func applyTextButton(moedaEscolhida: Moeda){
        
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

    
    func moedaSelected(moedaSelecionada: Moeda) {
  
        
        applyTextButton(moedaEscolhida: moedaSelecionada)
    }
}

