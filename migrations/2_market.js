var market = artifacts.require("Market");
module.export = function(deployer)
{
    deployer.deploy(Time);
    deployer.deploy(Asset);
    deployer.deploy(AssetsHistory);
    deployer.deploy(SaleOrder);
    deployer.deploy(SalesOrderHistory);
    
    deployer.link([SaleOrder, Asset, Time, AssetsHistory], Utils);
    deployer.deploy(Utils);

    deployer.link([SaleOrder, Asset, SalesOrderHistory, AssetsHistory, Utils], Market);
    deployer.deploy(market);
};