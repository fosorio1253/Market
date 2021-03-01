// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.8.1;

contract SalesOrderHistory
{
    //Atributos
    uint private Timestamp;
    uint private Asset;
    uint private Value;
    uint private Price;
    address private Shareholder;
    bool private IsSale;
    bool private IsBuy;

    //Construtor
    constructor(uint _asset, uint _value, uint _price, bool _sale, bool _buy) public
    {
        Timestamp = block.timestamp;
        Asset = _asset;
        Value = _value;
        Price = _price;
        Shareholder = msg.sender;
        IsSale = _sale;
        IsBuy = _buy;
    }

    //Gettes
    function GetHistory() public view
    returns(uint, uint, uint, uint, bool, bool)
    {return(Timestamp, Asset, Value, Price, IsSale, IsBuy);}

    function GetTimestamp() public view returns(uint){return Timestamp;}
    function GetAsset()     public view returns(uint){return Asset;}
    function GetValue()     public view returns(uint){return Value;}
    function GetPrice()     public view returns(uint){return Price;}
    function GetIsSale()    public view returns(bool){return IsSale;}
    function GetIsBuy()     public view returns(bool){return IsBuy;}

    function IsOwner(address _addr) public view
    returns(bool)
    {
        if(Shareholder == _addr)
            return true;
        return false;
    }
}