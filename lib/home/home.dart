import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pkcoin/widgets/slider_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Client httpClient;
  Web3Client ethClient;
  bool data;
  int myAmount = 0;
  final myAddress = '0x4746C0E4338bF5b1965d1bd7cd7Aba096cbe0140';
  var myData;
  String txHash;
  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
      'https://rinkeby.infura.io/v3/e89725fe26d1404ea9fd7ad1512167ce',
      httpClient,
    );

    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    final String abi = await rootBundle.loadString('assets/abi.json');
    final String contractAddress = "0x7133D5D682feBff562318AB9A5Be2bE3f7DAECbc";
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, 'PKCoin'),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<dynamic> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    final List<dynamic> result = await query('getBalance', []);
    myData = result?.first;
    data = true;
    print(result);
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
      '4bbf21d63e634eb3029b18c28563758e757778d060c913d60f7661cde19e11d1',
    );
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.signTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
      fetchChainIdFromNetworkId: true,
    );
    return result.first.toString();
  }

  Future<String> sendCoin() async {
    final bigAmount = BigInt.from(myAmount);
    final response = await submit(
      'depositBalance',
      [bigAmount],
    );
    print('Deposited');
    txHash = response;
    setState(() {});
    return response;
  }

  Future<String> withdrawCoin() async {
    final bigAmount = BigInt.from(myAmount);
    final response = await submit(
      'withdrawBalance',
      [bigAmount],
    );
    print('Withdrawn');
    txHash = response;
    setState(() {});
    return response;
  }

  Widget _buildContentVx() {
    return ZStack([
      VxBox()
          .blue600
          .size(context.screenWidth, context.percentHeight * 30)
          .make(),
      VStack([
        (context.percentHeight * 10).heightBox,
        "\$PKCoin".text.xl4.white.bold.center.makeCentered().py16(),
        (context.percentHeight * 5).heightBox,
        VxBox(
          child: VStack(
            [
              "Balance".text.gray700.xl2.semiBold.makeCentered(),
              10.heightBox,
              data != null && data
                  ? "\$$myData".text.bold.xl6.makeCentered().shimmer()
                  : CircularProgressIndicator().centered()
            ],
          ).p16(),
        )
            .white
            .size(context.screenWidth, context.percentHeight * 30)
            .rounded
            .shadow2xl
            .make()
            .p16(),
        30.heightBox,
        SliderWidget(
          min: 0,
          max: 100,
          finalVal: (val) {
            myAmount = (val * 100).round();
            // setState(() {});
            print(myAmount);
          },
        ).centered(),
        HStack(
          [
            FlatButton.icon(
              onPressed: () => getBalance(myAddress),
              label: 'Refresh'.text.white.make(),
              shape: Vx.roundedSm,
              color: Colors.blue,
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ).h(50),
            FlatButton.icon(
              onPressed: () => sendCoin(),
              label: 'Deposit'.text.white.make(),
              shape: Vx.roundedSm,
              color: Colors.green,
              icon: Icon(
                Icons.call_made_outlined,
                color: Colors.white,
              ),
            ).h(50),
            FlatButton.icon(
              onPressed: () => withdrawCoin(),
              label: 'Withdraw'.text.white.make(),
              shape: Vx.roundedSm,
              color: Colors.red,
              icon: Icon(
                Icons.call_received_outlined,
                color: Colors.white,
              ),
            ).h(50),
          ],
          alignment: MainAxisAlignment.spaceAround,
          axisSize: MainAxisSize.max,
        ).p16(),
        if (txHash != null) txHash.text.black.makeCentered().p16(),
      ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: _buildContentVx(),
    );
  }
}
