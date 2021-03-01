// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.8.1;

contract AssetsHistory
{
    //Atributos
    uint private Asset;
    uint private Timestamp;
    uint private PayProfitPreview;
    uint private TotalAssets;
    uint private TotalPayment;
    uint private IndividualPayment;
    bool private IsCreate;
    bool private IsFinalyze;
    bool private IsPayment;
    bool private IsValidation;

    //Construtor
    constructor(uint _asset, uint _ppp, uint _ta, uint _tp, uint _ip, bool _c, bool _f, bool _p, bool _v) public
    {
        Asset = _asset;
        Timestamp = block.timestamp;
        PayProfitPreview = _ppp;
        TotalAssets = _ta;
        TotalPayment = _tp;
        IndividualPayment = _ip;
        IsCreate = _c;
        IsFinalyze = _f;
        IsPayment = _p;
        IsValidation = _v;
    }

    //Gettes
    function GetHistory() public view
    returns(uint timestamp, uint ppp, uint ta, uint tp, uint ip, bool c, bool f, bool p, bool v)
    {
        timestamp = GetTimestamp();
        ppp = GetPayProfitPreview();
        ta = GetTotalAssets();
        tp = GetTotalPayment();
        ip = GetIndividualPayment();
        c = GetIsCreate();
        f = GetIsFinalyze();
        p = GetIsPayment();
        v = GetIsValidation();
    }
    function GetAsset() public view returns(uint){return Asset;}
    function GetTimestamp() public view returns(uint){return Timestamp;}
    function GetPayProfitPreview() public view returns(uint){return PayProfitPreview;}
    function GetTotalAssets() public view returns(uint){return TotalAssets;}
    function GetTotalPayment() public view returns(uint){return TotalPayment;}
    function GetIndividualPayment() public view returns(uint){return IndividualPayment;}
    function GetIsCreate() public view returns(bool){return IsCreate;}
    function GetIsFinalyze() public view returns(bool){return IsFinalyze;}
    function GetIsPayment() public view returns(bool){return IsPayment;}
    function GetIsValidation() public view returns(bool){return IsValidation;}
}