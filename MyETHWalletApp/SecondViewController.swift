//
//  SecondViewController.swift
//  MyETHWalletApp
//
//  Created by Yuta Fujii on 2022/04/06.
//

import UIKit
import web3swift
//import BigUInt

class SecondViewController: UIViewController {

    var fromAddress = String()
    var balanceString = String()
    var password = "1234567890"
    var web3 = Web3.InfuraMainnetWeb3()

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ballanceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func createAC(_ sender: Any) {

        do {
            try createAccount(name: "wallet123")
        }catch{
            print("エラー")
            return
        }
        
        
    }
    
    
    @IBAction func showBallance(_ sender: Any) {
        
    }
    
    func createAccount(name: String) throws -> Web3Wallet {
     
        var bitsOfEntropy = 18979170348709
        guard let mnemonicsString = try BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy) else {
            throw Web3ServiceError.noMnemonics
            
        }
        
        guard let keystore = try BIP32Keystore(mnemonics: mnemonicsString, password: password, mnemonicsPassword: "", language: .english)else {
            throw Web3ServiceError.noKeyStore
            
        }
        
        guard let address = keystore.addresses?.first?.address else {
            throw Web3ServiceError.noAddress
            
        }
        let keyData = try JSONEncoder().encode(keystore.keystoreParams)
        let mnemonics = mnemonicsString.split(separator: " ").map(String.init)
        
        return Web3Wallet(address: address, data: keyData, name: name, type: .hd(mnemonics: mnemonics))
    }
    
    func importAccount(by privateKey: String, name: String) throws -> Web3Wallet {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let dataKey = Data.fromHex(formattedKey), let keystore = try EthereumKeystoreV3(privateKey: dataKey, password: password) else {
            throw Web3ServiceError.noKeyStore
            
        }
        
        guard let address = keystore.addresses?.first?.address else {
            throw Web3ServiceError.noAddress
            
        }
        
        let keyData = try JSONEncoder().encode(keystore.keystoreParams)
        
        return Web3Wallet(address: address, data: keyData, name: name, type: .normal)
    }


    func exportAccount(wallet: Web3Wallet) throws -> ExportedType {
        
        let keyStoreManager = try fetchKeyStoreManager(wallet: wallet)
        
        guard let ethereumAddress = EthereumAddress(wallet.address) else {
            
            throw Web3ServiceError.noAddress
            
        }
        
        let key = try keyStoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
       
        switch wallet.type {
            case .normal: return .privateKey(key: key)
            case .hd(let mnemonics): return .mnemonics(mnemonics: mnemonics, key: key)
        }
    }
    
    func fetchKeyStoreManager(wallet: Web3Wallet) throws -> KeystoreManager {
        switch wallet.type {
        case .normal:
            guard let keystore = EthereumKeystoreV3(wallet.data) else { throw Web3ServiceError.noKeyStore }
            return KeystoreManager([keystore])
        case .hd:
            guard let keystore = BIP32Keystore(wallet.data) else { throw Web3ServiceError.noKeyStore }
            return KeystoreManager([keystore])
        }
    }
    
    func getETHBalance(wallet: Web3Wallet) throws -> String? {
        guard let walletAddress = EthereumAddress(wallet.address) else {
            throw Web3ServiceError.noAddress
        }
        web3.addKeystoreManager(try fetchKeyStoreManager(wallet: wallet))
        let balance = try web3.eth.getBalance(address: walletAddress)
        return Web3.Utils.formatToEthereumUnits(
            balance,
            toUnits: .eth,
            decimals: 3
        )
    }
//
//    func getERC20Balance(
//        wallet: Web3Wallet,
//        token: ERC20Token
//    ) throws -> String? {
//        guard let walletAddress = EthereumAddress(wallet.address),
//              let erc20ContractAddress = EthereumAddress(token.address, ignoreChecksum: true) else {
//            throw Web3ServiceError.noAddress
//        }
//        guard let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2) else {
//            throw Web3ServiceError.noContract
//        }
//        web3.addKeystoreManager(try fetchKeyStoreManager(wallet: wallet))
//        var options = TransactionOptions.defaultOptions
//        options.from = walletAddress
//        options.gasPrice = .automatic
//        options.gasLimit = .automatic
//        let tx = contract.read(
//            TxMethod.balanceOf.rawValue,
//            parameters: [walletAddress] as [AnyObject],
//            extraData: Data(),
//            transactionOptions: options
//        )
//        let tokenBalance = try tx?.call()
//
//        guard let balanceBigUInt = tokenBalance?["0"] as? BigUInt else {
//            throw Web3ServiceError.noBalance
//        }
//        return Web3.Utils.formatToEthereumUnits(
//            balanceBigUInt,
//            toUnits: .eth,
//            decimals: 3
//        )
//    }
}
