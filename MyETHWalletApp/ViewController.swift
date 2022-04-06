//
//  ViewController.swift
//  MyETHWalletApp
//
//  Created by Yuta Fujii on 2022/04/06.
//

import UIKit
import web3swift

class ViewController: UIViewController {

    var fromAddress = String()
    var balanceString = String()
    var password = "1234567890"
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ballanceLabel: UILabel!
    
    var toAddressString:String = "0x183109C3Cd833E5B473a0Df12f47d4cc457cAA92"
    
    var web3 = Web3.InfuraMainnetWeb3()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("現在の状況")
        print("アカウント: ", fromAddress)
        print("残高: ",balanceString)

    }
    
    
    
    
    @IBAction func createWallet(_ sender: Any) {
        //ファイル名生成
        let generationFileName = "WalletAccount"
        // keystore ファイルを保存するディレクトリのパスを取得
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore", scanForHDwallets: true)

        // パスワードを使用する
//        let password = "1234567890"
        //KeyStoreの生成ファイルを作成
        let keystore = try! EthereumKeystoreV3(password: password)!
        //生成ファイルをエンコード
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        //アドレス取得
        fromAddress = keystore.addresses!.first!.address
        //ファイル書き込み処理
        FileManager.default.createFile(atPath: userDir + "/keystore"+"/\(generationFileName).json", contents: keyData, attributes: nil)
                keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore", scanForHDwallets: true)
        print("アカウント：\(fromAddress)")
    }
    
    @IBAction func sendEth(_ sender: Any) {
    
        let value: String = "1.0" // In Ether
        print("My Wallet Address is ",fromAddress)
        let walletAddress = EthereumAddress(fromAddress)! // Your wallet address
        let toAddress = EthereumAddress(toAddressString)!
        let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress)
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = TransactionOptions.defaultOptions
        options.value = amount
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
     
        let transaction = contract!.write(
        "fallback",
        parameters: [AnyObject](),
        extraData: Data(),
        transactionOptions: options)!
        
        do{
            //実際に送信
            let result = try! transaction.send(password: password)
            print("成功")
            
        }catch{
                print("エラー:\(error)")
                
                return
            }
        }
        
    
    @IBAction func checkMyAddress(_ sender: Any) {
        
        addressLabel.text = fromAddress
        
    }
   
    @IBAction func getBallance(_ sender: Any) {
        let web3 = Web3.InfuraMainnetWeb3()
        let address = EthereumAddress(fromAddress)!
        let balance = try! web3.eth.getBalance(address: address)
        let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 3)
        ballanceLabel.text = balanceString
        print("残高: ",balanceString as Any)
    
    }
    
    
    @IBAction func sendERC20Token(_ sender: Any) {
//        let web3 = Web3.InfuraMainnetWeb3()
//        let value: String = "1.0" // In Tokens
//        let walletAddress = EthereumAddress(fromAddress)! // Your wallet address
//        let toAddress = EthereumAddress(toAddressString)!
//        let erc20ContractAddress = EthereumAddress(address)!
//        let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
////        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
//        var options = TransactionOptions.defaultOptions
////        options.value = amount
//        options.from = walletAddress
//        options.gasPrice = .automatic
//        options.gasLimit = .automatic
//        let method = "transfer"
//        let tx = contract.write(
//            method,
//            parameters: [toAddress] as [AnyObject],
//            extraData: Data(),
//            transactionOptions: options)!

    }
    


}

