//
//  ThirdViewController.swift
//  MyETHWalletApp
//
//  Created by Yuta Fujii on 2022/04/06.
//

import UIKit
import web3swift
import BigInt

class ThirdViewController: UIViewController {

    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var ballanceLabel: UILabel!
    
    var wallet:Wallet?
    var keystoreManager: KeystoreManager?
    let web3 = Web3.InfuraRopstenWeb3() // Ropsten Infura Endpoint Provider
    var token:ERC20Token?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func createWallet(_ sender: Any) {
        let password = "web3swift" // We recommend here and everywhere to use the password set by the user.
        let keystore = try! EthereumKeystoreV3(password: password)!
        let name = "New Wallet"
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
        print(wallet!)
        walletLabel.text = wallet!.address
    }
    
    
    
    @IBAction func importAccount(_ sender: Any) {
        let password = "09270705Aab"
        let mnemonics = "ginger inhale outer damp seminar enhance solar heavy tower primary useful gaze" // Some mnemonic phrase
        let keystore = try! BIP32Keystore(
            mnemonics: mnemonics,
            password: password,
            mnemonicsPassword: "",
            language: .english)!
        let name = "MetaMask My Wallet"
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        wallet = Wallet(address: address, data: keyData, name: name, isHD: true)
        print(wallet!.address)
        print(wallet!.data.debugDescription)
        //0x183109C3Cd833E5B473a0Df12f47d4cc457cAA92
        let data = wallet!.data
        if wallet!.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        
        
    }
    
    
    
    @IBAction func getBallance(_ sender: Any) {
//        let endpoint = "https://data-seed-prebsc-1-s1.binance.org:8545/"
//        let web3 = web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
        //Ropstenとはテストネットワークのこと
        //Ropstenとは Ethereumの主要なテストネットの一つ。 JSON-RPCのサーバはinfura ( https://infura.io/ ) を使うことが一般的
        let web3 = Web3.InfuraRopstenWeb3() // Ropsten Infura Endpoint Provider

        //https://data-seed-prebsc-1-s1.binance.org:8545/
        let walletAddress = EthereumAddress(wallet!.address)! // Address which balance we want to know
        let balanceResult = try! web3.eth.getBalance(address: walletAddress)
        let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
        print(balanceString)
//        web3.addKeystoreManager(keystoreManager)
        
    }
    
    
    @IBAction func getETHBallance(_ sender: Any) {
        let walletAddress = EthereumAddress(wallet!.address)! // Address which balance we want to know
        let balanceResult = try! web3.eth.getBalance(address: walletAddress)
        let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
        print(balanceString)

    }
    
    @IBAction func getERC20Token(_ sender: Any) {
        let walletAddress = EthereumAddress(wallet!.address)! // Your wallet address
        let exploredAddress = EthereumAddress(wallet!.address)! // Address which balance we want to know. Here we used same wallet address
        let erc20ContractAddress = EthereumAddress(token!.address)!
        let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
        var options = TransactionOptions.defaultOptions
        options.from = walletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        let method = "balanceOf"
        let tx = contract.read(
            method,
            parameters: [exploredAddress] as [AnyObject],
            extraData: Data(),
            transactionOptions: options)!
        let tokenBalance = try! tx.call()
        let balanceBigUInt = tokenBalance["0"] as! BigUInt
        print(balanceBigUInt)
        let balanceString2 = Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 3)!
        print(balanceString2)
    
    }
    
    
}
