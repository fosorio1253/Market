// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.8.1;

import "./Assets.sol";
import "./SalesOrder.sol";
import "./Time.sol";
import "./AssetsHistory.sol";

contract Utils
{
    Time private TM;

    //Assets Utils
    function SelectAssetsByAddress(Asset[] memory _assets, uint _dim, address payable _addr) public view
    returns(uint[] memory SAA, uint ind_SAA)
    {
        for(uint i = 0; _dim > i; i++)
        {
            if(ContainsAddress(_assets[i].GetProprietarios(), _assets[i].GetTotalAtivos(), _addr))
            {
                SAA[ind_SAA] = i;
                ind_SAA++;
            }
        }
    }

    function SelectAssetsByOwner(Asset[] memory _assets, uint _dim) public view
    returns(Asset[] memory SAO, uint ind_SAO)
    {
        for(uint i = 0; _dim > i; i++)
        {
            if(_assets[i].GetOwner() == msg.sender)
            {
                SAO[ind_SAO] = _assets[i];
                ind_SAO++;
            }
        }
    }

    function CheckAssetSalesValue(SaleOrder[] memory _salesorder, uint _dim, uint _value) public view
    returns(bool)
    {
        uint tempval;
        for(uint i = 0; _dim > i; i++)
            tempval += _salesorder[i].GetValor();
        if(tempval > _value)
            return true;
        return false;
    }

    function CheckAssetSalesPrice(SaleOrder[] memory _salesorder, uint _dim, uint _value) public view
    returns(bool)
    {
        uint tempvalue = _value;
        uint disp = 0;
        for(uint i = 0; _dim > i; i++)
        {
            if(tempvalue > 0)
            {
                if(_salesorder[i].GetValor() > tempvalue)
                {
                    disp += _salesorder[i].GetPreco() * tempvalue;
                    tempvalue = 0;
                }
                else
                {
                    disp += _salesorder[i].GetPreco() * _salesorder[i].GetValor();
                    tempvalue -= _salesorder[i].GetValor();
                }
            }
        }
        if(msg.sender.balance > disp)
            return true;
        return false;
    }

    function ReorderAssets(Asset[] memory _assets, uint _dim) public view
    returns(Asset[] memory nassets, uint ndim) 
    {
        for(uint i = 0; _dim > i; i++)
        {
            if(_assets[i].GetTotalAtivos() != 0)
            {
                nassets[ndim] = _assets[i];
                ndim ++;
            }
        }        
    }

    function CreateAssetHistory(Asset _assets, uint _totalpayment, uint _individualpayment, uint _status, uint _asset) public
    returns(AssetsHistory AH)
    {
        if(_status == 1)
            AH = new AssetsHistory(_asset, _assets.GetPayProfitPreview(), _assets.GetTotalAtivos(), _totalpayment, _individualpayment, true, false, false, false);
        if(_status == 2)
            AH = new AssetsHistory(_asset, _assets.GetPayProfitPreview(), _assets.GetTotalAtivos(), _totalpayment, _individualpayment, false, true, false, false);
        if(_status == 3)
            AH = new AssetsHistory(_asset, _assets.GetPayProfitPreview(), _assets.GetTotalAtivos(), _totalpayment, _individualpayment, false, false, true, false);
        if(_status == 4)
            AH = new AssetsHistory(_asset, _assets.GetPayProfitPreview(), _assets.GetTotalAtivos(), _totalpayment, _individualpayment, false, false, false, true);
    }

    function ContainsAddress(address payable[] memory _addrs, uint _dim, address payable _search) public pure
    returns(bool)
    {
        for(uint i = 0; _dim > i; i++)
        {
            if(_addrs[i] == _search)
                return true;
        }
        return false;
    }

    function ValidateAssetsByOwner(Asset[] memory _assets, uint _dim, address _search) public view
    returns(bool)
    {
        uint rest;
        for(uint i = 0; _dim > i; i++)
        {
            if(_assets[i].GetOwner() == _search)
                rest++;
            if(rest == 4)
                return false;
        }
        return true;
    }

//======================================================================================================

    //SalesOrder Utils
    function SelectSalesOrderByAsset(SaleOrder[] memory _salesorder, uint _dim, uint _asset) public view
    returns(SaleOrder[] memory SOA, uint ind_SOA)
    {
        for(uint i = 0; _dim > i; i++)
        {
            if(_salesorder[i].GetAtivo() == _asset)
            {
                SOA[ind_SOA] = _salesorder[i];
                ind_SOA++;
            }
        }
    }

    function ReorderSalesOrder(SaleOrder[] memory _salesorder, uint _dim) public view
    returns(SaleOrder[] memory nsalesorder, uint ndim) 
    {
        for(uint i = 0; _dim > i; i++)
        {
            if(_salesorder[i].GetValor() != 0)
            {
                nsalesorder[ndim] = _salesorder[i];
                ndim++;
            }
        }
        quickSortSO(nsalesorder, uint(0), uint(nsalesorder.length - 1));
    }

    function quickSortSO(SaleOrder[] memory arr, uint left, uint right) private view 
    {
        uint i = left;
        uint j = right;

        if(i==j) return;

        SaleOrder pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j)
        {
            while (arr[uint(i)].GetPreco() < pivot.GetPreco()) i++;
            while (pivot.GetPreco() < arr[uint(j)].GetPreco()) j--;

            if (i <= j)
            {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSortSO(arr, left, j);
        if (i < right)
            quickSortSO(arr, i, right);
    }

    function ProcessSalesOrder(SaleOrder[] memory _salesorder, uint _dim, uint _value, uint _asset) public view
    returns(uint Ind_Seller, address payable[] memory Seller, uint[] memory Price, uint[] memory Value, uint Tax) 
    {
        uint rest = _value;
        (SaleOrder[] memory SOA, uint ind_SOA) = SelectSalesOrderByAsset(_salesorder, _dim, _asset);
        for(uint i = 0; ind_SOA > i; i++)
        {
            if(rest > 0)
            {
                uint trest = rest;
                (Price[Ind_Seller], rest) = SOA[i].VerifyPriceByValue(rest);
                Seller[Ind_Seller] = SOA[i].GetVendedor();
                Value[Ind_Seller] = trest - rest;
                Tax += SOA[i].GetTaxa();
                Ind_Seller++;
            }
        }
    }

//======================================================================================================
    
    //Payprofit Utils
    function CheckAssetPayProfitPrice(Asset[] memory _assets, uint _dim) public view
    returns(bool)
    {
        uint disp = 0;
        for(uint i = 0; _dim > i; i++)
            disp += _assets[i].GetPayProfitPreview();
        if(msg.sender.balance > uint(disp * 1/100))
            return true;
        return false;
    }

    function CheckAssetPayProfitTotalPrice(Asset[] memory _assets, uint _dim) public view
    returns(bool)
    {
        uint disp = 0;
        for(uint i = 0; _dim > i; i++)
            disp += _assets[i].GetPayProfitPreview();
        if(msg.sender.balance - tx.gasprice > disp)
            return true;
        return false;
    }

    function SelectPayProfitAssetTotalPrice(Asset[] memory _assets, uint _dim) public view
    returns(uint disp)
    {
        for(uint i = 0; _dim > i; i++)
            disp += _assets[i].GetPayProfitPreview();
    }

    function PreparePayProfit(Asset[] memory _assets, Asset[] memory SAO, uint _dim, uint Ind_SAO) public
    returns(uint totalpay, uint pay, uint[] memory asset, uint ind_asset)
    {
        for(uint i = 0; _dim > i; i++)
        {
            if(_assets[i].IsOwner(msg.sender) && !_assets[i].GetValidationProfit())
            {                
                if(CheckAssetPayProfitTotalPrice(SAO, Ind_SAO))
                {
                    (totalpay, pay) = _assets[i].PayProfit(_assets[i].GetPayProfitPreview());                    
                }
                else
                    (totalpay, pay) = _assets[i].PayProfit(_assets[i].GetPayProfitPreview() * ((msg.sender.balance - tx.gasprice) / SelectPayProfitAssetTotalPrice(SAO, Ind_SAO)));
                asset[ind_asset] = i;
                ind_asset++;                    
            }
        }
    }

    function ValidateProfitHistory(AssetsHistory _ah) public view
    returns(bool)
    {
        if(TM.getMonth(_ah.GetTimestamp()) == TM.getMonth(block.timestamp) && TM.getYear(_ah.GetTimestamp()) == TM.getYear(block.timestamp))
            return true;
        return false;
    }

//======================================================================================================

    //Others Utils
    

    function EqualsBytes32(bytes32 _dataA, bytes32 _dataB) public pure
    returns(bool)
    {
        if(_dataA == _dataB)
            return true;
        return false;
    }
    
    function CriptographString(string memory _word) public pure
    returns(bytes32)
    {
        return keccak256(abi.encodePacked(_word));
    }

    function IsMarketDate(uint _timestamp) public view returns(bool)
    {
        if(TM.getMonth(_timestamp) == 6 || TM.getMonth(_timestamp) == 12)
        {
            if(TM.getDay(_timestamp) > 20 && TM.getDay(_timestamp) < 30)
                return true;
        }
        return false;
    }
    function IsProfitDate(uint _timestamp) public view returns(bool)
    {
        if(TM.getMonth(_timestamp) == 6 || TM.getMonth(_timestamp) == 12)
        {
            if(TM.getDay(_timestamp) > 20 && TM.getDay(_timestamp) < 25)
                return true;
        }
        return false;
    }

    function GetAssetCreateDatefromHistory(AssetsHistory[] memory _AH, uint _Ind_AH, uint _asset) public view
    returns(uint Day , uint Month, uint Year) 
    {
        for(uint i = 0; _Ind_AH > i; i++)
        {
            if(_AH[i].GetAsset() == _asset && _AH[i].GetIsCreate())
            {
                return(TM.getDay(_AH[i].GetTimestamp()), TM.getMonth(_AH[i].GetTimestamp()), TM.getYear(_AH[i].GetTimestamp()));
            }
        }
    }
}