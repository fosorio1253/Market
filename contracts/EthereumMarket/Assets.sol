// SPDX-License-Identifier: MIT
pragma solidity <0.8.1;

contract Asset
{
    //Atributos
    string private Nome;
    string private Cod;
    uint private TotalAtivos;
    uint private PayProfitPreview;
    uint private NTotalAtivos;
    uint private NPayProfitPreview;
    uint private LastPayProfit;
    address payable private Owner;
    mapping (address => uint) private Balances;
    address payable[] private Proprietarios;
    bool private ValidationProfit;
        
    //construtor
    constructor(string memory _nome, string memory _cod, uint _ativos, uint _payprofitpreview) public
    {
        Nome = _nome;
        Cod = _cod;
        TotalAtivos = _ativos;
        PayProfitPreview = _payprofitpreview;
        Owner = msg.sender;
        Balances[Owner] = TotalAtivos;
        for(uint i = 0; TotalAtivos > i; i++)
            Proprietarios[i] = Owner;
    }
    function Finalize() public
    {
        TotalAtivos = 0;
        selfdestruct(Owner);
    }

    //Getters
    function GetAssetProperty(address _addr) public view returns(string memory _nome, string memory _cod, uint _ta, uint _ppp, uint _lpp, uint _balances)
    {
        _nome = GetNome();
        _cod = GetCod();
        _ta = GetTotalAtivos();
        _ppp = GetPayProfitPreview();
        _lpp = GetLastPayProfit();
        _balances = GetBalance(_addr);
    }
    function GetAssetOwner() public view returns(string memory _nome, string memory _cod, uint _ta, uint _ppp, uint _nta, uint _nppp, uint _lpp, uint _balances)
    {
        _nome = GetNome();
        _cod = GetCod();
        _ta = GetTotalAtivos();
        _ppp = GetPayProfitPreview();
        _nta = GetNTotalAtivos();
        _nppp = GetNPayProfitPreview();
        _lpp = GetLastPayProfit();
        _balances = GetBalance(Owner);
    }
    function GetAsset() public view returns(string memory _nome, string memory _cod, uint _ta, uint _ppp, uint _lpp)
    {
        _nome = GetNome();
        _cod = GetCod();
        _ta = GetTotalAtivos();
        _ppp = GetPayProfitPreview();
        _lpp = GetLastPayProfit();
    }
    function GetNome() public view returns(string memory){return Nome;}
    function GetCod() public view returns(string memory){return Cod;}
    function GetTotalAtivos() public view returns(uint){return TotalAtivos;}
    function GetPayProfitPreview() public view returns(uint){return PayProfitPreview;}
    function GetNTotalAtivos() public view returns(uint){return NTotalAtivos;}
    function GetNPayProfitPreview() public view returns(uint){return NPayProfitPreview;}
    function GetLastPayProfit() public view returns(uint){return LastPayProfit;}
    function GetOwner() public view returns(address payable){return Owner;}
    function GetBalance(address _addr) public view returns(uint){return Balances[_addr];}
    function GetProprietarios() public view returns(address payable[] memory){return Proprietarios;}
    function GetValidationProfit() public view returns(bool){return ValidationProfit;}

    //Metodos
    function IsOwner(address _addr) public view returns(bool)
    {
        if(GetOwner() == _addr)
            return true;
        return false;
    }
    function VerifyBalance(address _addr, uint _value) public view returns(bool)
    {
        if(GetBalance(_addr) > _value)
            return true;
        return false;
    }
    function TrasferBalance(address _from, address payable _to, uint _value) public returns(bool)
    {
        if(VerifyBalance(_from, _value))
        {
            Balances[_from] -= _value;
            Balances[_to] += _value;
            for(uint i = 0; TotalAtivos > i; i++)
            {
                if(Proprietarios[i] == _from)
                    Proprietarios[i] = _to;
            }
            return true;
        }
        return false;
    }
    
    //Metodos datados
    function AddLastPayProfit(uint _lastpayprofit) public returns(bool)
    {
        LastPayProfit = _lastpayprofit;
        return true;
    }
    function NewTotalAssets(uint _assets) public returns(bool)
    {
        NTotalAtivos = _assets;
        return true;
    }
    function NewPayProfitPreview(uint _npayprofit) public returns(bool)
    {
        NPayProfitPreview = _npayprofit;
        return true;
    }
    function PayProfit(uint _totalpay) public
    returns(uint totalpay, uint pay)
    {
        totalpay = _totalpay;
        pay = _totalpay / GetTotalAtivos();
        for(uint x = 0; GetTotalAtivos() > x; x++)
            GetProprietarios()[x].transfer(pay);
        AddLastPayProfit(_totalpay);
        ValidationProfit = true;
    }
    function ExecuteNewConf() public
    returns(bool)
    {
        PayProfitPreview = NPayProfitPreview;
        TotalAtivos = NTotalAtivos;
        return true;
    }    
}