//
//  Rest.swift
//  conversorDeMoeda
//
//  Created by Diogenes de Souza on 08/01/21.
//

import Foundation
import CoreData
import UIKit


enum cambioError {
    case url
    case takError(error: Error)
    case noResponse
}

var contexto: NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}

// MARK: classe responsável por fazer a requisição no servidor
class Rest {
    private static let basePhath = "http://api.currencylayer.com/"
    private static let acesskey = "?access_key=62ac3fd83ede8cb37b1591c7d1635ae4" // MARK: chave da api
    private static var fullUrl: URL?
    
    private static let configuration : URLSessionConfiguration = {
        
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.httpAdditionalHeaders = ["Content-type" : "aplicattion/json"]
        config.timeoutIntervalForRequest = 40.0
        config.httpMaximumConnectionsPerHost = 6
        return config
    }()
    
    
    // MARK: Carrega a lista de moedas com nome e siglas correspondentes (String:String)
    class func loadCurrencys(endPoint: String, onClomplete: @escaping([Any]?, Dictionary<String,Double>?) -> Void, onError: @escaping(cambioError) -> Void){
        
        fullUrl = URL(string: basePhath + endPoint + acesskey)
        guard let url = fullUrl else {
            onError(.url)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
            if error == nil{
                guard let response = response as? HTTPURLResponse else{
                    onError(.noResponse)
                    return
                }
                
                // MARK: se houve sucesso na resposta código 200
                if response.statusCode == 200 {
                    guard let data = data else{return}
                    
                    do{
                        // MARK: decodificar JSON
                        if endPoint == "list" {
                            let cambioList: Cambio = try JSONDecoder().decode(Cambio.self, from: data)
                            let arrayDeMoedas: Dictionary = cambioList.currencies
                            
                            var currencyList:[Currency] = []
                            
                            for item in arrayDeMoedas {
                                let currency = Currency(context: contexto)
                                currency.nome = item.value
                                currency.sigla = item.key
                                currencyList.append(currency)
                            }
                            
                            do {
                                try contexto.save()
                            } catch  {
                                print(error.localizedDescription)
                            }
                            
                            // MARK: Ordena a lista por nome em ordem crescente
                            currencyList.sort {
                                $0.nome! < $1.nome!
                            }
                            onClomplete(currencyList, nil)
                        }else{
                            let cambioList: Cotacao = try JSONDecoder().decode(Cotacao.self, from: data)
                            let arrayDeMoedas = cambioList.quotes
                            onClomplete(nil, arrayDeMoedas)
                        }
                        
                    }catch{
                        print(error.localizedDescription)
                        
                    }
                    
                }else{
                    print("Algum status inválido no servidor")
                }
            }else{
                onError(.takError(error: error!))
            }
            
        }
        dataTask.resume()
    }
}


