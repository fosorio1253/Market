// SPDX-License-Identifier: GPL-3.0

pragma solidity <0.8.1;

contract SaleOrder
{
    //Atributos
    address payable Vendedor;
    uint Valor;
    uint Preco;
    uint Ativo;
    
    //Construtor
    constructor(address payable _addr, uint _valor, uint _preco, uint _ativo) public
    {
        Vendedor = _addr;
        Valor = _valor;
        Preco = _preco;
        Ativo = _ativo;
    }
    
    //Getters
    function GetOrdem() public view returns(uint _Valor, uint _preco, uint _taxa, uint _tot, uint _ativo)
    {
        _Valor = GetValor();
        _preco = GetPreco();
        _taxa = GetTaxa();
        _tot = GetPrecoTotal();
        _ativo = GetAtivo();
    }
    function GetVendedor() public view returns(address payable){return Vendedor;}
    function GetValor() public view returns(uint){return Valor;}
    function GetPreco() public view returns(uint){return Preco;}
    function GetTaxa() public view returns(uint){return uint(Preco * 1/100);}
    function GetPrecoTotal() public view returns(uint){return Preco + uint(Preco * 1/100);}
    function GetAtivo() public view returns(uint){return Ativo;}
    
    //Metodos
    function VerifyTotalPrice() public view returns(uint)
    {
        return GetValor()*GetPreco();
    }
    function VerifyPriceByValue(uint _value) public view returns(uint price, uint rest)
    {
        if(GetValor() > _value)
        {
            price = GetPreco()* _value;
            rest = 0;
        }
        else
        {
            price = VerifyTotalPrice();
            rest = _value - GetValor();
        }
    }
    function VerifyValor(uint _valor) public view returns(bool)
    {
        if(GetValor() > _valor)
            return true;
        return false;
    }
    function IsVendedor(address payable _addr) public view returns(bool)
    {
        if(GetVendedor() == _addr)
            return true;
        return false;
    }
    function DeduzirValor(uint _valor) public returns(uint _resto, uint _deduzido)
    {
        if(VerifyValor(_valor))
        {
            _resto = 0;
            _deduzido = _valor;
            Valor -= _valor;
        }
        else
        {
            _resto = _valor - Valor;
            _deduzido = _valor - _resto;
            Valor = 0;
        }
    }
}