// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.8.1;
pragma experimental ABIEncoderV2;

import "./Assets.sol";
import "./SalesOrder.sol";
import "./Utils.sol";
import "./AssetsHistory.sol";
import "./SalesOrderHistory.sol";

contract Market
{
    //Atributos
    bytes32 private KeySystem;
    address payable AddrSystem;
    Utils private Util;

    uint private IndexAssets;
    Asset[] private Assets;
    
    uint private IndexAssetsHistory;
    AssetsHistory[] private AssetHistory;

    uint private IndexSalesOrder;
    SaleOrder[] private SalesOrder;

    uint private IndexSalesOrderHistory;
    SalesOrderHistory[] private SaleOrderHistory;
    
    uint private IndexBlackList;
    address payable[] private BlackList;
    
    
//===========================================================================================================================================================    


    //Metodos do Sistema
    constructor(string memory _keysystem, address payable _addrsys) public ValidationConstruct()
    {
        KeySystem = keccak256(abi.encodePacked(_keysystem));
        AddrSystem = _addrsys;
    }
    function Updatekey(string memory _keysystem, string memory _nkeysystem) public ValidationSystem(_keysystem)
    returns(bool)
    {
        KeySystem = keccak256(abi.encodePacked(_nkeysystem));
        return true;
    }
    function ValidationProfits(string memory _keysystem) public ValidationProfit(_keysystem)
    returns(bool)
    {
        AssetsHistory AH;
        for(uint i = 0; IndexAssets > i; i++)
        {
            AH = GetAssetLastHistory(_keysystem, i);
            if(!AH.GetIsValidation())
            {
                if(AH.GetIsPayment())
                {
                    AssetHistory[IndexAssetsHistory] = Util.CreateAssetHistory(Assets[i], 0, 0, 4, i);
                    IndexAssetsHistory++;
                }
                else
                {
                    BlackList[IndexBlackList] = Assets[i].GetOwner();
                    IndexBlackList++;
                    Assets[i].Finalize();
                    AssetHistory[IndexAssetsHistory] = Util.CreateAssetHistory(Assets[i], 0, 0, 2, i);
                    IndexAssetsHistory++;
                }
            }
        }
        return true;
    }


//===========================================================================================================================================================    

    
    //Metodos de ativos Próprios
    function CreateMyAsset(string memory _keysystem, string memory _nome, string memory _cod, uint _ativos, uint _payprofitpreview) public ValidationCreateAssets(_keysystem)
    returns(bool)
    {
        Assets[IndexAssets] = new Asset(_nome, _cod, _ativos, _payprofitpreview);        
        AssetHistory[IndexAssetsHistory] = Util.CreateAssetHistory(Assets[IndexAssets], 0, 0, 1, IndexAssets);
        IndexAssetsHistory++;
        IndexAssets++;
        return true;
    }
    function DestroyMyAssetsCreate(string memory _keysystem) public ValidationDestroyAssets(_keysystem)
    returns(bool Res)
    {
        uint Tax;
        bool flag;
        for(uint i = 0; IndexAssets > i; i++)
        {
            if(Assets[i].IsOwner(msg.sender))
            {
                Tax = uint(Assets[i].GetPayProfitPreview() * 1/100);
                AssetHistory[IndexAssetsHistory] = Util.CreateAssetHistory(Assets[i], 0, 0, 2, i);
                IndexAssetsHistory++;
                for(uint x = 0; Assets[i].GetTotalAtivos() > x; x++)
                {
                    if(Assets[i].GetProprietarios()[i] != msg.sender)
                        flag = true;
                }
                Assets[i].Finalize();
                Res = true;
            }
        }
        (Assets, IndexAssets) = Util.ReorderAssets(Assets, IndexAssets);
        if(flag)
        {
            AddrSystem.transfer(Tax);
            BlackList[IndexBlackList] = msg.sender;
            IndexBlackList++;
        }        
    }
    function DestroyMyAssetCreate(string memory _keysystem, uint _asset) public ValidationDestroyAssets(_keysystem)
    returns(bool Res)
    {
        uint Tax;
        bool flag;
        for(uint x = 0; Assets[_asset].GetTotalAtivos() > x; x++)
        {
            if(Assets[_asset].GetProprietarios()[x] != msg.sender)
                flag = true;
        }
        if(flag)
        {
            for(uint i = 0; IndexAssets > i; i++)
            {
                if(Assets[i].IsOwner(msg.sender))
                {
                    Tax = uint(Assets[i].GetPayProfitPreview() * 1/100);
                    AssetHistory[IndexAssetsHistory] = Util.CreateAssetHistory(Assets[i], 0, 0, 2, i);
                    IndexAssetsHistory++;
                    for(uint x = 0; Assets[i].GetTotalAtivos() > x; x++)
                    {
                        if(Assets[i].GetProprietarios()[x] != msg.sender)
                            flag = true;
                    }
                    Assets[i].Finalize();
                    Res = true;
                }
            }
            (Assets, IndexAssets) = Util.ReorderAssets(Assets, IndexAssets);
            AddrSystem.transfer(Tax);
            BlackList[IndexBlackList] = msg.sender;
            IndexBlackList++;
        }
        if(Assets[_asset].IsOwner(msg.sender))
        {
            Tax = uint(Assets[_asset].GetPayProfitPreview() * 1/100);
            AssetHistory[IndexAssetsHistory] = Util.CreateAssetHistory(Assets[_asset], 0, 0, 2, _asset);
            IndexAssetsHistory++;            
            Assets[_asset].Finalize();
            Res = true;
        }
        (Assets, IndexAssets) = Util.ReorderAssets(Assets, IndexAssets);                
    }
    function PayProfit(string memory _keysystem) public ValidationPayProfit(_keysystem)
    returns(bool) 
    {
        (Asset[] memory SAO, uint Ind_SAO) = Util.SelectAssetsByOwner(Assets, IndexAssets);
        if(Util.CheckAssetPayProfitPrice(SAO, Ind_SAO))
        {
            (uint totalpay, uint pay, uint[] memory asset, uint ind_asset) = Util.PreparePayProfit(Assets, SAO, IndexAssets, Ind_SAO);
            for(uint x = 0; ind_asset > x; x++)
            {
                AssetHistory[IndexAssetsHistory] = Util.CreateAssetHistory(Assets[asset[x]],totalpay, pay, 3, asset[x]);
                IndexAssetsHistory++;
            }
        }
        else
        {
            AddrSystem.transfer(msg.sender.balance - tx.gasprice);
            BlackList[IndexBlackList] = msg.sender;
            IndexBlackList++;
        }
        return true;
    }
    function UpdatePayProfitPreview(string memory _keysystem, uint _asset, uint _npayprofitpreview) public ValidationPayProfit(_keysystem)
    returns(bool)
    {
        if(Assets[_asset].IsOwner(msg.sender) && Assets[_asset].GetValidationProfit())
        {
            Assets[_asset].NewPayProfitPreview(_npayprofitpreview);
            return true;
        }
        return false;
    }
    function NewTotalAssets(string memory _keysystem, uint _asset, uint _nassets) public ValidationPayProfit(_keysystem)
    returns(bool)
    {
        if(Assets[_asset].IsOwner(msg.sender) && Assets[_asset].GetValidationProfit() && _nassets > Assets[_asset].GetTotalAtivos())
        {
            Assets[_asset].NewTotalAssets(_nassets);
            return true;
        }
        return false;
    }

//Metodos de transação
    function GiveAsset(string memory _keysystem, uint _value, uint _asset, address payable _to) public ValidationDispatch(_keysystem, _value, _asset)
    returns(bool)
    {
        return Assets[_asset].TrasferBalance(msg.sender, _to, _value);
    }
    function SellAssets(string memory _keysystem, uint _value, uint _asset, uint _price) public ValidationDispatch(_keysystem, _value, _asset)
    returns(bool)
    {
        SalesOrder[IndexSalesOrder] = new SaleOrder(msg.sender, _value, _price, _asset);
        IndexSalesOrder++;
        (SalesOrder, IndexSalesOrder) = Util.ReorderSalesOrder(SalesOrder, IndexSalesOrder);
        SaleOrderHistory[IndexSalesOrderHistory] = new SalesOrderHistory(_asset, _value,_price, true, false);
        IndexSalesOrderHistory++;
        return true;
    }
    function BuyAssets(string memory _keysystem, uint _value, uint _asset) public ValidationPurchase(_keysystem, _value, _asset)
    returns(bool)
    {
        uint totprice;
        (uint Ind_Seller, address payable[] memory Seller, uint[] memory Price,uint[] memory Value, uint Tax) = Util.ProcessSalesOrder(SalesOrder, IndexSalesOrder, _value, _asset);
        for(uint i = 0; Ind_Seller > i; i++)
        {
            totprice += Price[i];
            Seller[i].transfer(Price[i]);
            Assets[_asset].TrasferBalance(Seller[i], msg.sender, Value[i]);
        }
        AddrSystem.transfer(Tax);
        (SalesOrder, IndexSalesOrder) = Util.ReorderSalesOrder(SalesOrder, IndexSalesOrder);
        SaleOrderHistory[IndexSalesOrderHistory] = new SalesOrderHistory(_asset, _value, totprice, false, true);
        IndexSalesOrderHistory++;
        return true;
    }

//------------------------------------------------------    
    
    //Metodos de visualização
    function GetAssets(string memory _keysystem) public view ValidationSystem(_keysystem)
    returns(string[] memory Name, string[] memory Code, uint[] memory TotalAssets, uint[] memory PayProfitPreview, uint[] memory Day, uint[] memory Month, uint[] memory Year, uint[] memory LastPayProfit)
    {
        for(uint i = 0; IndexAssets > i; i++)
        {
            (Name[i], Code[i], TotalAssets[i], PayProfitPreview[i], LastPayProfit[i]) = Assets[i].GetAsset();
            (Day[i], Month[i], Year[i]) = Util.GetAssetCreateDatefromHistory(AssetHistory, IndexAssetsHistory, i);
        }
    }

    function GetAssetByAsset(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(string memory Name, string memory Code, uint TotalAssets, uint PayProfitPreview, uint Day, uint Month, uint Year, uint LastPayProfit)
    {
        (Name, Code, TotalAssets, PayProfitPreview, LastPayProfit) = Assets[_asset].GetAsset();
        (Day, Month, Year) = Util.GetAssetCreateDatefromHistory(AssetHistory, IndexAssetsHistory, _asset);
    }  

    function GetMyAssets(string memory _keysystem) public view ValidationSystem(_keysystem)
    returns(string[] memory Name, string[] memory Code, uint[] memory TotalAssets, uint[] memory PayProfitPreview, uint[] memory Day, uint[] memory Month, uint[] memory Year, uint[] memory LastPayProfit, uint[] memory Balances)
    {
        (uint[] memory SSA, uint ind_SSA) = Util.SelectAssetsByAddress(Assets, IndexAssets, msg.sender);
        for(uint i = 0; ind_SSA > i; i++)
        {
            (Name[i], Code[i], TotalAssets[i], PayProfitPreview[i], LastPayProfit[i], Balances[i]) = Assets[SSA[i]].GetAssetProperty(msg.sender);
            (Day[i], Month[i], Year[i]) = Util.GetAssetCreateDatefromHistory(AssetHistory, IndexAssetsHistory, SSA[i]);
        }
            
    }

    function GetMyCreateAssets(string memory _keysystem) public view ValidationSystem(_keysystem)
    returns(string memory Name, string memory Code, uint TotalAssets, uint PayProfitPreview, uint NTotalAssets, uint NPayProfitPreview, uint LastPayProfit, uint Balances)
    {
        (Asset[] memory SAO, uint ind_SAO) = Util.SelectAssetsByOwner(Assets, IndexAssets);
        for(uint i = 0; ind_SAO > i; i++)
            (Name, Code, TotalAssets, PayProfitPreview,NTotalAssets, NPayProfitPreview, LastPayProfit, Balances) = SAO[i].GetAssetOwner();
    }

    function GetAssetsForSale(string memory _keysystem) public view ValidationSystem(_keysystem)
    returns(uint[] memory Value, uint[] memory Price, uint[] memory Tax, uint[] memory TotalPrice, string[] memory AssetName, string[] memory AssetCode, uint[] memory PayProfitPreview)
    {
        uint asset;
        uint a;
        uint b;

        for(uint i = 0; IndexSalesOrder > i; i++)
        {
            (Value[i], Price[i], Tax[i], TotalPrice[i], asset) = SalesOrder[i].GetOrdem();
            (AssetName[i], AssetCode[i], a, PayProfitPreview[i], b) = Assets[asset].GetAsset();
        }
    }

    function GetAssetsForSaleByAsset(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(uint[] memory Value, uint[] memory Price, uint[] memory Tax, uint[] memory TotalPrice, string[] memory AssetName, string[] memory AssetCode, uint[] memory PayProfitPreview)
    {
        uint asset;
        uint a;
        uint b;

        for(uint i = 0; IndexSalesOrder > i; i++)
        {
            if(SalesOrder[i].GetAtivo() == _asset)
            {
                (Value[i], Price[i], Tax[i], TotalPrice[i], asset) = SalesOrder[i].GetOrdem();
                (AssetName[i], AssetCode[i], a, PayProfitPreview[i], b) = Assets[asset].GetAsset();
            }
        }
    }

    function GetMyAssetsForSale(string memory _keysystem) public view ValidationSystem(_keysystem)
    returns(uint[] memory Value, uint[] memory Price, uint[] memory Tax, uint[] memory TotalPrice, string[] memory AssetName, string[] memory AssetCode, uint[] memory PayProfitPreview)
    {
        uint asset;
        uint a;
        uint b;

        for(uint i = 0; IndexSalesOrder > i; i++)
        {
            if(SalesOrder[i].GetVendedor() == msg.sender)
            {
                (Value[i], Price[i], Tax[i], TotalPrice[i], asset) = SalesOrder[i].GetOrdem();
                (AssetName[i], AssetCode[i], a, PayProfitPreview[i], b) = Assets[asset].GetAsset();
            }
        }
    }

    //Metodos de Histórico de ativos
    function GetAssetTotalHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(AssetsHistory[] memory AH, uint Ind_AH) 
    {
        for(uint i = 0; IndexAssetsHistory > i; i++)
        {
            if(AssetHistory[i].GetAsset() == _asset)
            {
                AH[Ind_AH] = AssetHistory[i];
                Ind_AH++;
            }
        }
    }
    function GetAssetLastHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(AssetsHistory Res_AH) 
    {
        uint temptime;
        uint temppos;
        (AssetsHistory[] memory AH, uint Ind_AH) = GetAssetTotalHistory(_keysystem, _asset);
        for(uint i = 0; Ind_AH > i; i++)
        {
            if(AH[i].GetTimestamp() > temptime)
            {
                temptime = AH[i].GetTimestamp();
                temppos = i;
            }
        }
        Res_AH = AH[temppos];
    }    

    //Metodos de Histórico de Ordens de Venda
    function GetSalesOrderHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(SalesOrderHistory[] memory SOH, uint Ind_SOH) 
    {
        for(uint i = 0; IndexAssetsHistory > i; i++)
        {
            if(SaleOrderHistory[i].GetAsset() == _asset)
            {
                SOH[Ind_SOH] = SaleOrderHistory[i];
                Ind_SOH++;
            }
        }
    }
    function GetSalesOrderLastHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(SalesOrderHistory Res_SOH) 
    {
        uint temptime;
        uint temppos;
        (SalesOrderHistory[] memory SOH, uint Ind_SOH) = GetSalesOrderHistory(_keysystem, _asset);
        for(uint i = 0; Ind_SOH > i; i++)
        {
            if(SOH[i].GetTimestamp() > temptime)
            {
                temptime = SOH[i].GetTimestamp();
                temppos = i;
            }
        }
        Res_SOH = SOH[temppos];
    }

    //Metodos de Histórico de payprofit
    function GetPayProfitPreviewHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(uint[] memory PayProfitPreviewHistory, uint Ind_PPPH) 
    {
        (AssetsHistory[] memory AH, uint Ind_AH) = GetAssetTotalHistory(_keysystem, _asset);
        for(uint i = 0; Ind_AH> i; i++)
        {
            if(AH[i].GetIsPayment())
            {
                PayProfitPreviewHistory[Ind_PPPH] = AH[i].GetPayProfitPreview();
                Ind_PPPH++;
            }
        }
    }
    function GetTotalPaymentHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(uint[] memory TotalPaymentHistory, uint Ind_TPH)
    {
        (AssetsHistory[] memory AH, uint Ind_AH) = GetAssetTotalHistory(_keysystem, _asset);
        for(uint i = 0; Ind_AH> i; i++)
        {
            if(AH[i].GetIsPayment())
            {
                TotalPaymentHistory[Ind_TPH] = AH[i].GetTotalPayment();
                Ind_TPH++;
            }
        }
    }
    function GetIndividualPaymentHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(uint[] memory IndividualPaymentHistory, uint Ind_IPH) 
    {
        (AssetsHistory[] memory AH, uint Ind_AH) = GetAssetTotalHistory(_keysystem, _asset);
        for(uint i = 0; Ind_AH> i; i++)
        {
            if(AH[i].GetIsPayment())
            {
                IndividualPaymentHistory[Ind_IPH] = AH[i].GetIndividualPayment();
                Ind_IPH++;
            }
        }
    }
    function GetTotalAssetsHistory(string memory _keysystem, uint _asset) public view ValidationSystem(_keysystem)
    returns(uint[] memory TotalAssetsHistory, uint Ind_TAH) 
    {
        (AssetsHistory[] memory AH, uint Ind_AH) = GetAssetTotalHistory(_keysystem, _asset);
        for(uint i = 0; Ind_AH> i; i++)
        {
            if(AH[i].GetIsPayment())
            {
                TotalAssetsHistory[Ind_TAH] = AH[i].GetTotalAssets();
                Ind_TAH++;
            }
        }
    }

//===========================================================================================================================================================

    
    //Validações
    modifier ValidationConstruct()
    {
        bool bl = Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        require(!bl);
        _;
    }
    modifier ValidationSystem(string memory _keysystem)
    {
        bool bl = !Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        bool ks = Util.EqualsBytes32(KeySystem, Util.CriptographString(_keysystem));
        require(bl && ks);
        _;
    }
    modifier ValidationDispatch(string memory _keysystem, uint _value, uint _asset)
    {
        bool dt = !Util.IsMarketDate(block.timestamp);
        bool bl = !Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        bool ks = Util.EqualsBytes32(KeySystem, Util.CriptographString(_keysystem));
        bool vb = Assets[_asset].VerifyBalance(msg.sender, _value);
        require(dt && bl && ks && vb);
        _;
    }
    modifier ValidationPurchase(string memory _keysystem, uint _value, uint _asset)
    {
        (SaleOrder[] memory SOA, uint ind_SOA) = Util.SelectSalesOrderByAsset(SalesOrder, IndexSalesOrder, _asset);
        bool dt = !Util.IsMarketDate(block.timestamp);
        bool bl = !Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        bool ks = Util.EqualsBytes32(KeySystem, Util.CriptographString(_keysystem));
        bool ea = Util.CheckAssetSalesValue(SOA, ind_SOA, _value);
        bool ep = Util.CheckAssetSalesPrice(SOA, ind_SOA, _value);
        require(dt && bl && ks && ea && ep);
        _;
    }
    modifier ValidationPayProfit(string memory _keysystem)
    {
        bool bl = !Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        bool dt = Util.IsMarketDate(block.timestamp);
        bool pd = Util.IsProfitDate(block.timestamp);
        bool ks = Util.EqualsBytes32(KeySystem, Util.CriptographString(_keysystem));
        require(dt && bl && ks && pd);
        _;
    }
    modifier ValidationProfit(string memory _keysystem)
    {
        bool bl = !Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        bool dt = Util.IsMarketDate(block.timestamp);
        bool pd = !Util.IsProfitDate(block.timestamp);
        bool ks = Util.EqualsBytes32(KeySystem, Util.CriptographString(_keysystem));
        require(dt && bl && ks && pd);
        _;
    }
    modifier ValidationCreateAssets(string memory _keysystem)
    {
        bool ao = Util.ValidateAssetsByOwner(Assets , IndexAssets, msg.sender);
        bool dt = !Util.IsMarketDate(block.timestamp);
        bool bl = !Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        bool ks = Util.EqualsBytes32(KeySystem, Util.CriptographString(_keysystem));
        require(ao && dt && bl && ks);
        _;
    }
    modifier ValidationDestroyAssets(string memory _keysystem)
    {
        (Asset[] memory SAO, uint Ind_SAO) = Util.SelectAssetsByOwner(Assets, IndexAssets);
        bool bl = !Util.ContainsAddress(BlackList, IndexBlackList, msg.sender);
        bool dt = !Util.IsMarketDate(block.timestamp);
        bool ks = Util.EqualsBytes32(KeySystem, Util.CriptographString(_keysystem));
        bool pp = Util.CheckAssetPayProfitPrice(SAO, Ind_SAO);
        require(dt && bl && ks && pp);
        _;
    }
}